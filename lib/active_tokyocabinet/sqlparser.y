class SQLParser
options no_result_var
rule
  sql                   : create_statement
                        | read_statemant
                        | update_statemant
                        | delete_statemant

  create_statement      : INSERT INTO id '(' id_list ')' VALUES '(' value_list ')'
                          {
                            {:command => :insert, :table => val[2], :column_list => val[4], :value_list => val[8]}
                          }

  read_statemant        : SELECT select_list FROM id where_clause order_by_clause limit_clause offset_clause
                          {
                            {:command => :select, :table => val[3], :select_list => val[1], :condition => val[4], :order => val[5], :limit => val[6], :offset => val[7]}
                          }
                        | SELECT count_clause FROM id where_clause order_by_clause limit_clause offset_clause
                          {
                            {:command => :select, :table => val[3], :count => val[1], :condition => val[4]}
                          }

  count_clause          : COUNT '(' count_arg ')'
                          {
                            "count_all"
                          }
                        | COUNT '(' count_arg ')' AS id
                          {
                            val[5]
                          }

  count_arg             : '*'
                        | id

  select_list           : '*'
                          {
                            []
                          }
                        | id_list

  where_clause          :
                          {
                            []
                          }
                        | WHERE id_search_condition
                          {
                            val[1]
                          }
                        | WHERE search_condition
                          {
                            val[1]
                          }

  id_search_condition   : id_predicate
                        | '(' id_predicate ')'
                          {
                            val[1]
                          }

  id_predicate          : ID '=' value
                          {
                            val[2]
                          }
                        |  ID IN '(' value_list ')'
                          {
                            val[3]
                          }

  search_condition      : boolean_primary
                          {
                            [val[0]].flatten
                          }
                        | search_condition AND boolean_primary
                          {
                            (val[0] << val[2]).flatten
                          }

  boolean_primary       : predicate
                        | '(' search_condition ')'
                          {
                            val[1]
                          }

  predicate             : id op value
                          {
                            {:name => val[0], :op => tccond(val[1], val[2]), :expr => val[2]}
                          }
                        | id op '(' value_list ')'
                          {
                            {:name => val[0], :op => tccond(val[1], val[3]), :expr => val[3]}
                          }
  order_by_clause       :
                          {
                            nil
                          }
                        | ORDER BY id ordering_spec
                          {
                            {:name => val[2], :type => val[3]}
                          }

  ordering_spec         :
                          {
                            :QOSTRASC
                          }
                        | ORDER

  limit_clause          :
                          {
                            nil
                          }
                        | LIMIT NUMBER
                          {
                            val[1]
                          }

  offset_clause          :
                          {
                            nil
                          }
                        | OFFSET NUMBER
                          {
                            val[1]
                          }

  update_statemant      : UPDATE id SET set_clause_list where_clause
                          {
                            {:command => :update, :table => val[1], :set_clause_list => val[3], :condition => val[4]}
                          }

  set_clause_list       : set_clause
                        | set_clause_list ',' set_clause
                          {
                            val[0].merge val[2]
                          }

  set_clause            : id '=' value
                        {
                          {val[0] => val[2]}
                        }

  delete_statemant      : DELETE FROM id where_clause
                          {
                            {:command => :delete, :table => val[2], :condition => val[3]}
                          }

  id                    : IDENTIFIER

  id_list               : id
                          {
                            [val[0]]
                          }
                        | id_list ',' id
                          {
                            val[0] << val[2]
                          }

  value                 : STRING
                        | NUMBER
                        | NULL

  value_list            : value
                          {
                            [val[0]]
                          }
                        | value_list ',' value
                          {
                            val[0] << val[2]
                          }

  op                    : BW
                        | EW
                        | INCALL
                        | INCANY
                        | INC
                        | IN
                        | EQANY
                        | REGEXP
                        | BETWEEN
                        | FTS
                        | FTSALL
                        | FTSANY
                        | FTSEX
                        | '>='
                        | '<='
                        | '>'
                        | '<'
                        | '='

end

---- header

require 'strscan'

module ActiveTokyoCabinet

---- inner

def initialize(obj)
  src = obj.is_a?(IO) ? obj.read : obj.to_s
  @ss = StringScanner.new(src)
end

def scan
  piece = nil

  until @ss.eos?
    if (tok = @ss.scan /\s+/)
      # nothing to do
    elsif (tok = @ss.scan /(?:BW|EW|INCALL|INCANY|INC|IN|EQANY|REGEXP|BETWEEN|FTS|FTSALL|FTSANY|FTSEX)\b/i)
      yield tok.upcase.to_sym, tok
    elsif (tok = @ss.scan /(?:>=|<=|>|<|=)/)
      yield tok, tok
    elsif (tok = @ss.scan /(?:INSERT|INTO|VALUES|SELECT|FROM|WHERE|AND|UPDATE|SET|DELETE|COUNT|ORDER|BY|LIMIT|OFFSET|AS)\b/i)
      yield tok.upcase.to_sym, tok
    elsif (tok = @ss.scan /(?:ASC|DESC|STRASC|STRDESC|NUMASC|NUMDESC)\b/i)
      yield :ORDER, tcordertype(tok)
    elsif (tok = @ss.scan /NULL\b/i)
      yield :NULL, nil
    elsif (tok = @ss.scan /'(?:[^']|'')*'/) #'
      yield :STRING, tok.slice(1...-1).gsub(/''/, "'")
    elsif (tok = @ss.scan /-?(?:0|[1-9]\d*)(?:\.\d+)/)
      yield :NUMBER, tok.to_f
    elsif (tok = @ss.scan /-?(?:0|[1-9]\d*)/)
      yield :NUMBER, tok.to_i
    elsif (tok = @ss.scan /[,\(\)\*]/)
      yield tok, tok
    elsif (tok = @ss.scan /(?:[a-z_][\w]+\.)*ID\b/i)
      yield :ID, tok
    elsif (tok = @ss.scan /(?:[a-z_][\w]+\.)*[a-z_][\w]+/i)
      yield :IDENTIFIER, tok
    else
      raise Racc::ParseError, ('parse error on value "%s"' % @ss.rest.inspect)
    end
  end

  yield false, '$'
end
private :scan

def parse
  yyparse self, :scan
end

def tccond(op, expr)
  case op.upcase
  when '='
    expr.kind_of?(Numeric) ? :QCNUMEQ : :QCSTREQ
  when 'INC'
    :QCSTRINC
  when 'BW'
    :QCSTRBW
  when 'EW'
    :QCSTREW
  when 'INCALL'
    :QCSTRAND
  when 'INCANY'
    :QCSTROR
  when 'IN', 'EQANY'
    expr.all? {|i| i.kind_of?(Numeric) } ? :QCNUMOREQ : :QCSTROREQ
  when 'REGEXP'
    :QCSTRRX
  when '>'
    :QCNUMGT
  when '>='
    :QCNUMGE
  when '<'
    :QCNUMLT
  when '<='
    :QCNUMLE
  when 'BETWEEN'
    :QCNUMBT
  when 'FTS'
    :QCFTSPH
  when 'FTSALL'
    :QCFTSAND
  when 'FTSANY'
    :QCFTSOR
  when 'FTSEX'
    :QCFTSEX
  else
    raise 'must not happen'
  end
end
private :tccond

def tcordertype(type)
  case type.upcase
  when 'ASC', 'STRASC'
    :QOSTRASC
  when 'DESC', 'STRASC'
    :QOSTRASC
  when 'NUMASC'
    :QONUMASC
  when 'NUMDESC'
    :QONUMDESC
  else
    raise 'must not happen'
  end
end
private :tcordertype

---- footer

end # module ActiveTokyoCabinet
