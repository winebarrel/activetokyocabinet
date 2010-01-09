$wd = File.dirname(File.expand_path(__FILE__))
ENV['RUBYLIB'] = "#{$wd}/../lib"

require 'spec_helper'
include SpecHelper
include ActiveTokyoCabinetSpec

describe 'tokyocabinet:' do
  before do
    TokyoCabinetSpec.establish_connection
    TokyoCabinetSpec.create_tables
    TokyoCabinetSpec.setup_employee
    TokyoCabinetSpec.setup_department
  end

  it 'employees length > 0' do
    employees = Employee.find(:all)
    employees.length.should == employee_data.length
  end

  it 'employees has any data (getter)' do
    employee_data.each_with_index do |data, i|
      empno, ename, job, mgr, hiredate, sal, comm, deptno = data
      employee_id = i + 1
      employee = Employee.find(employee_id)

      employee.id.should       == employee_id
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

  it 'departments length > 0' do
    departments = Department.find(:all)
    departments.length.should == department_data.length
  end

  it 'departments has any data (getter)' do
    department_data.each_with_index do |data, i|
      deptno, dname, loc = data
      department_id = i + 1
      department = Department.find(department_id)

      department.id.should     == department_id
      department.deptno.should == deptno
      department.dname.should  == dname
      department.loc.should    == loc
    end
  end

  after do
    TokyoCabinetSpec.clean
    @empty_array = nil
  end
end
