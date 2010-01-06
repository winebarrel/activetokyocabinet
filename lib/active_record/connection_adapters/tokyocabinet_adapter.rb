require 'active_record/connection_adapters/abstract_tokyocabinet_adapter'
require 'tokyocabinet'

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
    class TokyoCabinetAdapter < AbstractTokyoCabinetAdapter
      def initialize(connection, logger, config)
        super(connection, logger, TokyoCabinet::TDBQRY)
        @config = config
      end

      def table_exists?(table_name)
        path = tdbpath(table_name)
        File.exist?(path)
      end

      def tdbopen(pa)
        table_name = parsed_sql[:table]
        path = tdbpath(table_name)

        if File.exist?(path) and parsed_sql[:command] == :select
          omode = TokyoCabinet::TDB::OREADER
        else
          omode = TokyoCabinet::TDB::OWRITER | TokyoCabinet::TDB::OCREAT
        end

        tdb = TokyoCabinet::TDB::new

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

      def tdbpath(table_name)
        File.join(@config[:database], table_name + ".tct")
      end
      private :tdbpath
    end
  end
end
