class Employee < ActiveRecord::Base
  include ActiveTokyoCabinet::TDB

  int    :empno
  string :ename
  string :job
  int    :mgr
  string :hiredate
  float  :sal
  float  :comm
  int    :deptno
end
