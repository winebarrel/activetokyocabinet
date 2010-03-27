module ActiveTokyoCabinet
  module TDB
    def self.included(mod)
      mod.instance_eval %{
        def schema_free(options = {})
          raise 'invalid definition: schema is already defined' if @__schema_defined
          @__schema_free_defined = true

          primary_key = ActiveRecord::ConnectionAdapters::Column.new('id', nil)
          primary_key.primary = true
          @columns = [primary_key]

          class_eval <<-EOS
            @@__with_timestamp = \#{options[:timestamp].inspect}

            alias :__respond_to? :respond_to?

            def attributes_with_quotes(include_primary_key = true, include_readonly_attributes = true, attribute_names = @attributes.keys)
              quoted = {}
              connection = self.class.connection

              __attributes = (attributes || {}).merge(@__attributes || {})
              __attributes.delete('id')

              if @@__with_timestamp == :on
                %w(created_at updated_at).each {|i| __attributes.delete(i) }
              elsif @@__with_timestamp
                %w(created_on updated_on).each {|i| __attributes.delete(i) }
              else
                %w(created_on updated_on created_at updated_at).each do |i|
                  __attributes.delete(i)
                end
              end

              __attributes.each do |name, value|
                quoted[name] = connection.quote(value)
              end

              quoted
            end

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
