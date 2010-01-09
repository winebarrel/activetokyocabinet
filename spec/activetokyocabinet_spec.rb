$wd = File.dirname(File.expand_path(__FILE__))
ENV['RUBYLIB'] = "#{$wd}/../lib"

require 'spec_helper'
include SpecHelper
include ActiveTokyoCabinetSpec

describe 'tokyocabinet' do
  before do
    TokyoCabinetSpec.establish_connection
    TokyoCabinetSpec.create_tables
    TokyoCabinetSpec.setup_employee
    TokyoCabinetSpec.setup_department
  end

  it 'length > 0' do
    employees = Employee.find(:all)
    employees.length.should == 14
  end

  it 'any data (getter)' do
    employee_data.each_with_index do |data, i|
      empno, ename, job, mgr, hiredate, sal, comm, deptno = data
      employee_id = i + 1
      employee = Employee.find(employee_id)

      employee.empno.should    == empno
      employee.ename.should    == ename
      employee.job.should      == job
      employee.mgr.should      == mgr
      employee.hiredate.should == hiredate
      employee.sal.should      == sal
      employee.comm.should     == comm
      employee.deptno.should   == deptno
    end
  end

  after do
    TokyoCabinetSpec.clean
    @empty_array = nil
  end
end
