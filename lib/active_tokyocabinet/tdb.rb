module ActiveTokyoCabinet
  module TDB
    def self.included(mod)
      {:string => :to_s, :int => :to_i, :float => :to_s}.each do |type, conv|
        mod.instance_eval %{
          def #{type}(name)
            unless @columns
              primary_key = ActiveRecord::ConnectionAdapters::Column.new('id', nil)
              primary_key.primary = true
              @columns = [primary_key]
            end

            @columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, nil)
            class_eval "def \#{name}; v = self[:\#{name}]; v && v.#{conv}; end"
          end
        }
      end
    end
  end
end