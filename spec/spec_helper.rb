require 'rubygems'
require 'fileutils'
require 'tokyocabinet'
require 'tokyotyrant'
require 'active_record'
require 'active_tokyocabinet/tdb'
require "#{$wd}/models/employee"
require "#{$wd}/models/department"

module SpecHelper
  def desc(klass, out = $stdout)
    rows = klass.find(:all)

    if rows.empty?
      out.puts "Empty set"
      return
    end

    cols = {}

    klass.instance_variable_get(:@columns).each do |col|
      cols[col.name] = col.name.to_s.length
    end

    rows.each do |row|
      row.attributes.each do |col, val|
        val = val.to_s
        cols[col] = val.length if val.length > cols[col]
      end
    end

    id_len = cols.delete('id')
    cols = cols.map {|k, v| [k, v] }
    cols.unshift ['id', id_len]

    line = cols.map {|col, len| '+' + '-' * (len + 2) }.join + '+'
    head = cols.map {|col, len| "| %-*s " % [len, col] }.join + '|'

    body = rows.map do |row|
      cols.map {|col, len| "| %-*s " % [len, row[col]] }.join + '|'
    end

    out.puts <<EOS
#{line}
#{head}
#{line}
#{body.join "\n"}
#{line}
EOS
  end

  def employee_data
    [
      [7369, 'SMITH' , 'CLERK'    , 7902, '17-DEC-1980',  800.0,    nil, 20],
      [7499, 'ALLEN' , 'SALESMAN' , 7698, '20-FEB-1981', 1600.0,  300.0, 30],
      [7521, 'WARD'  , 'SALESMAN' , 7698, '22-FEB-1981', 1250.0,  500.0, 30],
      [7566, 'JONES' , 'MANAGER'  , 7839, '2-APR-1981' , 2975.0,    nil, 20],
      [7654, 'MARTIN', 'SALESMAN' , 7698, '28-SEP-1981', 1250.0, 1400.0, 30],
      [7698, 'BLAKE' , 'MANAGER'  , 7839, '1-MAY-1981' , 2850.0,    nil, 30],
      [7782, 'CLARK' , 'MANAGER'  , 7839, '9-JUN-1981' , 2450.0,    nil, 10],
      [7788, 'SCOTT' , 'ANALYST'  , 7566, '09-DEC-1982', 3000.0,    nil, 20],
      [7839, 'KING'  , 'PRESIDENT',  nil, '17-NOV-1981', 5000.0,    nil, 10],
      [7844, 'TURNER', 'SALESMAN' , 7698, '8-SEP-1981' , 1500.0,    0.0, 30],
      [7876, 'ADAMS' , 'CLERK'    , 7788, '12-JAN-1983', 1100.0,    nil, 20],
      [7900, 'JAMES' , 'CLERK'    , 7698, '3-DEC-1981' ,  950.0,    nil, 30],
      [7902, 'FORD'  , 'ANALYST'  , 7566, '3-DEC-1981' , 3000.0,    nil, 20],
      [7934, 'MILLER', 'CLERK'    , 7782, '23-JAN-1982', 1300.0,    nil, 10],
    ]
  end

  def department_data
    [
      [10, 'ACCOUNTING', 'NEW YORK'],
      [20, 'RESEARCH'  , 'DALLAS'  ],
      [30, 'SALES'     , 'CHICAGO' ],
      [40, 'OPERATIONS', 'BOSTON'  ],
    ]
  end
end # SpecHelper

module ActiveTokyoCabinetSpec
  module Base
    def create_row(klass, vals)
      cols = klass.instance_variable_get(:@columns).map {|col| col.name.to_sym }
      cols.delete(:id)
      row = {}
      cols.zip(vals).each {|col, val| row[col] = val }
      klass.create!(row)
    end

    def setup_employee
      establish_connection
      employee_data.each {|row| create_row(Employee, row) }
    end

    def setup_department
      establish_connection
      department_data.each {|row| create_row(Department, row) }
    end
  end # module Base
end # module ActiveTokyoCabinetSpec

module ActiveTokyoCabinetSpec
  module TokyoCabinetSpec
    extend ActiveTokyoCabinetSpec::Base

    class << self
      def establish_connection
        ActiveRecord::Base.establish_connection(
          :adapter  => 'tokyocabinet',
          :database => $wd
        )
      end

      def tctmgr_create(path)
        `tctmgr create #{path}`
      end

      def create_tables
        tctmgr_create "#{$wd}/employees.tct"
        tctmgr_create "#{$wd}/departments.tct"
      end

      def clean
        FileUtils.rm_f "#{$wd}/employees.tct"
        FileUtils.rm_f "#{$wd}/departments.tct"
      end
    end # class << self
  end # module TokyoCabinetSpec
end # module ActiveTokyoCabinetSpec
