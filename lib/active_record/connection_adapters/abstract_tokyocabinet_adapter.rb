require 'active_record/connection_adapters/abstract_adapter'
require 'active_tokyocabinet/tdb'
require 'active_tokyocabinet/sqlparser.tab'

module ActiveRecord
  module ConnectionAdapters
    class AbstractTokyoCabinetAdapter < AbstractAdapter
      def initialize(connection, logger, query_clazz)
        super(connection, logger)
        @query_clazz = query_clazz
      end

      def select(sql, name = nil)
        rows = []

        log(sql, name) do
          parsed_sql = ActiveTokyoCabinet::SQLParser.new(sql).parse

          tdbopen(parsed_sql) do |tdb|
            select_list = parsed_sql[:select_list]

            rkeys(tdb, parsed_sql).each do |rkey|
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

          tdbopen(parsed_sql) do |tdb|
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

          tdbopen(parsed_sql) do |tdb|
            set_clause_list = parsed_sql[:set_clause_list]

            rkeys(tdb, parsed_sql).each do |rkey|
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

        return rownum
      end

      def delete_sql(sql, name = nil) #:nodoc:
        rownum = 0

        log(sql, name) do
          parsed_sql = ActiveTokyoCabinet::SQLParser.new(sql).parse

          tdbopen(parsed_sql[:table], TokyoCabinet::TDB::OWRITER) do |tdb|
            rkeys(tdb, parsed_sql)
            set_clause_list = parsed_sql[:set_clause_list]

            rkeys(tdb, parsed_sql).each do |rkey|
              rownum += 1

              unless tdb.out(rkey)
                ecode = tdb.ecode
                raise '%s: %s' % [tdb.errmsg(ecode), sql]
              end
            end
          end
        end

        return rownum
      end

      def rkeys(tdb, parsed_sql)
        condition, order, limit, offset = parsed_sql.values_at(:condition, :order, :limit, :offset)
        condition ||= []

        unless condition.kind_of?(Array) and condition.all? {|i| i.kind_of?(Hash) }
          return [parsed_sql[:condition]].flatten
        end

        qry = @query_clazz::new(tdb)

        condition.each do |cond|
          name, op, expr = cond.values_at(:name, :op, :expr)
          op = @query_clazz.const_get(op)
          expr = expr.kind_of?(Array) ? expr.join(' ') : expr.to_s
          qry.addcond(name, op, expr)
        end

        if order
          name, type = order.values_at(:name, :type)
          type = @query_clazz.const_get(type)
          qry.setorder(name, type)
        end

        if limit or offset
          qry.setlimit(limit || 0, offset || 0)
        end

        return qry.search
      end
      private :tdbqry
    end
  end
end
