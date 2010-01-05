require 'active_record/connection_adapters/abstract_adapter'
require 'tokyocabinet'
require 'active_tokyocabinet/tdb'
require 'active_tokyocabinet/sqlparser.tab'

module ActiveRecord
  class Base
    def self.tokyocabinet_connection(config)
      unless config[:database]
        raise ArgumentError, "No database file specified. Missing argument: database"
      end

      if Object.const_defined?(:RAILS_ROOT)
        config[:database] = File.expand_path(config[:database], RAILS_ROOT)
      end

      ConnectionAdapters::TokyoCabinetAdapter.new(nil, logger, config)
    end
  end

  module ConnectionAdapters
    class TokyoCabinetAdapter < AbstractAdapter
      def initialize(connection, logger, config)
        super(connection, logger)
        @config = config
      end

      def table_exists?(table_name)
        path = tdbpath(table_name)
        File.exist?(path)
      end

      def select(sql, name = nil)
        rows = []

        log(sql, name) do
          parsed_sql = ActiveTokyoCabinet::SQLParser.new(sql).parse

          tdbopen(parsed_sql[:table], TokyoCabinet::TDB::OREADER) do |tdb|
            if (qry = tdbqry(tdb, parsed_sql))
              rkeys = qry.search
            else
              rkeys = [parsed_sql[:condition]].flatten
            end

            select_list = parsed_sql[:select_list]

            rkeys.each do |rkey|
              rcols = tdb.get(rkey)
              next if rcols.nil?

              unless select_list.nil? or select_list.empty?
                rcols = select_list.each {|k| r[k] = rcols[k] }
              end

              rcols['id'] = rkey
              rows << rcols
            end
          end

          if (count = parsed_sql[:count])
            rows = [{count => rows.length}]
          end
        end

        return rows
      end

      def insert_sql(sql, name = nil, pk = nil, id_value = nil, sequence_name = nil)
        pkey = nil

        log(sql, name) do
          parsed_sql = ActiveTokyoCabinet::SQLParser.new(sql).parse

          tdbopen(parsed_sql[:table], TokyoCabinet::TDB::OWRITER) do |tdb|
            pkey = tdb.genuid
            keys = parsed_sql[:column_list]
            vals = parsed_sql[:value_list]
            cols = {}

            keys.zip(vals).each do |k, v|
              cols[k] = v.to_s
            end

            unless tdb.put(pkey, cols)
              ecode = tdb.ecode
              raise '%s: %s' % [tdb.errmsg(ecode), sql]
            end
          end
        end
        return pkey
      end

      def update_sql(sql, name = nil)
        rownum = 0

        log(sql, name) do
          parsed_sql = ActiveTokyoCabinet::SQLParser.new(sql).parse

          tdbopen(parsed_sql[:table], TokyoCabinet::TDB::OWRITER) do |tdb|
            set_clause_list = parsed_sql[:set_clause_list]

            if (qry = tdbqry(tdb, parsed_sql))
              r = qry.proc do |pkey, cols|
                set_clause_list.each do |k, v|
                  cols[k] = v.to_s
                end

                rownum += 1
                TokyoCabinet::TDBQRY::QPPUT
              end

              unless r
                ecode = tdb.ecode
                raise '%s: %s' % [tdb.errmsg(ecode), sql]
              end
            else
              [parsed_sql[:condition]].flatten.each do |rkey|
                rcols = tdb.get(rkey)

                set_clause_list.each do |k, v|
                  rcols[k] = v.to_s
                end

                rownum += 1

                unless tdb.put(rkey, rcols)
                  ecode = tdb.ecode
                  raise '%s: %s' % [tdb.errmsg(ecode), sql]
                end
              end
            end
          end
        end

        return rownum
      end

      def delete_sql(sql, name = nil) #:nodoc:
        rownum = 0

        log(sql, name) do
          parsed_sql = ActiveTokyoCabinet::SQLParser.new(sql).parse

          tdbopen(parsed_sql[:table], TokyoCabinet::TDB::OWRITER) do |tdb|
            set_clause_list = parsed_sql[:set_clause_list]

            if (qry = tdbqry(tdb, parsed_sql))
              r = qry.proc do |pkey, cols|
                rownum += 1
                TokyoCabinet::TDBQRY::QPOUT
              end

              unless r
                ecode = tdb.ecode
                raise '%s: %s' % [tdb.errmsg(ecode), sql]
              end
            else
              [parsed_sql[:condition]].flatten.each do |rkey|
                rownum += 1

                unless tdb.out(rkey)
                  ecode = tdb.ecode
                  raise '%s: %s' % [tdb.errmsg(ecode), sql]
                end
              end
            end
          end
        end

        return rownum
      end

      def tdbopen(table_name, omode)
        tdb = TokyoCabinet::TDB::new
        path = tdbpath(table_name)

        unless File.exist?(path)
          omode = TokyoCabinet::TDB::OWRITER | TokyoCabinet::TDB::OCREAT
        end

        unless tdb.open(path, omode)
          ecode = tdb.ecode
          raise "%s: %s" % [tdb.errmsg(ecode), path]
        end

        begin
          yield(tdb)
        ensure
          unless tdb.close
            ecode = tdb.ecode
            raise tdb.errmsg(ecode)
          end
        end
      end
      private :tdbopen

      def tdbqry(tdb, parsed_sql)
        condition, order, limit, offset = parsed_sql.values_at(:condition, :order, :limit, :offset)
        condition ||= []

        unless condition.kind_of?(Array) and condition.all? {|i| i.kind_of?(Hash) }
          return nil
        end

        qry = TokyoCabinet::TDBQRY::new(tdb)

        condition.each do |cond|
          name, op, expr = cond.values_at(:name, :op, :expr)
          op = TokyoCabinet::TDBQRY.const_get(op)
          expr = expr.kind_of?(Array) ? expr.join(' ') : expr.to_s
          qry.addcond(name, op, expr)
        end

        if order
          name, type = order.values_at(:name, :type)
          type = TokyoCabinet::TDBQRY.const_get(type)
          qry.setorder(name, type)
        end

        if limit or offset
          qry.setlimit(limit || 0, offset || 0)
        end

        return qry
      end
      private :tdbqry

      def tdbpath(table_name)
        File.join(@config[:database], table_name + ".tct")
      end
      private :tdbpath
    end
  end
end
