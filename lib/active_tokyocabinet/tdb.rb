module ActiveTokyoCabinet
  module TDB
    def self.included(mod)
      {:string => :to_s, :int => :to_i, :float => :to_f}.each do |type, conv|
        mod.instance_eval %{
          def #{type}(name)
            unless @columns
              primary_key = ActiveRecord::ConnectionAdapters::Column.new('id', nil)
              primary_key.primary = true
              @columns = [primary_key]
            end

            @columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, nil)
            class_eval "def \#{name}; v = self[:\#{name}]; (v.nil? || v.empty?) ? nil : v.#{conv}; end"
          end

          def tdbopen(readonly = false)
            self.connection.tdbopen(self.table_name, readonly) {|tdb| yield(tdb) }
          end

          def setindex(name, type)
            self.connection.setindex(self.table_name, name, type)
          end

          def proc(*args, &block)
            if block and (options = args.last) and options.kind_of?(Hash)
              options[:activetokyocabinet_proc] = block
            end

            self.find(*args)
          end
        }
      end
    end
  end
end
