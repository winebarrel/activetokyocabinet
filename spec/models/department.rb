class Department < ActiveRecord::Base
  include ActiveTokyoCabinet::TDB

  int    :deptno
  string :dname
  string :loc
end
