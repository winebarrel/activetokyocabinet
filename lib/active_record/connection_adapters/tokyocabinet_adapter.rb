require 'active_record/connection_adapters/abstract_tokyocabinet_adapter'
require 'tokyocabinet'

module ActiveRecord
  class Base
    def self.tokyocabinet_connection(config)
      unless config[:database].kind_of?(String)
        raise ArgumentError, "Incorrect argument: database"
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

      def tdbopen(table_name, readonly = false)
        path = tdbpath(table_name)

        if File.exist?(path) and readonly
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

      def rnum(tdb, parsed_sql)
        if (parsed_sql[:condition] || []).empty?
          tdb.rnum
        else
          rkeys(tdb, parsed_sql).length
        end
      end
      private :rnum

      def setindex(table_name, name, type)
        type = {
          :lexical => TokyoCabinet::TDB::ITLEXICAL,
          :decimal => TokyoCabinet::TDB::ITDECIMAL,
          :token   => TokyoCabinet::TDB::ITTOKEN,
          :qgram   => TokyoCabinet::TDB::ITQGRAM,
          :void    => TokyoCabinet::TDB::ITVOID,
          :keep    => TokyoCabinet::TDB::ITKEEP,
        }.fetch(type)

        name = name.to_s
        path = tdbpath(table_name)
        tdb = TokyoCabinet::TDB::new

        unless tdb.open(path, TokyoCabinet::TDB::OWRITER | TokyoCabinet::TDB::OCREAT)
          ecode = tdb.ecode
          raise "%s: %s" % [tdb.errmsg(ecode), path]
        end

        begin
          unless tdb.setindex(name, type)
            ecode = tdb.ecode
            raise "%s: %s" % [tdb.errmsg(ecode), path]
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
