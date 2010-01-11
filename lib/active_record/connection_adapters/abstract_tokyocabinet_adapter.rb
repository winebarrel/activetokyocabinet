require 'active_record/connection_adapters/abstract_adapter'
require 'active_tokyocabinet/tdb'
require 'active_tokyocabinet/sqlparser.tab'

module ActiveRecord
  module ConnectionAdapters
    class AbstractTokyoCabinetAdapter < AbstractAdapter
      def initialize(connection, logger, query_klass)
        super(connection, logger)
        @query_klass = query_klass
      end

      def supports_count_distinct?
        false
      end

      def select(sql, name = nil)
        rows = nil

        log(sql, name) do
          parsed_sql = ActiveTokyoCabinet::SQLParser.new(sql).parse

          tdbopen(parsed_sql) do |tdb|
            if (count = parsed_sql[:count])
              rows = [{count => rnum(tdb, parsed_sql)}]
            else
              rows = search(tdb, parsed_sql)
            end
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
              k.split('.').last
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
                k.split('.').last
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

      def delete_sql(sql, name = nil)
        log(sql, name) do
          parsed_sql = ActiveTokyoCabinet::SQLParser.new(sql).parse

          tdbopen(parsed_sql) do |tdb|
            unless query(tdb, parsed_sql).searchout
              ecode = tdb.ecode
              raise '%s: %s' % [tdb.errmsg(ecode), sql]
            end
          end
        end

        # XXX:
        return 1
      end

      def search(tdb, parsed_sql)
        rows = []
        select_list = parsed_sql[:select_list]

        rkeys(tdb, parsed_sql).each do |rkey|
          rcols = tdb.get(rkey)
          next if rcols.nil?
  
          unless select_list.nil? or select_list.empty?
            rcols = select_list.each do |k|
              k = k.split('.').last
              r[k] = rcols[k]
            end
          end

          rcols['id'] = rkey.to_i
          rows << rcols
        end

        return rows
      end
      private :search

      def cond?(condition)
        condition.kind_of?(Array) and condition.all? {|i| i.kind_of?(Hash) }
      end
      private :cond?

      def rkeys(tdb, parsed_sql)
        condition = parsed_sql[:condition] || []

        unless cond?(condition)
          return [condition].flatten
        end

        query(tdb, parsed_sql).search
      end
      private :rkeys

      def query(tdb, parsed_sql)
        condition, order, limit, offset = parsed_sql.values_at(:condition, :order, :limit, :offset)
        condition ||= []

        qry = @query_klass::new(tdb)

        condition.each do |cond|
          name, op, expr = cond.values_at(:name, :op, :expr)
          name = name.split('.').last
          op = @query_klass.const_get(op)
          expr = expr.kind_of?(Array) ? expr.join(' ') : expr.to_s
          qry.addcond(name, op, expr)
        end

        if order
          name, type = order.values_at(:name, :type)
          type = @query_klass.const_get(type)
          qry.setorder(name, type)
        end

        if limit or offset
          qry.setlimit(limit || 0, offset || 0)
        end

        return qry
      end
      private :query
    end
  end
end
