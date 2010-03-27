#
# DO NOT MODIFY!!!!
# This file is automatically generated by Racc 1.4.6
# from Racc grammer file "".
#

require 'racc/parser.rb'


require 'strscan'

module ActiveTokyoCabinet

class SQLParser < Racc::Parser

module_eval(<<'...end sqlparser.y/module_eval...', 'sqlparser.y', 205)

def initialize(obj)
  src = obj.is_a?(IO) ? obj.read : obj.to_s
  @ss = StringScanner.new(src)
end

def scan
  piece = nil

  until @ss.eos?
    if (tok = @ss.scan /\s+/)
      # nothing to do
    elsif (tok = @ss.scan /(?:BW|EW|INCALL|INCANY|INC|IN|ANYONE|REGEXP|BT|BETWEEN|FTS|FTSAND|FTSOR|FTSEX)\b/i)
      yield tok.upcase.to_sym, tok
    elsif (tok = @ss.scan /(?:>=|<=|>|<|=)/)
      yield tok, tok
    elsif (tok = @ss.scan /(?:INSERT|INTO|VALUES|SELECT|FROM|WHERE|AND|UPDATE|SET|DELETE|COUNT|ORDER|BY|LIMIT|OFFSET|AS)\b/i)
      yield tok.upcase.to_sym, tok
    elsif (tok = @ss.scan /(?:ASC|DESC|STRASC|STRDESC|NUMASC|NUMDESC)\b/i)
      yield :ORDER_SPEC, tcordertype(tok)
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
    elsif (tok = @ss.scan /(?:[a-z_]\w+\.|[a-z]\.)*ID\b/i)
      yield :ID, tok
    elsif (tok = @ss.scan /(?:[a-z_]\w+\.|[a-z]\.)*(?:[a-z_]\w+|[a-z])/i)
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
  when 'IN', 'ANYONE'
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
  when 'BT', 'BETWEEN'
    :QCNUMBT
  when 'FTS'
    :QCFTSPH
  when 'FTSAND'
    :QCFTSAND
  when 'FTSOR'
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
    74,    78,    33,    81,    26,    58,    63,    64,    33,    33,
    56,    65,    60,    61,    65,    99,    42,    85,    87,    69,
    71,    73,    75,    77,    79,    80,    82,    83,    84,    86,
    68,    70,    72,    58,     2,    10,    49,    65,    10,     7,
    60,    61,    62,   119,   120,    47,    47,   125,    19,    37,
    15,    96,    10,    10,    10,    10,     1,    10,    33,     4,
    10,    10,    88,    28,   118,   118,    10,    10,   118,    58,
    88,    58,    90,    58,    90,    58,    60,    61,    60,    61,
    60,    61,    60,    61,    58,    92,    58,    93,    58,    32,
    95,    60,    61,    60,    61,    60,    61,    10,    28,    97,
    27,    43,    25,   103,   104,    10,    10,   107,    23,    10,
   111,   112,   114,    10,   112,    21,    14,    13,    12,   122,
   124,    10,   103 ]

racc_action_check = [
    51,    51,    29,    51,    17,   107,    47,    47,    35,    36,
    38,    88,   107,   107,    65,    76,    29,    51,    51,    51,
    51,    51,    51,    51,    51,    51,    51,    51,    51,    51,
    51,    51,    51,    76,     0,    88,    33,    49,    65,     0,
    76,    76,    44,   109,   110,    33,    49,   117,     7,    27,
     7,    66,    42,    28,    26,    32,     0,    25,    24,     0,
    33,    49,    66,    44,   109,   110,    27,     7,   117,    95,
    52,    99,    54,    63,    55,   111,    95,    95,    99,    99,
    63,    63,   111,   111,    43,    56,    81,    62,   118,    22,
    64,    43,    43,    81,    81,   118,   118,    21,    20,    67,
    19,    31,    16,    89,    90,    14,    92,    93,    13,    12,
   100,   102,   103,   104,   105,    11,     4,     3,     2,   112,
   115,     1,    91 ]

racc_action_pointer = [
    32,    93,   115,   117,   108,   nil,   nil,    39,   nil,   nil,
   nil,    90,    81,   108,    77,   nil,    94,    -4,   nil,    96,
    72,    69,    85,   nil,    46,    29,    26,    38,    25,   -10,
   nil,    87,    27,    32,   nil,    -4,    -3,   nil,     5,   nil,
   nil,   nil,    24,    62,    37,   nil,   nil,    -8,   nil,    33,
   nil,   -14,    54,   nil,    54,    56,    75,   nil,   nil,   nil,
   nil,   nil,    81,    51,    86,    10,    46,    94,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,    11,   nil,   nil,   nil,
   nil,    64,   nil,   nil,   nil,   nil,   nil,   nil,     7,    82,
    85,   101,    78,   103,   nil,    47,   nil,   nil,   nil,    49,
    94,   nil,    88,    90,    85,    91,   nil,   -17,   nil,    38,
    39,    53,    97,   nil,   nil,   100,   nil,    42,    66,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil ]

racc_action_default = [
   -68,   -68,   -68,   -68,   -68,    -1,    -2,   -68,    -3,    -4,
   -42,   -68,   -68,   -68,   -68,   -12,   -68,   -68,   -43,   -68,
   -13,   -68,   -68,   127,   -14,   -68,   -68,   -68,   -68,   -14,
   -38,   -68,   -68,   -68,   -41,   -14,   -14,   -10,   -68,   -11,
   -44,   -37,   -68,   -68,   -68,   -21,   -23,   -68,   -27,   -68,
   -15,   -68,   -16,   -17,   -29,   -29,    -8,   -39,   -46,   -40,
   -45,   -47,   -68,   -68,   -68,   -68,   -68,   -68,   -64,   -52,
   -65,   -53,   -66,   -54,   -67,   -56,   -68,   -57,   -55,   -58,
   -59,   -68,   -60,   -61,   -62,   -50,   -63,   -51,   -68,   -33,
   -68,   -33,   -68,   -68,   -19,   -68,   -24,   -18,   -25,   -68,
   -68,   -22,   -35,   -68,   -68,   -35,    -9,   -68,   -48,   -68,
   -68,   -68,   -68,    -6,   -34,   -31,    -7,   -68,   -68,   -20,
   -26,   -28,   -36,   -30,   -32,    -5,   -49 ]

racc_goto_table = [
    11,    59,    30,    20,    34,   113,    18,    52,   116,    41,
   102,    22,   105,    24,    53,    54,    55,    89,    91,     9,
    31,    94,     8,    57,    35,    36,    39,    40,    44,    17,
    67,    18,   109,    38,    98,    50,   110,    16,     6,   100,
     5,    31,   101,    76,   117,   123,    29,     3,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   121,
   nil,   nil,   nil,   nil,   nil,   nil,   126,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   106,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   115 ]

racc_goto_check = [
     6,    19,    26,     7,    10,    13,     6,    17,    13,    10,
    12,     6,    12,     6,    18,    10,    10,    11,    11,     5,
     6,    19,     4,    26,     6,     6,     6,     6,     7,    14,
    18,     6,     8,    15,    19,    16,     8,     9,     3,    19,
     2,     6,    20,    22,     8,    24,    25,     1,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,    19,
   nil,   nil,   nil,   nil,   nil,   nil,    19,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,     6,   nil,   nil,   nil,   nil,   nil,   nil,   nil,   nil,
   nil,   nil,   nil,     6 ]

racc_goto_pointer = [
   nil,    47,    40,    38,    22,    19,    -1,    -4,   -63,    30,
   -20,   -37,   -79,   -97,    22,     6,     2,   -26,   -19,   -42,
   -46,   nil,    -8,   nil,   -70,    25,   -19 ]

racc_goto_default = [
   nil,   nil,   nil,   nil,   nil,   nil,    51,   nil,   nil,   nil,
   nil,   nil,   nil,   nil,   nil,   nil,   nil,    66,   nil,   108,
    45,    46,   nil,    48,   nil,   nil,   nil ]

racc_reduce_table = [
  0, 0, :racc_error,
  1, 48, :_reduce_none,
  1, 48, :_reduce_none,
  1, 48, :_reduce_none,
  1, 48, :_reduce_none,
  10, 49, :_reduce_5,
  8, 50, :_reduce_6,
  8, 50, :_reduce_7,
  4, 61, :_reduce_8,
  6, 61, :_reduce_9,
  1, 62, :_reduce_none,
  1, 62, :_reduce_none,
  1, 56, :_reduce_12,
  1, 56, :_reduce_none,
  0, 57, :_reduce_14,
  2, 57, :_reduce_15,
  2, 57, :_reduce_16,
  1, 63, :_reduce_none,
  3, 63, :_reduce_18,
  3, 65, :_reduce_19,
  5, 65, :_reduce_20,
  1, 64, :_reduce_21,
  3, 64, :_reduce_22,
  1, 67, :_reduce_none,
  3, 67, :_reduce_24,
  3, 68, :_reduce_25,
  5, 68, :_reduce_26,
  1, 68, :_reduce_none,
  5, 70, :_reduce_28,
  0, 58, :_reduce_29,
  4, 58, :_reduce_30,
  0, 71, :_reduce_31,
  1, 71, :_reduce_none,
  0, 59, :_reduce_33,
  2, 59, :_reduce_34,
  0, 60, :_reduce_35,
  2, 60, :_reduce_36,
  5, 51, :_reduce_37,
  1, 72, :_reduce_none,
  3, 72, :_reduce_39,
  3, 73, :_reduce_40,
  4, 52, :_reduce_41,
  1, 53, :_reduce_none,
  1, 54, :_reduce_43,
  3, 54, :_reduce_44,
  1, 66, :_reduce_none,
  1, 66, :_reduce_none,
  1, 66, :_reduce_none,
  1, 55, :_reduce_48,
  3, 55, :_reduce_49,
  1, 69, :_reduce_none,
  1, 69, :_reduce_none,
  1, 69, :_reduce_none,
  1, 69, :_reduce_none,
  1, 69, :_reduce_none,
  1, 69, :_reduce_none,
  1, 69, :_reduce_none,
  1, 69, :_reduce_none,
  1, 69, :_reduce_none,
  1, 69, :_reduce_none,
  1, 69, :_reduce_none,
  1, 69, :_reduce_none,
  1, 69, :_reduce_none,
  1, 69, :_reduce_none,
  1, 69, :_reduce_none,
  1, 69, :_reduce_none,
  1, 69, :_reduce_none,
  1, 69, :_reduce_none ]

racc_reduce_n = 68

racc_shift_n = 127

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
  :BETWEEN => 17,
  :ORDER => 18,
  :BY => 19,
  :ORDER_SPEC => 20,
  :LIMIT => 21,
  :NUMBER => 22,
  :OFFSET => 23,
  :UPDATE => 24,
  :SET => 25,
  "," => 26,
  :DELETE => 27,
  :IDENTIFIER => 28,
  :STRING => 29,
  :NULL => 30,
  :BW => 31,
  :EW => 32,
  :INCALL => 33,
  :INCANY => 34,
  :INC => 35,
  :ANYONE => 36,
  :REGEXP => 37,
  :BT => 38,
  :FTS => 39,
  :FTSAND => 40,
  :FTSOR => 41,
  :FTSEX => 42,
  ">=" => 43,
  "<=" => 44,
  ">" => 45,
  "<" => 46 }

racc_nt_base = 47

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
  "BETWEEN",
  "ORDER",
  "BY",
  "ORDER_SPEC",
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
  "ANYONE",
  "REGEXP",
  "BT",
  "FTS",
  "FTSAND",
  "FTSOR",
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
  "between_predicate",
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

# reduce 27 omitted

module_eval(<<'.,.,', 'sqlparser.y', 95)
  def _reduce_28(val, _values)
                                {:name => val[0], :op => tccond(val[1], nil), :expr => [val[2], val[4]]}
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 100)
  def _reduce_29(val, _values)
                                nil
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 104)
  def _reduce_30(val, _values)
                                {:name => val[2], :type => val[3]}
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 109)
  def _reduce_31(val, _values)
                                :QOSTRASC
                          
  end
.,.,

# reduce 32 omitted

module_eval(<<'.,.,', 'sqlparser.y', 115)
  def _reduce_33(val, _values)
                                nil
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 119)
  def _reduce_34(val, _values)
                                val[1]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 124)
  def _reduce_35(val, _values)
                                nil
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 128)
  def _reduce_36(val, _values)
                                val[1]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 133)
  def _reduce_37(val, _values)
                                {:command => :update, :table => val[1], :set_clause_list => val[3], :condition => val[4]}
                          
  end
.,.,

# reduce 38 omitted

module_eval(<<'.,.,', 'sqlparser.y', 139)
  def _reduce_39(val, _values)
                                val[0].merge val[2]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 144)
  def _reduce_40(val, _values)
                              {val[0] => val[2]}
                        
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 149)
  def _reduce_41(val, _values)
                                {:command => :delete, :table => val[2], :condition => val[3]}
                          
  end
.,.,

# reduce 42 omitted

module_eval(<<'.,.,', 'sqlparser.y', 156)
  def _reduce_43(val, _values)
                                [val[0]]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 160)
  def _reduce_44(val, _values)
                                val[0] << val[2]
                          
  end
.,.,

# reduce 45 omitted

# reduce 46 omitted

# reduce 47 omitted

module_eval(<<'.,.,', 'sqlparser.y', 169)
  def _reduce_48(val, _values)
                                [val[0]]
                          
  end
.,.,

module_eval(<<'.,.,', 'sqlparser.y', 173)
  def _reduce_49(val, _values)
                                val[0] << val[2]
                          
  end
.,.,

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

# reduce 66 omitted

# reduce 67 omitted

def _reduce_none(val, _values)
  val[0]
end

end   # class SQLParser


end # module ActiveTokyoCabinet
