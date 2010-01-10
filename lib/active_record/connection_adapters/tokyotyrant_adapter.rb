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

      def tdbopen(parsed_sql)
        table_name = parsed_sql[:table]

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
      private :tdbopen
    end
  end
end
