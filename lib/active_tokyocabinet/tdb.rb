module ActiveTokyoCabinet
  module TDB
    def self.included(mod)
      mod.instance_eval %{
        def schema_free
          raise 'invalid definition: schema is already defined' if @__schema_defined
          @__schema_free_defined = true
          @columns = []

          class_eval <<-EOS
            alias :__respond_to? :respond_to?

            def respond_to?(name, priv = false); true; end

            def method_missing(name, *args, &block)
              @__attributes ||= {}
              name = name.to_s

              if __respond_to?(name)
                super
              elsif name =~ /\\\\A(.+)=\\\\Z/ and args.length == 1
                @__attributes[$1] = args[0]
              elsif name =~ /[^=]\\\\Z/ and args.length == 0
                @__attributes[$1]
              else
                raise NoMethodError, "undefined method `\\\#{name}' for \#{name}"
                super
              end
            end
          EOS
        end
      }

      mod.instance_eval %{
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

      {:string => :to_s, :int => :to_i, :float => :to_f}.each do |type, conv|
        mod.instance_eval %{
          def #{type}(name)
            raise 'invalid definition: schema_free is already defined' if @__schema_free_defined
            @__schema_defined = true

            unless @columns
              primary_key = ActiveRecord::ConnectionAdapters::Column.new('id', nil)
              primary_key.primary = true
              @columns = [primary_key]
            end

            @columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, nil)
            class_eval "def \#{name}; v = self[:\#{name}]; (v.nil? || v.empty?) ? nil : v.#{conv}; end"
          end
        }
      end
    end
  end
end
