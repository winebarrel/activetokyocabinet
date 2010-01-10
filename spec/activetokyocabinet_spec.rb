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

  it "employees length > 0" do
    employees = Employee.find(:all)
    employees.length.should == employee_data.length
  end

  it "employees has a one data (ename = 'SMITH')" do
    employees = Employee.find(:all, :conditions => ['ename = ?', 'SMITH'])
    employees.length.should == 1
    data = employee_data.find {|i| i[EMP_ENAME] == 'SMITH' }
    validate_employee(data, employees[0])
  end

  it "employees has a one data (empno = 7521)" do
    employees = Employee.find(:all, :conditions => ['empno = ?', 7521])
    employees.length.should == 1
    data = employee_data.find {|i| i[EMP_EMPNO] == 7521 }
    validate_employee(data, employees[0])
  end

  it "employees has no data (ename = 'SMITH' and job = 'SALESMAN')" do
    employees = Employee.find(:all, :conditions => ['ename = ? and job = ?', 'SMITH', 'SALESMAN'])
    employees.should be_empty
  end

  it "employees a one data (ename = 'TURNER' and job = 'SALESMAN')" do
    employees = Employee.find(:all, :conditions => ['ename = ? and job = ?', 'TURNER', 'SALESMAN'])
    employees.length.should == 1
    data = employee_data.find {|i| i[EMP_ENAME] == 'TURNER' and i[EMP_JOB] == 'SALESMAN' }
    validate_employee(data, employees[0])
  end

  it "employees a one data ({:ename => 'TURNER', :job => 'SALESMAN'})" do
    employees = Employee.find(:all, :conditions => {:ename => 'TURNER', :job => 'SALESMAN'})
    employees.length.should == 1
    data = employee_data.find {|i| i[EMP_ENAME] == 'TURNER' and i[EMP_JOB] == 'SALESMAN' }
    validate_employee(data, employees[0])
  end

  it "employees has any data" do
    employee_data.each do |data|
      employee_id = data.id
      employee = Employee.find(employee_id)

      employee.should_not be_nil
      employee.id.should == employee_id
      validate_employee(data, employee)
    end
  end

  it "employees has any data (job = 'SALESMAN')" do
    employees = Employee.find(:all, :conditions => ['job = ?', 'SALESMAN'])

    employees.each do |employee|
      data = employee_data[employee.id - 1]

      data.should_not be_nil
      data[EMP_JOB].should == 'SALESMAN'
      validate_employee(data, employee)
    end
  end

  it "employees has any data (id=1,2,3)" do
    employees = Employee.find([1, 2, 3])
    data_list = employee_data[0..2]
    employees.length.should == data_list.length

    data_list.each do |data|
      empno, ename, job, mgr, hiredate, sal, comm, deptno = data
      employee_id = data.id
      employee = employees.find {|i| i.id == employee_id }

      employee.should_not be_nil
      employee.id.should == employee_id
      validate_employee(data, employee)
    end
  end

  it "employees has any data (order by ename desc limit 3)" do
    employees = Employee.find(:all, :order => 'ename desc', :limit => 3)
    data_list = employee_data.sort_by {|i| i[EMP_ENAME] || '' }.reverse[0..2]
    employees.length.should == data_list.length

    data_list.each do |data|
      employee = employees.find {|i| i.id == data.id }
      employee.should_not be_nil
      validate_employee(data, employee)
    end
  end

  it "employees has any data (order by ename desc limit 4 offset 5)" do
    employees = Employee.find(:all, :order => 'ename desc', :limit => 4, :offset => 5)
    data_list = employee_data.sort_by {|i| i[EMP_ENAME] || '' }.reverse[5..8]
    employees.length.should == data_list.length

    data_list.each do |data|
      employee = employees.find {|i| i.id == data.id }
      employee.should_not be_nil
      validate_employee(data, employee)
    end
  end

  it "employees has any data (ename bw 'J')" do
    employees = Employee.find(:all, :conditions => ['ename bw ?', 'J'])
    data_list = employee_data.select {|i| i[EMP_ENAME] =~ /\AJ/ }
    employees.length.should == data_list.length

    data_list.each do |data|
      employee = employees.find {|i| i.id == data.id }
      employee.should_not be_nil
      validate_employee(data, employee)
    end
  end

  it "employees has any data (ename ew 'ES')" do
    employees = Employee.find(:all, :conditions => ['ename ew ?', 'ES'])
    data_list = employee_data.select {|i| i[EMP_ENAME] =~ /ES\Z/ }
    employees.length.should == data_list.length

    data_list.each do |data|
      employee = employees.find {|i| i.id == data.id }
      employee.should_not be_nil
      validate_employee(data, employee)
    end
  end

  it "employees has any data (ename inc 'LA')" do
    employees = Employee.find(:all, :conditions => ['ename inc ?', 'LA'])
    data_list = employee_data.select {|i| i[EMP_ENAME] =~ /LA/ }
    employees.length.should == data_list.length

    data_list.each do |data|
      employee = employees.find {|i| i.id == data.id }
      employee.should_not be_nil
      validate_employee(data, employee)
    end
  end

  it "employees has any data (job incall ('ANALYST', 'MANAGER'))" do
    employees = Employee.find(:all, :conditions => ['job incall (?)', ['ANALYST', 'MANAGER']])
    data_list = employee_data.select {|i| i[EMP_JOB] =~ /ANALYST/ and i[EMP_JOB] =~ /MANAGER/ }
    employees.length.should == data_list.length

    data_list.each do |data|
      employee = employees.find {|i| i.id == data.id }
      employee.should_not be_nil
      validate_employee(data, employee)
    end
  end

  it "employees has any data (job incany ('ANALYST', 'MANAGER'))" do
    employees = Employee.find(:all, :conditions => ['job incany (?)', ['ANALYST', 'MANAGER']])
    data_list = employee_data.select {|i| i[EMP_JOB] =~ /ANALYST/ or i[EMP_JOB] =~ /MANAGER/ }
    employees.length.should == data_list.length

    data_list.each do |data|
      employee = employees.find {|i| i.id == data.id }
      employee.should_not be_nil
      validate_employee(data, employee)
    end
  end

  it "employees has any data (job in ('ANALYST', 'MANAGER'))" do
    employees = Employee.find(:all, :conditions => ['job in (?)', ['ANALYST', 'MANAGER']])
    data_list = employee_data.select {|i| i[EMP_JOB] == 'ANALYST' or i[EMP_JOB] == 'MANAGER' }
    employees.length.should == data_list.length

    data_list.each do |data|
      employee = employees.find {|i| i.id == data.id }
      employee.should_not be_nil
      validate_employee(data, employee)
    end
  end

  it "employees has any data (empno in (7934, 7935, 7936))" do
    employees = Employee.find(:all, :conditions => ['empno in (?)', [7934, 7935, 7936]])
    data_list = employee_data.select {|i| [7934, 7935, 7936].include?(i[EMP_EMPNO]) }
    employees.length.should == data_list.length

    data_list.each do |data|
      employee = employees.find {|i| i.id == data.id }
      employee.should_not be_nil
      validate_employee(data, employee)
    end
  end

  it "employees has any data (job anyone ('ANALYST', 'MANAGER'))" do
    employees = Employee.find(:all, :conditions => ['job anyone (?)', ['ANALYST', 'MANAGER']])
    data_list = employee_data.select {|i| i[EMP_JOB] == 'ANALYST' or i[EMP_JOB] == 'MANAGER' }
    employees.length.should == data_list.length

    data_list.each do |data|
      employee = employees.find {|i| i.id == data.id }
      employee.should_not be_nil
      validate_employee(data, employee)
    end
  end

  it "employees has any data (ename regexp '^J[AO].+$')" do
    employees = Employee.find(:all, :conditions => ['ename regexp ?', '^J[AO].+$'])
    data_list = employee_data.select {|i| i[EMP_ENAME] =~ /\AJ[AO].+\Z/ }
    employees.length.should == data_list.length

    data_list.each do |data|
      employee = employees.find {|i| i.id == data.id }
      employee.should_not be_nil
      validate_employee(data, employee)
    end
  end

  it "employees has any data ([])" do
    employee_data.each do |data|
      empno, ename, job, mgr, hiredate, sal, comm, deptno = data
      employee_id = data.id
      employee = Employee.find(employee_id)

      employee.should_not be_nil
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

  it "departments length > 0" do
    departments = Department.find(:all)
    departments.length.should == department_data.length
  end

  it "departments has a one data (dname = 'SALES')" do
    departments = Department.find(:all, :conditions => ['dname = ?', 'SALES'])
    departments.length.should == 1
    data = department_data.find {|i| i[DEPT_DNAME] == 'SALES' }
    validate_department(data, departments[0])
  end

  it "departments has a one data (deptno = 20)" do
    departments = Department.find(:all, :conditions => ['deptno = ?', 20])
    departments.length.should == 1
    data = department_data.find {|i| i[DEPT_DEPTNO] == 20 }
    validate_department(data, departments[0])
  end

  it "departments has no data (deptno = 20 and loc = 'BOSTON')" do
    departments = Department.find(:all, :conditions => ['deptno = ? and loc = ?', 20, 'BOSTON'])
    departments.should be_empty
  end

  it "departments has a one data (deptno = 40 and loc = 'BOSTON')" do
    departments = Department.find(:all, :conditions => ['deptno = ? and loc = ?', 40, 'BOSTON'])
    departments.length.should == 1
    data = department_data.find {|i| i[DEPT_DEPTNO] == 40 and i[DEPT_LOC] == 'BOSTON' }
    validate_department(data, departments[0])
  end

  it "departments has a one data ({:deptno => 40. :loc => 'BOSTON'})" do
    departments = Department.find(:all, :conditions => {:deptno => 40, :loc => 'BOSTON'})
    departments.length.should == 1
    data = department_data.find {|i| i[DEPT_DEPTNO] == 40 and i[DEPT_LOC] == 'BOSTON' }
    validate_department(data, departments[0])
  end

  it "departments has any data" do
    department_data.each do |data|
      department_id = data.id
      department = Department.find(department_id)

      department.should_not be_nil
      department.id.should == department_id
      validate_department(data, department)
    end
  end

  it "departments has any data ([])" do
    department_data.each do |data|
      deptno, dname, loc = data
      department_id = data.id
      department = Department.find(department_id)

      department.should_not be_nil
      department[:id].should     == department_id
      department[:deptno].should == deptno.to_s
      department[:dname].should  == dname.to_s
      department[:loc].should    == loc.to_s
    end
  end

  it "department has any data (loc in ('NEW YORK', 'CHICAGO'))" do
    departments = Department.find(:all, :conditions => ['loc in (?)', ['NEW YORK', 'CHICAGO']])

    departments.each do |department|
      data = department_data[department.id - 1]

      data.should_not be_nil
      validate_department(data, department)
    end
  end

  it "department has any data ({:loc => ['NEW YORK', 'CHICAGO']})" do
    departments = Department.find(:all, :conditions => {:loc =>  ['NEW YORK', 'CHICAGO']})

    departments.each do |department|
      data = department_data[department.id - 1]

      data.should_not be_nil
      ['NEW YORK', 'CHICAGO'].should include(data[DEPT_LOC])
      validate_department(data, department)
    end
  end

  it "departments has any data (id=1,2,3)" do
    departments = Department.find([1, 2, 3])
    data_list = department_data[0..2]
    departments.length.should == data_list.length

    data_list.each do |data|
      deptno, dname, loc = data
      department_id = data.id
      department = departments.find {|i| i.id == department_id }

      department.should_not be_nil
      validate_department(data, department)
    end
  end

  it "departments has any data (order by deptno numdesc limit 65535 offset 1)" do
    departments = Department.find(:all, :order => 'deptno numdesc', :limit => 65535, :offset => 1)
    data_list = department_data.sort_by {|i| i[DEPT_DEPTNO] || 0 }.reverse[1..-1]
    departments.length.should == data_list.length

    data_list.each do |data|
      department = departments.find {|i| i.id == data.id }
      department.should_not be_nil
      validate_department(data, department)
    end
  end

  it "departments has any data (order by deptno numasc)" do
    departments = Department.find(:all, :order => 'deptno numasc')
    data_list = department_data.sort_by {|i| i[DEPT_DEPTNO] || 0 }
    departments.length.should == data_list.length

    data_list.each do |data|
      department = departments.find {|i| i.id == data.id }
      department.should_not be_nil
      validate_department(data, department)
    end
  end

  it "departments has any data (deptno between 20 and 30)" do
    departments = Department.find(:all, :conditions => ['deptno between ? and ?', 20, 30])
    data_list = department_data.select {|i| i[DEPT_DEPTNO] and 20 <= i[DEPT_DEPTNO] and i[DEPT_DEPTNO] <= 30 }
    departments.length.should == data_list.length

    data_list.each do |data|
      department = departments.find {|i| i.id == data.id }
      department.should_not be_nil
      validate_department(data, department)
    end
  end

  it "departments has any data (deptno bt (?) [20, 30])" do
    departments = Department.find(:all, :conditions => ['deptno bt (?)', [20, 30]])
    data_list = department_data.select {|i| i[DEPT_DEPTNO] and 20 <= i[DEPT_DEPTNO] and i[DEPT_DEPTNO] <= 30 }
    departments.length.should == data_list.length

    data_list.each do |data|
      department = departments.find {|i| i.id == data.id }
      department.should_not be_nil
      validate_department(data, department)
    end
  end

  it "departments has any data (deptno bt (?, ?) [20, 30])" do
    departments = Department.find(:all, :conditions => ['deptno bt (?, ?)', 20, 30])
    data_list = department_data.select {|i| i[DEPT_DEPTNO] and 20 <= i[DEPT_DEPTNO] and i[DEPT_DEPTNO] <= 30 }
    departments.length.should == data_list.length

    data_list.each do |data|
      department = departments.find {|i| i.id == data.id }
      department.should_not be_nil
      validate_department(data, department)
    end
  end

  after do
    TokyoCabinetSpec.clean
  end
end
