class Book < ActiveRecord::Base
  include ActiveTokyoCabinet::TDB
  schema_free
end
