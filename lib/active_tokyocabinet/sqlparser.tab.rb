#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.6
# from Racc grammer file "".
#

require 'racc/parser.rb'


require 'strscan'

module ActiveTokyoCabinet

class SQLParser < Racc::Parser

module_eval(<<'...end sqlparser.y/module_eval...', 'sqlparser.y', 198)

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
  when 'DESC', 'STRDESC'
    :QOSTRDESC
  when 'NUMASC'
    :QONUMASC
  when 'NUMDESC'
    :QONUMDESC
  else
    raise 'must not happen'
  end
end
private :tcordertype

...end sqlparser.y/module_eval...
##### State transition tables begin ###

racc_action_table = [
    72,    75,    34,    62,    63,    26,    10,    10,    34,    54,
    64,    34,    64,    10,    42,    79,    81,    83,    85,    68,
    69,    71,    73,    74,    76,    77,    78,    80,    82,    84,
    67,    96,    10,     2,    10,    47,    64,    37,     9,    94,
    61,   120,   116,   115,    46,    46,    19,    59,    15,    10,
    86,    34,    10,     1,    57,    58,     4,    10,    10,    26,
   114,   114,   114,    10,    59,    10,    59,    32,    59,    10,
    59,    57,    58,    57,    58,    57,    58,    57,    58,    59,
    86,    59,    88,    89,    88,    91,    57,    58,    57,    58,
    28,    93,    27,    43,    95,    25,    10,   100,   101,    23,
   100,   104,    10,    21,   109,   110,    10,   109,    14,    13,
    12,   117,   119,    10,    10 ]

racc_action_check = [
    49,    49,    29,    46,    46,    18,    32,    26,    35,    38,
    64,    40,    86,    42,    29,    49,    49,    49,    49,    49,
    49,    49,    49,    49,    49,    49,    49,    49,    49,    49,
    49,    70,    64,     0,    86,    34,    47,    27,     0,    65,
    44,   113,   107,   106,    34,    47,     9,    70,     9,    25,
    65,    24,    27,     0,    70,    70,     0,    34,    47,    44,
   113,   107,   106,     9,    96,    28,    93,    22,    43,    21,
   104,    96,    96,    93,    93,    43,    43,   104,   104,    62,
    50,   114,    53,    54,    55,    61,    62,    62,   114,   114,
    20,    63,    19,    31,    66,    16,    14,    87,    88,    13,
    90,    91,    12,    11,    99,   100,   101,   103,     4,     3,
     2,   109,   111,     1,    89 ]

racc_action_pointer = [
    31,    87,   107,   109,   100,   nil,   nil,   nil,   nil,    37,
   nil,    80,    76,    99,    70,   nil,    87,   nil,   -19,    88,
    82,    43,    63,   nil,    39,    23,   -19,    26,    39,   -10,
   nil,    79,   -20,   nil,    31,    -4,   nil,   nil,     4,   nil,
    -1,   nil,   -13,    48,    35,   nil,   -11,    32,   nil,   -14,
    64,   nil,   nil,    65,    73,    67,   nil,   nil,   nil,   nil,
   nil,    79,    59,    87,     6,    34,    89,   nil,   nil,   nil,
    27,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,     8,    78,    80,    88,
    81,    97,   nil,    46,   nil,   nil,    44,   nil,   nil,    83,
    85,    80,   nil,    86,    50,   nil,    38,    37,   nil,    91,
   nil,    95,   nil,    36,    61,   nil,   nil,   nil,   nil,   nil,
   nil,   nil ]

racc_action_default = [
   -66,   -66,   -66,   -66,   -66,    -1,    -2,    -3,    -4,   -66,
   -40,   -66,   -66,   -66,   -66,   -12,   -66,   -41,   -13,   -66,
   -66,   -66,   -66,   122,   -14,   -66,   -66,   -66,   -66,   -14,
   -36,   -66,   -66,   -39,   -66,   -14,   -42,   -10,   -66,   -11,
   -14,   -35,   -66,   -66,   -66,   -23,   -66,   -66,   -15,   -66,
   -16,   -17,   -21,   -27,    -8,   -27,   -37,   -43,   -45,   -44,
   -38,   -66,   -66,   -66,   -66,   -66,   -66,   -64,   -52,   -54,
   -66,   -55,   -65,   -56,   -57,   -53,   -58,   -59,   -60,   -48,
   -61,   -49,   -62,   -50,   -63,   -51,   -66,   -31,   -66,   -66,
   -31,   -66,   -19,   -66,   -24,   -18,   -66,   -25,   -22,   -33,
   -66,   -66,    -9,   -33,   -66,   -46,   -66,   -66,    -7,   -66,
   -32,   -29,    -6,   -66,   -66,   -20,   -26,   -34,   -28,   -30,
    -5,   -47 ]

racc_goto_table = [
    11,    30,    60,    51,    50,    18,   106,    33,    17,   107,
   108,    22,    41,    24,   112,     8,    66,   113,    53,     7,
    31,    92,    56,    55,    35,    36,    39,    40,    44,    97,
    99,    17,    87,   103,    90,    16,    38,    48,    20,     6,
     5,    31,    98,    70,   118,    29,     3,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   121,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   102,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   111 ]

racc_goto_check = [
     6,    25,    19,    18,    17,     7,     8,    10,     6,     8,
    13,     6,    10,     6,    13,     5,    18,     8,    10,     4,
     6,    19,    25,    10,     6,     6,     6,     6,     7,    19,
    12,     6,    11,    12,    11,    14,    15,    16,     9,     3,
     2,     6,    20,    22,    23,    24,     1,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,    19,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,     6,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
     6 ]

racc_goto_pointer = [
   nil,    46,    40,    39,    19,    15,    -1,    -4,   -87,    29,
   -17,   -21,   -57,   -89,    26,     9,     3,   -30,   -31,   -41,
   -44,   nil,    -6,   -67,    24,   -20 ]

racc_goto_default = [
   nil,   nil,   nil,   nil,   nil,   nil,    49,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,    65,   nil,   105,
    52,    45,   nil,   nil,   nil,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  1, 46, :_reduce_none,
  1, 46, :_reduce_none,
  1, 46, :_reduce_none,
  1, 46, :_reduce_none,
  10, 47, :_reduce_5,
  8, 48, :_reduce_6,
  8, 48, :_reduce_7,
  4, 59, :_reduce_8,
  6, 59, :_reduce_9,
  1, 60, :_reduce_none,
  1, 60, :_reduce_none,
  1, 54, :_reduce_12,
  1, 54, :_reduce_none,
  0, 55, :_reduce_14,
  2, 55, :_reduce_15,
  2, 55, :_reduce_16,
  1, 61, :_reduce_none,
  3, 61, :_reduce_18,
  3, 63, :_reduce_19,
  5, 63, :_reduce_20,
  1, 62, :_reduce_21,
  3, 62, :_reduce_22,
  1, 65, :_reduce_none,
  3, 65, :_reduce_24,
  3, 66, :_reduce_25,
  5, 66, :_reduce_26,
  0, 56, :_reduce_27,
  4, 56, :_reduce_28,
  0, 68, :_reduce_29,
  1, 68, :_reduce_none,
  0, 57, :_reduce_31,
  2, 57, :_reduce_32,
  0, 58, :_reduce_33,
  2, 58, :_reduce_34,
  5, 49, :_reduce_35,
  1, 69, :_reduce_none,
  3, 69, :_reduce_37,
  3, 70, :_reduce_38,
  4, 50, :_reduce_39,
  1, 51, :_reduce_none,
  1, 52, :_reduce_41,
  3, 52, :_reduce_42,
  1, 64, :_reduce_none,
  1, 64, :_reduce_none,
  1, 64, :_reduce_none,
  1, 53, :_reduce_46,
  3, 53, :_reduce_47,
  1, 67, :_reduce_none,
  1, 67, :_reduce_none,
  1, 67, :_reduce_none,
  1, 67, :_reduce_none,
  1, 67, :_reduce_none,
  1, 67, :_reduce_none,
  1, 67, :_reduce_none,
  1, 67, :_reduce_none,
  1, 67, :_reduce_none,
  1, 67, :_reduce_none,
  1, 67, :_reduce_none,
  1, 67, :_reduce_none,
  1, 67, :_reduce_none,
  1, 67, :_reduce_none,
  1, 67, :_reduce_none,
  1, 67, :_reduce_none,
  1, 67, :_reduce_none,
  1, 67, :_reduce_none ]

racc_reduce_n = 66

racc_shift_n = 122

racc_token_table = {
  false => 0,
  :error => 1,
  :INSERT => 2,
  :INTO => 3,
  "(" => 4,
  ")" => 5,
  :VALUES => 6,
  :SELECT => 7,
  :FROM => 8,
  :COUNT => 9,
  :AS => 10,
  "*" => 11,
  :WHERE => 12,
  :ID => 13,
  "=" => 14,
  :IN => 15,
  :AND => 16,
  :ORDER => 17,
  :BY => 18,
  :LIMIT => 19,
  :NUMBER => 20,
  :OFFSET => 21,
  :UPDATE => 22,
  :SET => 23,
  "," => 24,
  :DELETE => 25,
  :IDENTIFIER => 26,
  :STRING => 27,
  :NULL => 28,
  :BW => 29,
  :EW => 30,
  :INCALL => 31,
  :INCANY => 32,
  :INC => 33,
  :EQANY => 34,
  :REGEXP => 35,
  :BETWEEN => 36,
  :FTS => 37,
  :FTSALL => 38,
  :FTSANY => 39,
  :FTSEX => 40,
  ">=" => 41,
  "<=" => 42,
  ">" => 43,
  "<" => 44 }

racc_nt_base = 45

racc_use_result_var = false

Racc_arg = [
  racc_action_table,
  racc_action_check,
  racc_action_default,
  racc_action_pointer,
  racc_goto_table,
  racc_goto_check,
  racc_goto_default,
  racc_goto_pointer,
  racc_nt_base,
  racc_reduce_table,
  racc_token_table,
  racc_shift_n,
  racc_reduce_n,
  racc_use_result_var ]

Racc_token_to_s_table = [
  "$end",
  "error",
  "INSERT",
  "INTO",
  "\"(\"",
  "\")\"",
  "VALUES",
  "SELECT",
  "FROM",
  "COUNT",
  "AS",
  "\"*\"",
  "WHERE",
  "ID",
  "\"=\"",
  "IN",
  "AND",
  "ORDER",
  "BY",
  "LIMIT",
  "NUMBER",
  "OFFSET",
  "UPDATE",
  "SET",
  "\",\"",
  "DELETE",
  "IDENTIFIER",
  "STRING",
  "NULL",
  "BW",
  "EW",
  "INCALL",
  "INCANY",
  "INC",
  "EQANY",
  "REGEXP",
  "BETWEEN",
  "FTS",
  "FTSALL",
  "FTSANY",
  "FTSEX",
  "\">=\"",
  "\"<=\"",
  "\">\"",
  "\"<\"",
  "$start",
  "sql",
  "create_statement",
  "read_statemant",
  "update_statemant",
  "delete_statemant",
  "id",
  "id_list",
  "value_list",
  "select_list",
  "where_clause",
  "order_by_clause",
  "limit_clause",
  "offset_clause",
  "count_clause",
  "count_arg",
  "id_search_condition",
  "search_condition",
  "id_predicate",
  "value",
  "boolean_primary",
  "predicate",
  "op",
  "ordering_spec",
  "set_clause_list",
  "set_clause" ]

Racc_debug_parser = false

##### State transition tables end #####

# reduce 0 omitted

# reduce 1 omitted

# reduce 2 omitted

# reduce 3 omitted

# reduce 4 omitted

module_eval(<<'.,.,', 'sqlparser.y', 10)
  def _reduce_5(val, _values)
                                {:command => :insert, :table => val[2], :column_list => val[4], :value_list => val[8]}
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 15)
  def _reduce_6(val, _values)
                                {:command => :select, :table => val[3], :select_list => val[1], :condition => val[4], :order => val[5], :limit => val[6], :offset => val[7]}
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 19)
  def _reduce_7(val, _values)
                                {:command => :select, :table => val[3], :count => val[1], :condition => val[4]}
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 24)
  def _reduce_8(val, _values)
                                "count_all"
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 28)
  def _reduce_9(val, _values)
                                val[5]
                          
  end
.,.,

# reduce 10 omitted

# reduce 11 omitted

module_eval(<<'.,.,', 'sqlparser.y', 36)
  def _reduce_12(val, _values)
                                []
                          
  end
.,.,

# reduce 13 omitted

module_eval(<<'.,.,', 'sqlparser.y', 42)
  def _reduce_14(val, _values)
                                []
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 46)
  def _reduce_15(val, _values)
                                val[1]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 50)
  def _reduce_16(val, _values)
                                val[1]
                          
  end
.,.,

# reduce 17 omitted

module_eval(<<'.,.,', 'sqlparser.y', 56)
  def _reduce_18(val, _values)
                                val[1]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 61)
  def _reduce_19(val, _values)
                                val[2]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 65)
  def _reduce_20(val, _values)
                                val[3]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 70)
  def _reduce_21(val, _values)
                                [val[0]].flatten
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 74)
  def _reduce_22(val, _values)
                                (val[0] << val[2]).flatten
                          
  end
.,.,

# reduce 23 omitted

module_eval(<<'.,.,', 'sqlparser.y', 80)
  def _reduce_24(val, _values)
                                val[1]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 85)
  def _reduce_25(val, _values)
                                {:name => val[0], :op => tccond(val[1], val[2]), :expr => val[2]}
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 89)
  def _reduce_26(val, _values)
                                {:name => val[0], :op => tccond(val[1], val[3]), :expr => val[3]}
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 93)
  def _reduce_27(val, _values)
                                nil
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 97)
  def _reduce_28(val, _values)
                                {:name => val[2], :type => val[3]}
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 102)
  def _reduce_29(val, _values)
                                :QOSTRASC
                          
  end
.,.,

# reduce 30 omitted

module_eval(<<'.,.,', 'sqlparser.y', 108)
  def _reduce_31(val, _values)
                                nil
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 112)
  def _reduce_32(val, _values)
                                val[1]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 117)
  def _reduce_33(val, _values)
                                nil
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 121)
  def _reduce_34(val, _values)
                                val[1]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 126)
  def _reduce_35(val, _values)
                                {:command => :update, :table => val[1], :set_clause_list => val[3], :condition => val[4]}
                          
  end
.,.,

# reduce 36 omitted

module_eval(<<'.,.,', 'sqlparser.y', 132)
  def _reduce_37(val, _values)
                                val[0].merge val[2]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 137)
  def _reduce_38(val, _values)
                              {val[0] => val[2]}
                        
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 142)
  def _reduce_39(val, _values)
                                {:command => :delete, :table => val[2], :condition => val[3]}
                          
  end
.,.,

# reduce 40 omitted

module_eval(<<'.,.,', 'sqlparser.y', 149)
  def _reduce_41(val, _values)
                                [val[0]]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 153)
  def _reduce_42(val, _values)
                                val[0] << val[2]
                          
  end
.,.,

# reduce 43 omitted

# reduce 44 omitted

# reduce 45 omitted

module_eval(<<'.,.,', 'sqlparser.y', 162)
  def _reduce_46(val, _values)
                                [val[0]]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 166)
  def _reduce_47(val, _values)
                                val[0] << val[2]
                          
  end
.,.,

# reduce 48 omitted

# reduce 49 omitted

# reduce 50 omitted

# reduce 51 omitted

# reduce 52 omitted

# reduce 53 omitted

# reduce 54 omitted

# reduce 55 omitted

# reduce 56 omitted

# reduce 57 omitted

# reduce 58 omitted

# reduce 59 omitted

# reduce 60 omitted

# reduce 61 omitted

# reduce 62 omitted

# reduce 63 omitted

# reduce 64 omitted

# reduce 65 omitted

def _reduce_none(val, _values)
  val[0]
end

end   # class SQLParser


end # module ActiveTokyoCabinet
