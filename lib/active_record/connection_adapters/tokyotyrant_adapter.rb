require 'active_record/connection_adapters/abstract_tokyocabinet_adapter'
require 'tokyotyrant'

module ActiveRecord
  class Base
    def self.tokyotyrant_connection(config)
      unless config[:database].kind_of?(Hash)
        raise ArgumentError, "Incorrect argument: database"
      end

      ConnectionAdapters::TokyoTyrantAdapter.new({}, logger, config)
    end
  end

  module ConnectionAdapters
    class TokyoTyrantAdapter < AbstractTokyoCabinetAdapter
      def initialize(connection, logger, config)
        super(connection, logger, TokyoTyrant::RDBQRY)
        @database = {}

        config.fetch(:database).map do |table_name, attribute|
          attribute.keys.each do |k|
            attribute[k.to_s] = attribute[k]
          end

          @database[table_name.to_s] = {
            :host => attribute.fetch('host').to_s,
            :port => attribute.fetch('port', 0).to_i,
            :timeout => attribute.fetch('timeout', 0).to_i,
          }
        end
      end

      def table_exists?(table_name)
        @database.has_key?(table_name)
      end

      def disconnect!
        super

        @connection.keys.each do |table_name|
          conn = @connection[table_name]
          conn.close
          @connection.delete(table_name)
        end
      end

      def tdbopen(table_name, readonly = false)
        unless table_exists?(table_name)
          raise "Table does not exist: #{table_name}"
        end

        unless (tdb = @connection[table_name])
          host, port, timeout = @database.fetch(table_name).values_at(:host, :port, :timeout)
          tdb = TokyoTyrant::RDBTBL::new

          unless tdb.open(host, port, timeout)
            ecode = tdb.ecode
            raise "%s: %s:%s" % [tdb.errmsg(ecode), host, port]
          end
        end

        yield(tdb)
        @connection[table_name] = tdb
      end

      def search(tdb, parsed_sql)
        condition = parsed_sql[:condition] || []

        unless cond?(condition)
          super(tdb, parsed_sql)
        else
          select_list = parsed_sql[:select_list]

          if select_list.nil? or select_list.empty?
            names = nil
          else
            names = select_list.map {|i| i.split('.').last }
          end

          rows = query(tdb, parsed_sql).searchget

          if block_given?
            rows.each do |i|
              yield(tdb, i[""].to_i, i)
            end
          else
            rows.each {|i| i['id'] = i[""].to_i }
          end

          return rows
        end
      end
      private :search

      def rnum(tdb, parsed_sql)
        if (parsed_sql[:condition] || []).empty?
          tdb.rnum
        else
          query(tdb, parsed_sql).searchcount
        end
      end
      private :rnum

      def setindex(table_name, name, type)
        type = {
          :lexical => TokyoTyrant::RDBTBL::ITLEXICAL,
          :decimal => TokyoTyrant::RDBTBL::ITDECIMAL,
          :token   => TokyoTyrant::RDBTBL::ITTOKEN,
          :qgram   => TokyoTyrant::RDBTBL::ITQGRAM,
          :opt     => TokyoTyrant::RDBTBL::ITOPT,
          :void    => TokyoTyrant::RDBTBL::ITVOID,
          :keep    => TokyoTyrant::RDBTBL::ITKEEP,
        }.fetch(type)

        name = name.to_s

        unless (tdb = @connection[table_name])
          host, port, timeout = @database.fetch(table_name).values_at(:host, :port, :timeout)
          tdb = TokyoTyrant::RDBTBL::new

          unless tdb.open(host, port, timeout)
            ecode = tdb.ecode
            raise "%s: %s:%s" % [tdb.errmsg(ecode), host, port]
          end
        end

        begin
          unless tdb.setindex(name, type)
            ecode = tdb.ecode
            raise "%s: %s:%s" % [tdb.errmsg(ecode), host, port]
          end
        ensure
          unless tdb.close
            ecode = tdb.ecode
            raise tdb.errmsg(ecode)
          end
        end
      end
    end
  end
end
