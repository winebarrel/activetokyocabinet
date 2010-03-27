$wd = File.dirname(File.expand_path(__FILE__))
ENV['RUBYLIB'] = "#{$wd}/../lib"

require 'spec_helper'
include SpecHelper
include ActiveTokyoCabinetSpec

describe 'tokyotyrant:' do
  before do
     TokyoTyrantSpec.establish_connection
     TokyoTyrantSpec.create_tables
     TokyoTyrantSpec.setup_employee
     TokyoTyrantSpec.setup_department
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
    employees.should_not be_empty

    employees.each do |employee|
      data = employee_data[employee.id - 1]

      data.should_not be_nil
      data[EMP_JOB].should == 'SALESMAN'
      validate_employee(data, employee)
    end
  end

  it "employees has any data (id=1,2,3)" do
    employees = Employee.find([1, 2, 3])
    employees.should_not be_empty
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
    employees.should_not be_empty
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
    employees.should_not be_empty
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
    employees.should_not be_empty
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
    employees.should_not be_empty
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
    employees.should_not be_empty
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
    employees.should_not be_empty
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
    employees.should_not be_empty
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
    employees.should_not be_empty
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
    employees.should_not be_empty
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
    employees.should_not be_empty
    data_list = employee_data.select {|i| i[EMP_ENAME] =~ /\AJ[AO].+\Z/ }
    employees.length.should == data_list.length

    data_list.each do |data|
      employee = employees.find {|i| i.id == data.id }
      employee.should_not be_nil
      validate_employee(data, employee)
    end
  end

  it "employees has any data (ename fts 'MI')" do
    employees = Employee.find(:all, :conditions => ['ename fts ?', 'MI'])
    employees.should_not be_empty
    data_list = employee_data.select {|i| i[EMP_ENAME] =~ /MI/ }
    employees.length.should == data_list.length

    data_list.each do |data|
      employee = employees.find {|i| i.id == data.id }
      employee.should_not be_nil
      validate_employee(data, employee)
    end
  end

  it "employees has any data (ename ftsand 'HATSUNE MIKU')" do
    # XXX:
    employees = Employee.find(:all, :conditions => ['ename ftsand ?', 'HATSUNE MIKU'])
    employees = Employee.find(:all, :conditions => ['ename ftsand (?)', ['HATSUNE', 'MIKU']])
  end

  it "employees has any data (hiredate ftsor '1983 DEC')" do
    # XXX:
    employees = Employee.find(:all, :conditions => ['hiredate ftsor ?', '1983 DEC'])
    employees = Employee.find(:all, :conditions => ['hiredate ftsor (?)', ['1983', 'DEC']])
  end

  it "employees has any data (ename ftsex 'MIKU || RIN')" do
    employees = Employee.find(:all, :conditions => ['ename ftsex ?', 'MIKU || RIN'])
    employees.should_not be_empty
    data_list = employee_data.select {|i| i[EMP_ENAME] =~ /MIKU/ or i[EMP_ENAME] =~ /RIN/ }
    employees.length.should == data_list.length

    data_list.each do |data|
      employee = employees.find {|i| i.id == data.id }
      employee.should_not be_nil
      validate_employee(data, employee)
    end
  end

  it "employees has any data (ename ftsex 'HATSUNE && MIKU')" do
    employees = Employee.find(:all, :conditions => ['ename ftsex ?', 'HATSUNE && MIKU'])
    employees.should_not be_empty
    data_list = employee_data.select {|i| i[EMP_ENAME] =~ /HATSUNE/ and i[EMP_ENAME] =~ /MIKU/ }
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
    departments.should_not be_empty

    departments.each do |department|
      data = department_data[department.id - 1]

      data.should_not be_nil
      validate_department(data, department)
    end
  end

  it "department has any data ({:loc => ['NEW YORK', 'CHICAGO']})" do
    departments = Department.find(:all, :conditions => {:loc =>  ['NEW YORK', 'CHICAGO']})
    departments.should_not be_empty

    departments.each do |department|
      data = department_data[department.id - 1]

      data.should_not be_nil
      ['NEW YORK', 'CHICAGO'].should include(data[DEPT_LOC])
      validate_department(data, department)
    end
  end

  it "departments has any data (id=1,2,3)" do
    departments = Department.find([1, 2, 3])
    departments.should_not be_empty
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
    departments.should_not be_empty
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
    departments.should_not be_empty
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
    departments.should_not be_empty
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
    departments.should_not be_empty
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
    departments.should_not be_empty
    data_list = department_data.select {|i| i[DEPT_DEPTNO] and 20 <= i[DEPT_DEPTNO] and i[DEPT_DEPTNO] <= 30 }
    departments.length.should == data_list.length

    data_list.each do |data|
      department = departments.find {|i| i.id == data.id }
      department.should_not be_nil
      validate_department(data, department)
    end
  end

  it "destroy employee" do
    Employee.count.should == 17
    employee = Employee.find(:first, :conditions => {:ename => 'KING'})
    employee_id = employee.id
    Employee.find(employee_id).should_not be_nil
    employee.destroy
    Employee.count.should == 16
    Employee.find_by_id(employee_id).should be_nil
  end

  it "destroy all employee" do
    Employee.count.should == 17
    Employee.destroy_all
    Employee.count.should == 0
  end

  it "delete department" do
    Department.count.should == 5
    department = Department.find(:first, :conditions => {:dname => 'SALES'})
    department_id = department.id
    Department.find(department_id).should_not be_nil
    department.delete
    Department.count.should == 4
    Department.find_by_id(department_id).should be_nil
  end

  it "delete all department" do
    Department.count.should == 5
    Department.delete_all
    Department.count.should == 0
  end

  it "schema free" do
    Book.create(:foo => 'bar', :zoo => 'baz', :n => 100)
    Book.create!(:hoge => 'fuga', :n => 200)

    book = Book.new
    book.xxx = 'XXX'
    book.yyy = 'YYY'
    book.zzz = 'ZZZ'
    book.n = 300
    book.save!

    Book.count.should == 3

    book = Book.find(2)
    book.foo.should be_nil
    book.hoge.should == 'fuga'
    book.n.should == '200'

    book.n = 250
    book.save

    books = Book.find(:all, :conditions => ['hoge = ?', 'fuga'])
    books.length.should == 1
    books[0].xxx.should be_nil
    books[0].hoge.should == 'fuga'
    books[0].n.should == '250'

    books = Book.find(:all, :conditions => ['n >= ?', 200])
    books.length.should == 2
    books = books.sort_by {|i| i.id }
 
    books[0].id.should == 2
    books[0].hoge.should == 'fuga'
    books[0].n.should == '250'

    books[1].id.should == 3
    books[1].xxx.should == 'XXX'
    books[1].yyy.should == 'YYY'
    books[1].zzz.should == 'ZZZ'
    books[1].n.should == '300'

    Book.update_all("xxx = 'xxx'", ['n > ?', 100])

    books = Book.find(:all)
    books.length.should == 3
    books = books.sort_by {|i| i.id }

    books[0].id.should == 1
    books[0].xxx.should be_nil

    books[1].id.should == 2
    books[1].xxx.should == 'xxx'

    books[2].id.should == 3
    books[2].xxx.should == 'xxx'

    Book.find(2).destroy

    books = Book.find(:all)
    books.length.should == 2
    books = books.sort_by {|i| i.id }

    books[0].id.should == 1
    books[1].id.should == 3

    Book.delete_all
    Book.count.should == 0
  end

  after do
     TokyoTyrantSpec.clean
  end
end
