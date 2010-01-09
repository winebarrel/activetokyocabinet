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

    rows.first.attributes.keys.each do |col, val|
      col = col.to_s
      val = val.to_s
      len = col.length > val.length ? col.length : val.length
      cols[col] = len
    end

    rows.each do |row|
      row.attributes.each do |col, val|
        val = val.to_s
        cols[col] = val.length if val.length > cols[col]
      end
    end

    line = cols.map {|col, len| '+' + '-' * len }.join + '+'
    head = cols.map {|col, len| "|%-*s" % [len, col] }.join + '|'

    body = rows.map do |row|
      cols.map {|col, len| "|%-*s" % [len, row[col]] }.join + '|'
    end

    out.puts <<EOS
#{line}
#{head}
#{line}
#{body.join "\n"}
#{line}
EOS
  end
end # SpecHelper

module ActiveTokyoCabinetSpec
  module Base
    def create_row(klass, cols, vals)
      row = {}
      cols.zip(vals).each {|col, val| row[col] = val }
      Employee.create!(row)
    end

    def setup_employee_data
      establish_connection

      data = [
        [7369, 'SMITH', 'CLERK',  7902, '17-DEC-1980', 800.0, nil, 20],
      ]

      data.each do |row|
        create_row(Employee, [:empno, :ename, :job, :mgr, :hiredate, :sal, :comm, :deptno], row)
      end
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
