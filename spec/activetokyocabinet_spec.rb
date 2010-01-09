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

  it "employees has a one data (ename = 'SMITH')" do
    employees = Employee.find(:all, :conditions => ['ename = ?', 'SMITH'])
    employees.length.should == 1
    data = employee_data.find {|i| i[EMP_ENAME] == 'SMITH' }
    validate_employee(data, employees[0])
  end

  it 'employees has any data' do
    employee_data.each_with_index do |data, i|
      employee_id = i + 1
      employee = Employee.find(employee_id)

      employee.id.should == employee_id
      validate_employee(data, employee)
    end
  end

  it 'employees has any data (id=1,2,3)' do
    employees = Employee.find([1, 2, 3])
    employees.length.should == 3

    employee_data[0..2].each_with_index do |data, i|
      empno, ename, job, mgr, hiredate, sal, comm, deptno = data
      employee_id = i + 1
      employee = employees.find {|i| i.id == employee_id }

      employee.should_not be_nil
      employee.id.should == employee_id
      validate_employee(data, employee)
    end
  end

  it 'employees has any data ([])' do
    employee_data.each_with_index do |data, i|
      empno, ename, job, mgr, hiredate, sal, comm, deptno = data
      employee_id = i + 1
      employee = Employee.find(employee_id)

      employee[:id].should       == employee_id
      employee[:empno].should    == empno.to_s
      employee[:ename].should    == ename.to_s
      employee[:job].should      == job.to_s
      employee[:mgr].should      == mgr.to_s
      employee[:hiredate].should == hiredate.to_s
      employee[:sal].should      == sal.to_s
      employee[:comm].should     == comm.to_s
      employee[:deptno].should   == deptno.to_s
    end
  end

  # -------------------------------------------------------------------

  it 'departments length > 0' do
    departments = Department.find(:all)
    departments.length.should == department_data.length
  end

  it "departments has a one data (dname = 'SALES')" do
    departments = Department.find(:all, :conditions => ['dname = ?', 'SALES'])
    departments.length.should == 1
    data = department_data.find {|i| i[DEPT_DNAME] == 'SALES' }
    validate_department(data, departments[0])
  end

  it 'departments has any data' do
    department_data.each_with_index do |data, i|
      department_id = i + 1
      department = Department.find(department_id)

      department.id.should == department_id
      validate_department(data, department)
    end
  end

  it 'departments has any data' do
    department_data.each_with_index do |data, i|
      department_id = i + 1
      department = Department.find(department_id)

      department.id.should == department_id
      validate_department(data, department)
    end
  end

  it 'departments has any data (id=1,2,3)' do
    departments = Department.find([1, 2, 3])
    departments.length.should == 3

    department_data[0..2].each_with_index do |data, i|
      deptno, dname, loc = data
      department_id = i + 1
      department = departments.find {|i| i.id == department_id }

      department.should_not be_nil
      department[:id].should     == department_id
      department[:deptno].should == deptno.to_s
      department[:dname].should  == dname.to_s
      department[:loc].should    == loc.to_s
    end
  end

  after do
    TokyoCabinetSpec.clean
  end
end
