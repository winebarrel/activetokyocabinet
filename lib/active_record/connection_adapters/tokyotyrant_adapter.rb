require 'active_record/connection_adapters/abstract_tokyocabinet_adapter'
require 'tokyotyrant'

module ActiveRecord
  class Base
    def self.tokyotyrant_connection(config)
      ConnectionAdapters::TokyoTyrantAdapter.new(nil, logger, config)
    end
  end

  module ConnectionAdapters
    class TokyoTyrantAdapter < AbstractTokyoCabinetAdapter
      def initialize(connection, logger, config)
        super(connection, logger, TokyoTyrant::RDBTBL)
        @config = {}

        config.map do |k, v|
          @config[k] = {
            :host => v.fetch(:host).to_s,
            :port => v.fetch(:port, 0).to_i,
            :timeout => v.fetch(:timeout, 0).to_i,
          }
        end
      end

      def table_exists?(table_name)
        @config.has_key?(table_name)
      end

      def tdbopen(parsed_sql)
        table_name = parsed_sql[:table]
        host, port, timeout = @config.fetch(table_name).values_at(:host, :port, :timeout)

        tdb = TokyoTyrant::RDBTBL::new

        unless tdb.open(host, port, timeout)
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
    end
  end
end
