%option c++
%option yyclass="GraphScanner"
%option nodefault noyywrap
%option 8bit never-interactive
%option yylineno
%option warn
%option debug

%{
#include "parser/GQLParser.h"
#include "parser/GraphScanner.h"
#include "GraphParser.hpp"
#include "graph/service/GraphFlags.h"

#define YY_USER_ACTION                  \
    yylloc->step();                     \
    yylloc->columns(yyleng);

using Token = nebula::GraphParser::token;
using TokenType = nebula::GraphParser::token::token_kind_type;

#define NG_RESERVED_KEYWORD(a, b) {a, Token::TOK_##b},
#define NG_UNRESERVED_KEYWORD(a, b) {a, Token::TOK_##b},

#define NG_RETURN_TOKEN(a) return Token::TOK_##a;

const std::unordered_map<std::string, TokenType> kCaseSensitiveKeywords {
/* reserved keyword */
// case-sensitive reserved keyword
NG_RESERVED_KEYWORD("endNode", endNode)
NG_RESERVED_KEYWORD("inDegree", inDegree)
NG_RESERVED_KEYWORD("lTrim", lTrim)
NG_RESERVED_KEYWORD("outDegree", outDegree)
NG_RESERVED_KEYWORD("percentileCont", percentileCont)
NG_RESERVED_KEYWORD("percentileDist", percentileDist)
NG_RESERVED_KEYWORD("rTrim", rTrim)
NG_RESERVED_KEYWORD("startNode", startNode)
NG_RESERVED_KEYWORD("stDev", stDev)
NG_RESERVED_KEYWORD("stDevP", stDevP)
NG_RESERVED_KEYWORD("tail", tail)
NG_RESERVED_KEYWORD("toLower", toLower)
NG_RESERVED_KEYWORD("toUpper", toUpper)
};

const std::unordered_map<std::string, TokenType> kCaseInsensitiveKeywords {
// case-insensitive reserved keyword
NG_RESERVED_KEYWORD("ABS", ABS)
NG_RESERVED_KEYWORD("ACOS", ACOS)
NG_RESERVED_KEYWORD("ADD", ADD)
NG_RESERVED_KEYWORD("AGGREGATE", AGGREGATE)
NG_RESERVED_KEYWORD("ALIAS", ALIAS)
NG_RESERVED_KEYWORD("ALL", ALL)
NG_RESERVED_KEYWORD("ALL_DIFFERENT", ALL_DIFFERENT)
NG_RESERVED_KEYWORD("AND", AND)
NG_RESERVED_KEYWORD("ANY", ANY)
NG_RESERVED_KEYWORD("ARRAY", ARRAY)
NG_RESERVED_KEYWORD("AS", AS)
NG_RESERVED_KEYWORD("ASC", ASC)
NG_RESERVED_KEYWORD("ASCENDING", ASCENDING)
NG_RESERVED_KEYWORD("ASIN", ASIN)
NG_RESERVED_KEYWORD("AT", AT)
NG_RESERVED_KEYWORD("ATAN", ATAN)
NG_RESERVED_KEYWORD("AVG", AVG)
NG_RESERVED_KEYWORD("BINARY", BINARY)
NG_RESERVED_KEYWORD("BIGINT", BIGINT)
NG_RESERVED_KEYWORD("BOOL", BOOL)
NG_RESERVED_KEYWORD("BOOLEAN", BOOLEAN)
NG_RESERVED_KEYWORD("BOTH", BOTH)
NG_RESERVED_KEYWORD("BY", BY)
NG_RESERVED_KEYWORD("BYTE_LENGTH", BYTE_LENGTH)
NG_RESERVED_KEYWORD("BYTES", BYTES)
NG_RESERVED_KEYWORD("CALL", CALL)
NG_RESERVED_KEYWORD("CASE", CASE)
NG_RESERVED_KEYWORD("CAST", CAST)
NG_RESERVED_KEYWORD("CATALOG", CATALOG)
NG_RESERVED_KEYWORD("CEIL", CEIL)
NG_RESERVED_KEYWORD("CEILING", CEILING)
NG_RESERVED_KEYWORD("CHARACTER", CHARACTER)
NG_RESERVED_KEYWORD("CHARACTER_LENGTH", CHARACTER_LENGTH)
NG_RESERVED_KEYWORD("CLEAR", CLEAR)
NG_RESERVED_KEYWORD("CLONE", CLONE)
NG_RESERVED_KEYWORD("CLOSE", CLOSE)
NG_RESERVED_KEYWORD("COALESCE", COALESCE)
NG_RESERVED_KEYWORD("COLLECT", COLLECT)
NG_RESERVED_KEYWORD("COMMIT", COMMIT)
NG_RESERVED_KEYWORD("CONSTRAINT", CONSTRAINT)
NG_RESERVED_KEYWORD("CONSTANT", CONSTANT)
NG_RESERVED_KEYWORD("CONSTRUCT", CONSTRUCT)
NG_RESERVED_KEYWORD("COPY", COPY)
NG_RESERVED_KEYWORD("COS", COS)
NG_RESERVED_KEYWORD("COSH", COSH)
NG_RESERVED_KEYWORD("COST", COST)
NG_RESERVED_KEYWORD("COT", COT)
NG_RESERVED_KEYWORD("COUNT", COUNT)
NG_RESERVED_KEYWORD("CURRENT_DATE", CURRENT_DATE)
NG_RESERVED_KEYWORD("CURRENT_GRAPH", CURRENT_GRAPH)
NG_RESERVED_KEYWORD("CURRENT_PROPERTY_GRAPH", CURRENT_PROPERTY_GRAPH)
NG_RESERVED_KEYWORD("CURRENT_ROLE", CURRENT_ROLE)
NG_RESERVED_KEYWORD("CURRENT_SCHEMA", CURRENT_SCHEMA)
NG_RESERVED_KEYWORD("CURRENT_TIME", CURRENT_TIME)
NG_RESERVED_KEYWORD("CURRENT_TIMESTAMP", CURRENT_TIMESTAMP)
NG_RESERVED_KEYWORD("CURRENT_USER", CURRENT_USER)
NG_RESERVED_KEYWORD("CREATE", CREATE)
NG_RESERVED_KEYWORD("DATA", DATA)
NG_RESERVED_KEYWORD("DATE", DATE)
NG_RESERVED_KEYWORD("DATETIME", DATETIME)
NG_RESERVED_KEYWORD("DAY", DAY)  // Newly added for <SQL_interval_literal>
NG_RESERVED_KEYWORD("DEC", DEC)
NG_RESERVED_KEYWORD("DECIMAL", DECIMAL)
NG_RESERVED_KEYWORD("DEFAULT", DEFAULT)
NG_RESERVED_KEYWORD("DEGREES", DEGREES)
NG_RESERVED_KEYWORD("DELETE", DELETE)
NG_RESERVED_KEYWORD("DETACH", DETACH)
NG_RESERVED_KEYWORD("DESC", DESC)
NG_RESERVED_KEYWORD("DESCENDING", DESCENDING)
NG_RESERVED_KEYWORD("DIRECTORIES", DIRECTORIES)
NG_RESERVED_KEYWORD("DIRECTORY", DIRECTORY)
NG_RESERVED_KEYWORD("DISTINCT", DISTINCT)
NG_RESERVED_KEYWORD("DO", DO)
NG_RESERVED_KEYWORD("DOUBLE", DOUBLE)
NG_RESERVED_KEYWORD("DROP", DROP)
NG_RESERVED_KEYWORD("DURATION", DURATION)
NG_RESERVED_KEYWORD("ELEMENT_ID", ELEMENT_ID)
NG_RESERVED_KEYWORD("ELSE", ELSE)
NG_RESERVED_KEYWORD("END", END)
NG_RESERVED_KEYWORD("ENDS", ENDS)
NG_RESERVED_KEYWORD("EMPTY_BINDING_TABLE", EMPTY_BINDING_TABLE)
NG_RESERVED_KEYWORD("EMPTY_GRAPH", EMPTY_GRAPH)
NG_RESERVED_KEYWORD("EMPTY_PROPERTY_GRAPH", EMPTY_PROPERTY_GRAPH)
NG_RESERVED_KEYWORD("EMPTY_TABLE", EMPTY_TABLE)
NG_RESERVED_KEYWORD("EXCEPT", EXCEPT)
NG_RESERVED_KEYWORD("EXISTS", EXISTS)
NG_RESERVED_KEYWORD("EXISTING", EXISTING)
NG_RESERVED_KEYWORD("EXP", EXP)
NG_RESERVED_KEYWORD("EXPLAIN", EXPLAIN)
NG_RESERVED_KEYWORD("FALSE", FALSE)
NG_RESERVED_KEYWORD("FILTER", FILTER)
NG_RESERVED_KEYWORD("FLOAT", FLOAT)
NG_RESERVED_KEYWORD("FLOAT16", FLOAT16)
NG_RESERVED_KEYWORD("FLOAT32", FLOAT32)
NG_RESERVED_KEYWORD("FLOAT64", FLOAT64)
NG_RESERVED_KEYWORD("FLOAT128", FLOAT128)
NG_RESERVED_KEYWORD("FLOAT256", FLOAT256)
NG_RESERVED_KEYWORD("FLOOR", FLOOR)
NG_RESERVED_KEYWORD("FOR", FOR)
NG_RESERVED_KEYWORD("FROM", FROM)
NG_RESERVED_KEYWORD("FUNCTION", FUNCTION)
NG_RESERVED_KEYWORD("FUNCTIONS", FUNCTIONS)
NG_RESERVED_KEYWORD("GQLSTATUS", GQLSTATUS)
NG_RESERVED_KEYWORD("GRANT", GRANT)
NG_RESERVED_KEYWORD("GROUP", GROUP)
NG_RESERVED_KEYWORD("HAVING", HAVING)
NG_RESERVED_KEYWORD("HOME_GRAPH", HOME_GRAPH)
NG_RESERVED_KEYWORD("HOME_PROPERTY_GRAPH", HOME_PROPERTY_GRAPH)
NG_RESERVED_KEYWORD("HOME_SCHEMA", HOME_SCHEMA)
NG_RESERVED_KEYWORD("HOUR", HOUR)  // Newly added for <SQL_interval_literal>
NG_RESERVED_KEYWORD("IN", IN)
NG_RESERVED_KEYWORD("INSERT", INSERT)
NG_RESERVED_KEYWORD("INT", INT)
NG_RESERVED_KEYWORD("INTEGER", INTEGER)
NG_RESERVED_KEYWORD("INT8", INT8)
NG_RESERVED_KEYWORD("INTEGER8", INTEGER8)
NG_RESERVED_KEYWORD("INT16", INT16)
NG_RESERVED_KEYWORD("INTEGER16", INTEGER16)
NG_RESERVED_KEYWORD("INT32", INT32)
NG_RESERVED_KEYWORD("INTEGER32", INTEGER32)
NG_RESERVED_KEYWORD("INTERVAL", INTERVAL)  // Newly added for <SQL_interval_literal>
NG_RESERVED_KEYWORD("INT64", INT64)
NG_RESERVED_KEYWORD("INTEGER64", INTEGER64)
NG_RESERVED_KEYWORD("INT128", INT128)
NG_RESERVED_KEYWORD("INTEGER128", INTEGER128)
NG_RESERVED_KEYWORD("INT256", INT256)
NG_RESERVED_KEYWORD("INTEGER256", INTEGER256)
NG_RESERVED_KEYWORD("INTERSECT", INTERSECT)
NG_RESERVED_KEYWORD("IF", IF)
NG_RESERVED_KEYWORD("IS", IS)
NG_RESERVED_KEYWORD("KEEP", KEEP)
NG_RESERVED_KEYWORD("LEADING", LEADING)
NG_RESERVED_KEYWORD("LEFT", LEFT)
NG_RESERVED_KEYWORD("LENGTH", LENGTH)
NG_RESERVED_KEYWORD("LET", LET)
NG_RESERVED_KEYWORD("LIKE", LIKE)
NG_RESERVED_KEYWORD("LIKE_REGEX", LIKE_REGEX)
NG_RESERVED_KEYWORD("LIMIT", LIMIT)
NG_RESERVED_KEYWORD("LIST", LIST)
NG_RESERVED_KEYWORD("LN", LN)
NG_RESERVED_KEYWORD("LOCALDATETIME", LOCALDATETIME)
NG_RESERVED_KEYWORD("LOCALTIME", LOCALTIME)
NG_RESERVED_KEYWORD("LOCALTIMESTAMP", LOCALTIMESTAMP)
NG_RESERVED_KEYWORD("LOG", LOG)
NG_RESERVED_KEYWORD("LOG10", LOG10)
NG_RESERVED_KEYWORD("LOWER", LOWER)
NG_RESERVED_KEYWORD("MANDATORY", MANDATORY)
NG_RESERVED_KEYWORD("MAP", MAP)
NG_RESERVED_KEYWORD("MATCH", MATCH)
NG_RESERVED_KEYWORD("MERGE", MERGE)
NG_RESERVED_KEYWORD("MAX", MAX)
NG_RESERVED_KEYWORD("MIN", MIN)
NG_RESERVED_KEYWORD("MINUTE", MINUTE)  // Newly added for <SQL_interval_literal>
NG_RESERVED_KEYWORD("MOD", MOD)
NG_RESERVED_KEYWORD("MONTH", MONTH)  // Newly added for <SQL_interval_literal>
NG_RESERVED_KEYWORD("MULTI", MULTI)
NG_RESERVED_KEYWORD("MULTIPLE", MULTIPLE)
NG_RESERVED_KEYWORD("MULTISET", MULTISET)
NG_RESERVED_KEYWORD("NEW", NEW)
NG_RESERVED_KEYWORD("NOT", NOT)
NG_RESERVED_KEYWORD("NORMALIZE", NORMALIZE)
NG_RESERVED_KEYWORD("NOTHING", NOTHING)
NG_RESERVED_KEYWORD("NULL", NULL)
NG_RESERVED_KEYWORD("NULLS", NULLS)
NG_RESERVED_KEYWORD("NULLIF", NULLIF)
NG_RESERVED_KEYWORD("NUMERIC", NUMERIC)
NG_RESERVED_KEYWORD("OCCURRENCES_REGEX", OCCURRENCES_REGEX)
NG_RESERVED_KEYWORD("OCTET_LENGTH", OCTET_LENGTH)
NG_RESERVED_KEYWORD("OF", OF)
NG_RESERVED_KEYWORD("OFFSET", OFFSET)
NG_RESERVED_KEYWORD("ON", ON)
NG_RESERVED_KEYWORD("OPTIONAL", OPTIONAL)
NG_RESERVED_KEYWORD("OR", OR)
NG_RESERVED_KEYWORD("ORDER", ORDER)
NG_RESERVED_KEYWORD("ORDERED", ORDERED)
NG_RESERVED_KEYWORD("OTHERWISE", OTHERWISE)
NG_RESERVED_KEYWORD("PARAMETER", PARAMETER)
NG_RESERVED_KEYWORD("PATH", PATH)
NG_RESERVED_KEYWORD("PATHS", PATHS)
NG_RESERVED_KEYWORD("PARTITION", PARTITION)
NG_RESERVED_KEYWORD("POSITION_REGEX", POSITION_REGEX)
NG_RESERVED_KEYWORD("POWER", POWER)
NG_RESERVED_KEYWORD("PRECISION", PRECISION)
NG_RESERVED_KEYWORD("PROCEDURE", PROCEDURE)
NG_RESERVED_KEYWORD("PROCEDURES", PROCEDURES)
NG_RESERVED_KEYWORD("PRODUCT", PRODUCT)
NG_RESERVED_KEYWORD("PROFILE", PROFILE)
NG_RESERVED_KEYWORD("PROJECT", PROJECT)
NG_RESERVED_KEYWORD("QUERIES", QUERIES)
NG_RESERVED_KEYWORD("QUERY", QUERY)
NG_RESERVED_KEYWORD("RADIANS", RADIANS)
NG_RESERVED_KEYWORD("REAL", REAL)
NG_RESERVED_KEYWORD("RECORD", RECORD)
NG_RESERVED_KEYWORD("RECORDS", RECORDS)
NG_RESERVED_KEYWORD("REFERENCE", REFERENCE)
NG_RESERVED_KEYWORD("REMOVE", REMOVE)
NG_RESERVED_KEYWORD("RENAME", RENAME)
NG_RESERVED_KEYWORD("REPLACE", REPLACE)
NG_RESERVED_KEYWORD("REQUIRE", REQUIRE)
NG_RESERVED_KEYWORD("RESET", RESET)
NG_RESERVED_KEYWORD("RESULT", RESULT)
NG_RESERVED_KEYWORD("RETURN", RETURN)
NG_RESERVED_KEYWORD("REVOKE", REVOKE)
NG_RESERVED_KEYWORD("RIGHT", RIGHT)
NG_RESERVED_KEYWORD("ROLLBACK", ROLLBACK)
NG_RESERVED_KEYWORD("SAME", SAME)
NG_RESERVED_KEYWORD("SCALAR", SCALAR)
NG_RESERVED_KEYWORD("SCHEMA", SCHEMA)
NG_RESERVED_KEYWORD("SCHEMAS", SCHEMAS)
NG_RESERVED_KEYWORD("SCHEMATA", SCHEMATA)
NG_RESERVED_KEYWORD("SECOND", SECOND)  // Newly added for <SQL_interval_literal>
NG_RESERVED_KEYWORD("SELECT", SELECT)
NG_RESERVED_KEYWORD("SESSION", SESSION)
NG_RESERVED_KEYWORD("SET", SET)
NG_RESERVED_KEYWORD("SKIP", SKIP)
NG_RESERVED_KEYWORD("SIGNED", SIGNED)
NG_RESERVED_KEYWORD("SIN", SIN)
NG_RESERVED_KEYWORD("SINGLE", SINGLE)
NG_RESERVED_KEYWORD("SINH", SINH)
NG_RESERVED_KEYWORD("SMALLINT", SMALLINT)
NG_RESERVED_KEYWORD("SQRT", SQRT)
NG_RESERVED_KEYWORD("START", START)
NG_RESERVED_KEYWORD("STARTS", STARTS)
NG_RESERVED_KEYWORD("STRING", STRING)
NG_RESERVED_KEYWORD("SUBSTRING", SUBSTRING)
NG_RESERVED_KEYWORD("SUBSTRING_REGEX", SUBSTRING_REGEX)
NG_RESERVED_KEYWORD("SUM", SUM)
NG_RESERVED_KEYWORD("TAN", TAN)
NG_RESERVED_KEYWORD("TANH", TANH)
NG_RESERVED_KEYWORD("THEN", THEN)
NG_RESERVED_KEYWORD("TIME", TIME)
NG_RESERVED_KEYWORD("TIMESTAMP", TIMESTAMP)
NG_RESERVED_KEYWORD("TRAILING", TRAILING)
NG_RESERVED_KEYWORD("TRANSLATE_REGEX", TRANSLATE_REGEX)
NG_RESERVED_KEYWORD("TRIM", TRIM)
NG_RESERVED_KEYWORD("TRUE", TRUE)
NG_RESERVED_KEYWORD("TRUNCATE", TRUNCATE)
NG_RESERVED_KEYWORD("UINT", UINT)
NG_RESERVED_KEYWORD("UINT8", UINT8)
NG_RESERVED_KEYWORD("UINT16", UINT16)
NG_RESERVED_KEYWORD("UINT32", UINT32)
NG_RESERVED_KEYWORD("UINT64", UINT64)
NG_RESERVED_KEYWORD("UINT128", UINT128)
NG_RESERVED_KEYWORD("UINT256", UINT256)
NG_RESERVED_KEYWORD("UNION", UNION)
NG_RESERVED_KEYWORD("UNIT", UNIT)
NG_RESERVED_KEYWORD("UNIT_BINDING_TABLE", UNIT_BINDING_TABLE)
NG_RESERVED_KEYWORD("UNIT_TABLE", UNIT_TABLE)
NG_RESERVED_KEYWORD("UNIQUE", UNIQUE)
NG_RESERVED_KEYWORD("UNNEST", UNNEST)
NG_RESERVED_KEYWORD("UNKNOWN", UNKNOWN)
NG_RESERVED_KEYWORD("UNSIGNED", UNSIGNED)
NG_RESERVED_KEYWORD("UNWIND", UNWIND)
NG_RESERVED_KEYWORD("UPPER", UPPER)
NG_RESERVED_KEYWORD("USE", USE)
NG_RESERVED_KEYWORD("VALUE", VALUE)
NG_RESERVED_KEYWORD("VALUES", VALUES)
NG_RESERVED_KEYWORD("VARBINARY", VARBINARY)
NG_RESERVED_KEYWORD("VARCHAR", VARCHAR)
NG_RESERVED_KEYWORD("WHEN", WHEN)
NG_RESERVED_KEYWORD("WHERE", WHERE)
NG_RESERVED_KEYWORD("WITH", WITH)
NG_RESERVED_KEYWORD("WITHOUT", WITHOUT)
NG_RESERVED_KEYWORD("XOR", XOR)
NG_RESERVED_KEYWORD("YEAR", YEAR)  // Newly added for <SQL_interval_literal>
NG_RESERVED_KEYWORD("YIELD", YIELD)
NG_RESERVED_KEYWORD("ZERO", ZERO)
/* unreserved keyword */
// case-insensitive non-reserved keyword
NG_UNRESERVED_KEYWORD("ACYCLIC", ACYCLIC)
NG_UNRESERVED_KEYWORD("BINDING", BINDING)
NG_UNRESERVED_KEYWORD("CLASS_ORIGIN", CLASS_ORIGIN)
NG_UNRESERVED_KEYWORD("COMMAND_FUNCTION", COMMAND_FUNCTION)
NG_UNRESERVED_KEYWORD("COMMAND_FUNCTION_CODE", COMMAND_FUNCTION_CODE)
NG_UNRESERVED_KEYWORD("CONDITION_NUMBER", CONDITION_NUMBER)
NG_UNRESERVED_KEYWORD("CONNECTING", CONNECTING)
NG_UNRESERVED_KEYWORD("DESTINATION", DESTINATION)
NG_UNRESERVED_KEYWORD("DIRECTED", DIRECTED)
NG_UNRESERVED_KEYWORD("EDGE", EDGE)
NG_UNRESERVED_KEYWORD("EDGES", EDGES)
NG_UNRESERVED_KEYWORD("FINAL", FINAL)
NG_UNRESERVED_KEYWORD("FIRST", FIRST)
NG_UNRESERVED_KEYWORD("GRAPH", GRAPH)
NG_UNRESERVED_KEYWORD("GRAPHS", GRAPHS)
NG_UNRESERVED_KEYWORD("GROUPS", GROUPS)
NG_UNRESERVED_KEYWORD("INDEX", INDEX)
NG_UNRESERVED_KEYWORD("LAST", LAST)
NG_UNRESERVED_KEYWORD("LABEL", LABEL)
NG_UNRESERVED_KEYWORD("LABELED", LABELED)
NG_UNRESERVED_KEYWORD("LABELS", LABELS)
NG_UNRESERVED_KEYWORD("MESSAGE_TEXT", MESSAGE_TEXT)
NG_UNRESERVED_KEYWORD("MORE", MORE)
NG_UNRESERVED_KEYWORD("MUTABLE", MUTABLE)
NG_UNRESERVED_KEYWORD("NFC", NFC)
NG_UNRESERVED_KEYWORD("NFD", NFD)
NG_UNRESERVED_KEYWORD("NFKC", NFKC)
NG_UNRESERVED_KEYWORD("NFKD", NFKD)
NG_UNRESERVED_KEYWORD("NODE", NODE)
NG_UNRESERVED_KEYWORD("NODES", NODES)
NG_UNRESERVED_KEYWORD("NORMALIZED", NORMALIZED)
NG_UNRESERVED_KEYWORD("NUMBER", NUMBER)
NG_UNRESERVED_KEYWORD("ONLY", ONLY)
NG_UNRESERVED_KEYWORD("ORDINALITY", ORDINALITY)
NG_UNRESERVED_KEYWORD("PATTERN", PATTERN)
NG_UNRESERVED_KEYWORD("PATTERNS", PATTERNS)
NG_UNRESERVED_KEYWORD("PROPERTY", PROPERTY)
NG_UNRESERVED_KEYWORD("PROPERTIES", PROPERTIES)
NG_UNRESERVED_KEYWORD("READ", READ)
NG_UNRESERVED_KEYWORD("RELATIONSHIP", RELATIONSHIP)
NG_UNRESERVED_KEYWORD("RELATIONSHIPS", RELATIONSHIPS)
NG_UNRESERVED_KEYWORD("RETURNED_GQLSTATUS", RETURNED_GQLSTATUS)
NG_UNRESERVED_KEYWORD("SHORTEST", SHORTEST)
NG_UNRESERVED_KEYWORD("SIMPLE", SIMPLE)
NG_UNRESERVED_KEYWORD("SOURCE", SOURCE)
NG_UNRESERVED_KEYWORD("SUBCLASS_ORIGIN", SUBCLASS_ORIGIN)
NG_UNRESERVED_KEYWORD("TABLE", TABLE)
NG_UNRESERVED_KEYWORD("TABLES", TABLES)
NG_UNRESERVED_KEYWORD("TIES", TIES)
NG_UNRESERVED_KEYWORD("TO", TO)
NG_UNRESERVED_KEYWORD("TRAIL", TRAIL)
NG_UNRESERVED_KEYWORD("TRANSACTION", TRANSACTION)
NG_UNRESERVED_KEYWORD("TYPE", TYPE)
NG_UNRESERVED_KEYWORD("TYPES", TYPES)
NG_UNRESERVED_KEYWORD("UNDIRECTED", UNDIRECTED)
NG_UNRESERVED_KEYWORD("VERTEX", VERTEX)
NG_UNRESERVED_KEYWORD("VERTICES", VERTICES)
NG_UNRESERVED_KEYWORD("WALK", WALK)
NG_UNRESERVED_KEYWORD("WRITE", WRITE)
NG_UNRESERVED_KEYWORD("ZONE", ZONE)
};

// Check against the keyword list.
bool keywordLookup(const std::unordered_map<std::string, TokenType>& keywords,
                   std::string text,
                   bool caseSensitivity,
                   TokenType& token) {
  if (!caseSensitivity) {
    std::transform(
        text.begin(), text.end(), text.begin(), [](unsigned char c) { return std::toupper(c); });
  }

  auto iter = keywords.find(text);
  if (iter != keywords.end()) {
    token = iter->second;
    return true;
  }
  return false;
}

bool keywordLookup(const std::string& text, TokenType& token) {
  return keywordLookup(kCaseSensitiveKeywords, text, true, token) ||
         keywordLookup(kCaseInsensitiveKeywords, text, false, token);
}

%}


/* delimiter token */
/* GQL special character */
space " "
ampersand "&"
asterisk "*"
circumflex "^"
colon ":"
comma ","
dollar_sign "$"
double_quote "\""
equals_operator "="
exclamation_mark "!"
right_angle_bracket ">"
grave_accent "`"
left_brace "{"
left_bracket "["
left_paren "("
left_angle_bracket "<"
minus_sign "-"
percent "%"
period "."
plus_sign "+"
question_mark "?"
quote "'"
reverse_solidus "\\"
right_brace "}"
right_bracket "]"
right_paren ")"
semicolon ";"
solidus "/"
tilde "~"
underscore "_"
vertical_bar "|"

bracket_right_arrow "]->"
bracket_tilde_right_arrow "]~>"
concatenation_operator "||"
double_colon "::"
double_minus_sign "--"
double_period ".."
double_solidus "//"
greater_than_or_equals_operator ">="
left_arrow "<-"
left_arrow_tilde "<~"
left_arrow_bracket "<-["
left_arrow_tilde_bracket "<~["
left_minus_right "<->"
left_minus_slash "<-/"
left_tilde_slash "<~/"
less_than_or_equals_operator "<="
minus_left_bracket "-["
minus_slash "-/"
not_equals_operator "<>"
right_arrow "->"
right_bracket_minus "]-"
right_bracket_tilde "]~"
slash_minus "/-"
slash_minus_right "/->"
slash_tilde "/~"
slash_tilde_right "/~>"
tilde_left_bracket "~["
tilde_right_arrow "~>"
tilde_slash "~/"

multiset_alternation_operator "|+|"

bracketed_comment_introducer "/*"
bracketed_comment_terminator "*/"
non_bracketed_comment_terminator [^{bracketed_comment_terminator}]

/* doubled_grave_accent "``" */
/* escaped_grave_accent {reverse_solidus}{grave_accent}|{doubled_grave_accent} */


/* refer to https://www.fileformat.info/info/unicode/category/Nd/list.htm */
/* other_digit */
/* digit [0-9]|other_digit */
digit [0-9]
hex_digit [0-9A-Fa-f]
octal_digit [0-7]
binary_digit [01]
unsigned_decimal_integer {digit}({underscore}?{digit})*
unsigned_hexadecimal_integer 0x({underscore}?{hex_digit})*
unsigned_octal_integer 0o({underscore}?{octal_digit})*
unsigned_binary_integer 0b({underscore}?{binary_digit})*
unsigned_integer {unsigned_decimal_integer}|{unsigned_hexadecimal_integer}|{unsigned_octal_integer}|{unsigned_binary_integer}
exact_numeric_literal {unsigned_integer}|{unsigned_decimal_integer}({period}{unsigned_decimal_integer}?)?|{period}{unsigned_decimal_integer}
sign {plus_sign}|{minus_sign}
signed_decimal_integer {sign}?{unsigned_decimal_integer}
mantissa {exact_numeric_literal}
exponent {signed_decimal_integer}
approximate_numeric_literal {mantissa}[Ee]{exponent}

unsigned_numeric_literal {exact_numeric_literal}|{approximate_numeric_literal}
byte_string_literal [Xx]{quote}{space}*({hex_digit}{space}*{hex_digit}{space}*)*{quote}({separator}{quote}{space}*({hex_digit}{space}*{hex_digit}{space}*)*{quote})*


identifier_start [A-Za-z\200-\377_]
identifier_extend [A-Za-z\200-\377_0-9\$]
regular_identifier {identifier_start}{identifier_extend}*
extended_identifier {identifier_extend}*
/* identifier {regular_identifier}|{delimited_identifier} */

simple_comment_introducer {double_solidus}|{double_minus_sign}
simple_comment_character [^{newline}]
simple_comment {simple_comment_introducer}{simple_comment_character}*{newline}
bracketed_comment {bracketed_comment_introducer}{non_bracketed_comment_terminator}*{bracketed_comment_terminator}
comment {simple_comment}|{bracketed_comment}


string_literal_character [^{escaped_character}]
escaped_reverse_solidus {reverse_solidus}{reverse_solidus}
escaped_quote {reverse_solidus}{quote}
escaped_double_quote {reverse_solidus}{double_quote}
escaped_tab {reverse_solidus}t
escaped_backspace {reverse_solidus}b
escaped_newline {reverse_solidus}n
escaped_carriage_return {reverse_solidus}r
escaped_form_feed {reverse_solidus}f
unicode_4_digit_escape_value {reverse_solidus}u{hex_digit}{4}
unicode_6_digit_escape_value {reverse_solidus}U{hex_digit}{6}
unicode_escape_value {unicode_4_digit_escape_value}|{unicode_6_digit_escape_value}
escaped_character {escaped_reverse_solidus}|{escaped_quote}|{escaped_double_quote}|{escaped_tab}|{escaped_backspace}|{escaped_newline}|{escaped_carriage_return}|{escaped_form_feed}|{unicode_escape_value}
character_representation {string_literal_character}|{escaped_character}
single_quoted_character_representation {character_representation}
double_quoted_character_representation {character_representation}
accent_quoted_character_representation {character_representation}
unbroken_single_quoted_character_sequence {quote}{single_quoted_character_representation}*{quote}
unbroken_double_quoted_character_sequence {double_quote}{double_quoted_character_representation}*{double_quote}
unbroken_accent_quoted_character_sequence {grave_accent}{accent_quoted_character_representation}*{grave_accent}
single_quoted_character_sequence {unbroken_single_quoted_character_sequence}({separator}{unbroken_single_quoted_character_sequence})*
double_quoted_character_sequence {unbroken_double_quoted_character_sequence}({separator}{unbroken_double_quoted_character_sequence})*
delimited_identifier {double_quoted_character_sequence}|{unbroken_accent_quoted_character_sequence}

whitespace [ \t\n\v\f\r]+
newline [\n\r(\n\r)]
separator ({comment}|{whitespace})*

separated_identifier {extended_identifier}|{delimited_identifier}
parameter_name \${separated_identifier}

unbroken_character_string_literal {unbroken_single_quoted_character_sequence}|{unbroken_double_quoted_character_sequence}
character_string_literal {single_quoted_character_sequence}|{double_quoted_character_sequence}

/* special */
/* session_set SESSION{separator}SET */
is_source IS{separator}SOURCE
is_not_source IS{separator}NOT{separator}SOURCE
is_destination IS{separator}DESTINATION
is_not_destination IS{separator}NOT{separator}DESTINATION


%%

%{
  /* FLEX:  initial code: The following code block is executed every time yylex is called.
   * Reset the current scanning locations each time yylex is called to match new pattern.
   */
  // std::cerr << "FLEX: YYTEXT: " << string(yytext, yyleng) << std::endl;
%}

  /* {space} {
    NG_RETURN_TOKEN(SPACE);
  } */
{ampersand} {
  NG_RETURN_TOKEN(AMPERSAND);
}
{asterisk} {
  NG_RETURN_TOKEN(ASTERISK);
}
  /* {circumflex} {
    NG_RETURN_TOKEN(CIRCUMFLEX);
  } */
{colon} {
  NG_RETURN_TOKEN(COLON);
}
{comma} {
  NG_RETURN_TOKEN(COMMA);
}
  /* {dollar_sign} {
    NG_RETURN_TOKEN(DOLLAR_SIGN);
  } */
  /* {double_quote} {
    NG_RETURN_TOKEN(DOUBLE_QUOTE);
  } */
{equals_operator} {
  NG_RETURN_TOKEN(EQUALS_OPERATOR);
}
{exclamation_mark} {
  NG_RETURN_TOKEN(EXCLAMATION_MARK);
}
{right_angle_bracket} {
  NG_RETURN_TOKEN(RIGHT_ANGLE_BRACKET);
}
  /* {grave_accent} {
    NG_RETURN_TOKEN(GRAVE_ACCENT);
  } */
{left_brace} {
  NG_RETURN_TOKEN(LEFT_BRACE);
}
{left_bracket} {
  NG_RETURN_TOKEN(LEFT_BRACKET);
}
{left_paren} {
  NG_RETURN_TOKEN(LEFT_PAREN);
}
{left_angle_bracket} {
  NG_RETURN_TOKEN(LEFT_ANGLE_BRACKET);
}
{minus_sign} {
  NG_RETURN_TOKEN(MINUS_SIGN);
}
{percent} {
  NG_RETURN_TOKEN(PERCENT);
}
{period} {
  NG_RETURN_TOKEN(PERIOD);
}
{plus_sign} {
  NG_RETURN_TOKEN(PLUS_SIGN);
}
{question_mark} {
  NG_RETURN_TOKEN(QUESTION_MARK);
}
{quote} {
  NG_RETURN_TOKEN(QUOTE);
}
  /* {reverse_solidus} {
    NG_RETURN_TOKEN(REVERSE_SOLIDUS);
  } */
{right_brace} {
  NG_RETURN_TOKEN(RIGHT_BRACE);
}
{right_bracket} {
  NG_RETURN_TOKEN(RIGHT_BRACKET);
}
{right_paren} {
  NG_RETURN_TOKEN(RIGHT_PAREN);
}
{semicolon} {
  NG_RETURN_TOKEN(SEMICOLON);
}
{solidus} {
  NG_RETURN_TOKEN(SOLIDUS);
}
{tilde} {
  NG_RETURN_TOKEN(TILDE);
}
  /* {underscore} {
    NG_RETURN_TOKEN(UNDERSCORE);
  } */
{vertical_bar} {
  NG_RETURN_TOKEN(VERTICAL_BAR);
}
{bracket_right_arrow} {
  NG_RETURN_TOKEN(BRACKET_RIGHT_ARROW);
}
{bracket_tilde_right_arrow} {
  NG_RETURN_TOKEN(BRACKET_TILDE_RIGHT_ARROW);
}
{concatenation_operator} {
  NG_RETURN_TOKEN(CONCATENATION_OPERATOR);
}
{double_colon} {
  NG_RETURN_TOKEN(DOUBLE_COLON);
}
  /* {double_minus_sign} {
    NG_RETURN_TOKEN(DOUBLE_MINUS_SIGN);
  } */
{double_period} {
  NG_RETURN_TOKEN(DOUBLE_PERIOD);
}
  /* {double_solidus} {
    NG_RETURN_TOKEN(DOUBLE_SOLIDUS);
  } */
{greater_than_or_equals_operator} {
  NG_RETURN_TOKEN(GREATER_THAN_OR_EQUALS_OPERATOR);
}
{left_arrow} {
  NG_RETURN_TOKEN(LEFT_ARROW);
}
{left_arrow_tilde} {
  NG_RETURN_TOKEN(LEFT_ARROW_TILDE);
}
{left_arrow_bracket} {
  NG_RETURN_TOKEN(LEFT_ARROW_BRACKET);
}
{left_arrow_tilde_bracket} {
  NG_RETURN_TOKEN(LEFT_ARROW_TILDE_BRACKET);
}
{left_minus_right} {
  NG_RETURN_TOKEN(LEFT_MINUS_RIGHT);
}
{left_minus_slash} {
  NG_RETURN_TOKEN(LEFT_MINUS_SLASH);
}
{left_tilde_slash} {
  NG_RETURN_TOKEN(LEFT_TILDE_SLASH);
}
{less_than_or_equals_operator} {
  NG_RETURN_TOKEN(LESS_THAN_OR_EQUALS_OPERATOR);
}
{minus_left_bracket} {
  NG_RETURN_TOKEN(MINUS_LEFT_BRACKET);
}
{minus_slash} {
  NG_RETURN_TOKEN(MINUS_SLASH);
}
{not_equals_operator} {
  NG_RETURN_TOKEN(NOT_EQUALS_OPERATOR);
}
{right_arrow} {
  NG_RETURN_TOKEN(RIGHT_ARROW);
}
{right_bracket_minus} {
  NG_RETURN_TOKEN(RIGHT_BRACKET_MINUS);
}
{right_bracket_tilde} {
  NG_RETURN_TOKEN(RIGHT_BRACKET_TILDE);
}
{slash_minus} {
  NG_RETURN_TOKEN(SLASH_MINUS);
}
{slash_minus_right} {
  NG_RETURN_TOKEN(SLASH_MINUS_RIGHT);
}
{slash_tilde} {
  NG_RETURN_TOKEN(SLASH_TILDE);
}
{slash_tilde_right} {
  NG_RETURN_TOKEN(SLASH_TILDE_RIGHT);
}
{tilde_left_bracket} {
  NG_RETURN_TOKEN(TILDE_LEFT_BRACKET);
}
{tilde_right_arrow} {
  NG_RETURN_TOKEN(TILDE_RIGHT_ARROW);
}
{tilde_slash} {
  NG_RETURN_TOKEN(TILDE_SLASH);
}

{multiset_alternation_operator} {
  NG_RETURN_TOKEN(MULTISET_ALTERNATION_OPERATOR);
}

{whitespace} {}

{comment} {}

 /* {session_set} {
  NG_RETURN_TOKEN(SESSION_SET);
 } */
{is_source} {
  NG_RETURN_TOKEN(IS_SOURCE);
}
{is_not_source} {
  NG_RETURN_TOKEN(IS_NOT_SOURCE);
}
{is_destination} {
  NG_RETURN_TOKEN(IS_DESTINATION);
}
{is_not_destination} {
  NG_RETURN_TOKEN(IS_NOT_DESTINATION);
}

{regular_identifier} {
  /* Check against the keyword lists. */
  TokenType token;
  bool found = keywordLookup(std::string(yytext, yyleng), token);
  if (found) {
    std::cerr << "FLEX: regular_identifier, keyword: " << std::string(yytext, yyleng) << std::endl;
    // yylval->keywordVal = new std::string(yytext, yyleng);
    return token;
  }

  /* Not a keyword. Check if it is a legal unicode identifier. */
  //if (isValidUnicodeIdentifier(yytext, yyleng)) {
    // yylval->identVal = new std::string(yytext, yyleng);
    std::cerr << "FLEX: regular_identifier, normal identifier: " << std::string(yytext, yyleng) << std::endl;
    NG_RETURN_TOKEN(REGULAR_IDENTIFIER);
  //}
  throw GraphParser::syntax_error(*yylloc, "illegal unicode identifier");
}

{delimited_identifier} {
  NG_RETURN_TOKEN(DELIMITED_IDENTIFIER);
}

{parameter_name} {
  // yylval->paramVal = new std::string(yytext + 1, yyleng - 1);
  NG_RETURN_TOKEN(PARAMETER_NAME);
}

{unsigned_decimal_integer} {
  // yylval->unsignedDecimalInteger = parseUnsignedDecimalInteger(yytext, yyleng);
  std::cerr << "FLEX: unsigned_decimal_integer" << std::endl;
  NG_RETURN_TOKEN(UNSIGNED_DECIMAL_INTEGER);
}

{unsigned_hexadecimal_integer} {
  // yylval->unsignedHexadecimalInteger = parseUnsignedHexadecimalInteger(yytext, yyleng);
  NG_RETURN_TOKEN(UNSIGNED_HEXADECIMAL_INTEGER);
}

{unsigned_octal_integer} {
  // yylval->unsignedOctalInteger = parseUnsignedOctalInteger(yytext, yyleng);
  NG_RETURN_TOKEN(UNSIGNED_OCTAL_INTEGER);
}

{unsigned_binary_integer} {
  // yylval->unsignedBinaryInteger = parseUnsignedBinaryInteger(yytext, yyleng);
  NG_RETURN_TOKEN(UNSIGNED_BINARY_INTEGER);
}

{unsigned_numeric_literal} {
  // yylval->unsignedNumericLiteral = parseUnsignedNumericLiteral(yytext, yyleng);
  NG_RETURN_TOKEN(UNSIGNED_NUMERIC_LITERAL);
}

{byte_string_literal} {
  // yylval->byteStringLiteral = parseByteStringLiteral(yytext, yyleng);
  NG_RETURN_TOKEN(BYTE_STRING_LITERAL);
}

{unbroken_character_string_literal} {
  // yylval->unbrokenCharacterStringLiteral = new std::string(yytext+1, yyleng - 2);
  NG_RETURN_TOKEN(UNBROKEN_CHARACTER_STRING_LITERAL);
}

{character_string_literal} {
  // yylval->characterStringLiteral = parseCharacterStringLiteral(yytext, yyleng);
  NG_RETURN_TOKEN(CHARACTER_STRING_LITERAL);
}

.                           {
                                /**
                                 * Any other unmatched byte sequences will get us here,
                                 * including the non-ascii ones, which are negative
                                 * in terms of type of `signed char'. At the same time, because
                                 * Bison translates all negative tokens to EOF(i.e. YY_NULL),
                                 * so we have to cast illegal characters to type of `unsigned char'
                                 * This will make Bison receive an unknown token, which leads to
                                 * a syntax error.
                                 *
                                 * Please note that it is not Flex but Bison to regard illegal
                                 * characters as errors, in such case.
                                 */
                                std::cerr << "FLEX: . IS MATCHED" << std::endl;
                                return static_cast<unsigned char>(yytext[0]);

                                /**
                                 * Alternatively, we could report illegal characters by
                                 * throwing a `syntax_error' exception.
                                 * In such a way, we could distinguish illegal characters
                                 * from normal syntax errors, but at cost of poor performance
                                 * incurred by the expensive exception handling.
                                 */
                                // throw GraphParser::syntax_error(*yylloc, "char illegal");
                            }

%%
