%option c++
%option yyclass="GraphScanner"
%option nodefault noyywrap
%option 8bit never-interactive
/* %option stack */
%option yylineno
%option warn
%option debug
%option backup
%option perf-report

%{
#include "parser/GQLParser.h"
#include "parser/GraphScanner.h"
#include "GraphParser.hpp"
#include "graph/service/GraphFlags.h"

#define YY_USER_ACTION                  \
    yylloc->step();                     \
    yylloc->columns(yyleng);
%}

/* How does the input is matched?
 * When the generated scanner is run, it analyzes its input looking for strings which match any of its patterns.
 * If it finds more than one match, it takes the one matching the most text.
 * If it finds two or more matches of the same length, the rule listed first in the flex input file is chosen.
 *
 * What is a start condition?
 * flex provides a mechanism for conditionally activating rules. 
 * Any rule whose pattern is prefixed with ‘<sc>’ will only be active when the scanner
 * is in the start condition named sc.
 * `%s` is used to declare an inclusive start condition,
 * `%x` is used to declare an exclusive start condition.
 * A start condition is activated using the BEGIN action. Until the next BEGIN action is
 * executed, rules with the given start condition will be active and rules with other start
 * conditions will be inactive. If the start condition is inclusive, then rules with no start
 * conditions at all will also be active. If it is exclusive, then only rules qualified with
 * the start condition will be active. INITIAL is the default start condition.
 *
 * We use exclusive start conditions for single quoted character sequence,
 * double quoted character sequence, unbroken accent quoted character sequence,
 * and byte string literal.
 * Exclusive states:
 *  <SQCS> single quoted character sequence
 *  <DQCS> double quoted character sequence
 *  <UAQCS> unbroken accent quoted character sequence
 *  <BSL> byte string literal
 */

%x SQCS
%x DQCS
%x UAQCS
%x BSL

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

/* doubled_grave_accent "``" */
/* escaped_grave_accent {reverse_solidus}{grave_accent}|{doubled_grave_accent} */

escaped_reverse_solidus \\\\
escaped_quote \\'
escaped_double_quote \\\"
escaped_tab \\t
escaped_backspace \\b
escaped_newline \\n
escaped_carriage_return \\r
escaped_form_feed \\f
unicode_4_digit_escape_value \\u{hex_digit}{4}
unicode_6_digit_escape_value \\U{hex_digit}{6}
unicode_escape_value {unicode_4_digit_escape_value}|{unicode_6_digit_escape_value}

/* <whitespace> is any consecutive sequence of Unicode characters with the property White_Space.
NOTE 154 — These are the characters the Unicode General Category classes “Zs”, “Zl” and “Zp” together with the
characters: \u0009 (Horizontal Tabulation), \u000A (Line Feed), \u000B (Vertical Tabulation), \u000C (Form Feed),
\u000D (Carriage Return), and \u0085 (Next Line). */
white_space [ \t\n\v\f\r]
whitespace {white_space}+
newline [\n\r]
non_newline [^\n\r]

simple_comment_introducer {double_solidus}|{double_minus_sign}
simple_comment_character {non_newline}
/* TODO: maybe need to remove the last newline or make it be optional */
/* simple_comment {simple_comment_introducer}{simple_comment_character}*{newline} */
simple_comment {simple_comment_introducer}{simple_comment_character}*
/* bracketed_comment {bracketed_comment_introducer}{bracketed_comment_contents}{bracketed_comment_terminator} */
bracketed_comment "/*"([^*]|(\*+[^*/]))*\*+\/
/* We don't use flex state to match comment currently */
/* TODO: try to implenment comment by start condition */
comment {simple_comment}|{bracketed_comment}
separator ({whitespace}|{comment})+
/* TODO: In a <character string literal>, or <byte string literal>, a <separator> shall contain a <newline>(???) */
separator_with_newline {separator}

sqcs_start {quote}
sqcs_inside ([^\\\'])*
sqcs_stop {quote}
sqcs_continue {quote}{separator_with_newline}{quote}

dqcs_start {double_quote}
dqcs_inside ([^\\\"])*
dqcs_stop {double_quote}
dqcs_continue {double_quote}{separator_with_newline}{double_quote}

uaqcs_start {grave_accent}
uaqcs_inside ([^\\`])* 
uaqcs_stop {grave_accent}

bsl_start [Xx]{quote}
bsl_inside {space}*(({hex_digit}{space}*){2})*
bsl_stop {quote}
bsl_continue {quote}{separator_with_newline}{quote}

/* refer to https://www.fileformat.info/info/unicode/category/Nd/list.htm */
/* other_digit */
/* digit [0-9]|other_digit */
digit [0-9]
hex_digit [0-9A-Fa-f]
octal_digit [0-7]
binary_digit [01]
unsigned_decimal_integer {digit}({underscore}?{digit})*
unsigned_hexadecimal_integer 0x({underscore}?{hex_digit})+
unsigned_octal_integer 0o({underscore}?{octal_digit})+
unsigned_binary_integer 0b({underscore}?{binary_digit})+
unsigned_integer {unsigned_decimal_integer}|{unsigned_hexadecimal_integer}|{unsigned_octal_integer}|{unsigned_binary_integer}
/* a little change here */
exact_numeric_literal_with_period {unsigned_decimal_integer}{period}{unsigned_decimal_integer}?|{period}{unsigned_decimal_integer}
/* exact_numeric_literal {unsigned_integer}|{unsigned_decimal_integer}{period}{unsigned_decimal_integer}?|{period}{unsigned_decimal_integer} */
sign [+-]
signed_decimal_integer {sign}?{unsigned_decimal_integer}
exact_decimal_numeric_literal {unsigned_decimal_integer}|{unsigned_decimal_integer}({period}{unsigned_decimal_integer}?)?|{period}{unsigned_decimal_integer}
mantissa {exact_decimal_numeric_literal}
exponent {signed_decimal_integer}
approximate_numeric_literal {mantissa}[Ee]{exponent}
unsigned_floating_point {exact_numeric_literal_with_period}|{approximate_numeric_literal}

identifier_start [A-Za-z\x80-\xff_]
identifier_extend [A-Za-z\x80-\xff_0-9\$]
/* The pattern regular_identifier could match a keyword or an unverified regular identifier */
regular_identifier {identifier_start}{identifier_extend}*
extended_identifier {identifier_extend}*
parameter_name_1 \${extended_identifier}

/* string_literal_character [^{escaped_character}] */
/* Why doesn't escaped_character contains escaped accent(\`)? */
/* escaped_character {escaped_reverse_solidus}|{escaped_quote}|{escaped_double_quote}|{escaped_tab}|{escaped_backspace}|{escaped_newline}|{escaped_carriage_return}|{escaped_form_feed}|{unicode_escape_value} */
/* unbroken_single_quoted_character_sequence \'([^\\\']|{escaped_character})*\'
unbroken_double_quoted_character_sequence \"([^\\\"]|{escaped_character})*\"
unbroken_accent_quoted_character_sequence `([^\\`]|{escaped_character})*` */
/* TODO: Consider to restrict the following two patterns to let them just match the single_quoted_character_sequence which contains seprator. */
/* single_quoted_character_sequence {unbroken_single_quoted_character_sequence}({separator}{unbroken_single_quoted_character_sequence})*
double_quoted_character_sequence {unbroken_double_quoted_character_sequence}({separator}{unbroken_double_quoted_character_sequence})*
unbroken_character_string_literal {unbroken_single_quoted_character_sequence}|{unbroken_double_quoted_character_sequence}
character_string_literal {single_quoted_character_sequence}|{double_quoted_character_sequence}
byte_string_literal_introducer [Xx] */
/* unbroken_byte_string_literal_contents {quote}{space}*({hex_digit}{space}*{hex_digit}{space}*)*{quote} */
/* unbroken_byte_string_literal_contents {space}*(({hex_digit}{space}*){2})* */
/* byte_string_literal [Xx]{unbroken_byte_string_literal_contents}({separator}{unbroken_byte_string_literal_contents})* */

/* delimited_identifier {double_quoted_character_sequence}|{unbroken_accent_quoted_character_sequence} */
/* separated_identifier {extended_identifier}|{delimited_identifier} */
/* identifier {regular_identifier}|{delimited_identifier} */

/* parameter_name \${separated_identifier} */


/* Many of them coudl be eliminated if glr is ready */
is_source (?i:IS{separator}SOURCE)
is_not_source (?i:IS{separator}NOT{separator}SOURCE)
is_destination (?i:IS{separator}DESTINATION)
is_not_destination (?i:IS{separator}NOT{separator}DESTINATION)
is_null (?i:IS{separator}NULL)
is_not_null (?i:IS{separator}NOT{separator}NULL)
is_not (?i:IS{separator}NOT)
is_directed (?i:IS{separator}DIRECTED)
is_not_directed (?i:IS{separator}NOT{separator}DIRECTED)
is_labeled (?i:IS{separator}LABELED)
is_not_labeled (?i:IS{separator}NOT{separator}LABELED)
session_close (?i:SESSION{separator}CLOSE)
/* comma_optional (?i:{comma}{separator}OPTIONAL) */
group_by (?i:GROUP{separator}BY)
graph_synonym (?i:PROPERTY{separator}GRAPH)
graph_type_synonym (?i:(PROPERTY{separator})?GRAPH{separator}TYPE)
binding_table_synonym (?i:BINDING{separator}TABLE)
solidus_double_period (?i:{solidus}{separator}?{double_period})


%%

 /* Flex rules section */

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
{dollar_sign} {
  NG_RETURN_TOKEN(DOLLAR_SIGN);
}
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
  /* {quote} {
    NG_RETURN_TOKEN(QUOTE);
  } */
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

 /* <*>{newline} */
{newline} {
  yylineno++;
  yylloc->lines(yyleng);
}

{whitespace} { }
 /* TODO: comment leads to a lot of backing up */
{comment} { }

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
{is_null} {
  NG_RETURN_TOKEN(IS_NULL);
}
{is_not_null} {
  NG_RETURN_TOKEN(IS_NOT_NULL);
}
{is_not} {
  NG_RETURN_TOKEN(IS_NOT);
}
{is_directed} {
  NG_RETURN_TOKEN(IS_DIRECTED);
}
{is_not_directed} {
  NG_RETURN_TOKEN(IS_NOT_DIRECTED);
}
{is_labeled} {
  NG_RETURN_TOKEN(IS_LABELED);
}
{is_not_labeled} {
  NG_RETURN_TOKEN(IS_NOT_LABELED);
}
{session_close} {
  NG_RETURN_TOKEN(SESSION_CLOSE);
}
  /* {comma_optional} {
    NG_RETURN_TOKEN(COMMA_OPTIONAL);
  } */
{group_by} {
  NG_RETURN_TOKEN(GROUP_BY);
}
{graph_synonym} {
  NG_RETURN_TOKEN(GRAPH_SYNONYM);
}
{graph_type_synonym} {
  NG_RETURN_TOKEN(GRAPH_TYPE_SYNONYM);
}
{binding_table_synonym} {
  NG_RETURN_TOKEN(BINDING_TABLE_SYNONYM);
}
{solidus_double_period} {
  NG_RETURN_TOKEN(SOLIDUS_DOUBLE_PERIOD);
}

{regular_identifier} {
  /* Check against the keyword lists. */
  std::string text(yytext, yyleng);
  auto& keyword = keywordLookup(text);
  if (keyword != kInvalidKeyword) {
    if (keyword.category == Keyword::Category::NON_RESERVED_KEYWORD) {
      yylval->build(text);
    }
    return keyword.token;
  }

  /* Not a keyword. Check if it is a legal unicode identifier. */
  if (text.empty()) {
    throw GraphParser::syntax_error(*yylloc, "Zero-length regular identifier: ");
  }
  truncateIdentifier(text);
  if (!isValidUnicodeIdentifier(text)) {
    throw GraphParser::syntax_error(*yylloc, "illegal regular identifier");
  }
  yylval->build(text);
  NG_RETURN_TOKEN(REGULAR_IDENTIFIER);
}

{parameter_name_1} {
  std::string text(yytext+1, yyleng-1);
  if (text.empty()) {
    throw GraphParser::syntax_error(*yylloc, "Zero-length extended identifier: ");
  }
  truncateIdentifier(text);
  yylval->build(text);
  NG_RETURN_TOKEN(PARAMETER_NAME_1);
}

{sqcs_start} {
  BEGIN(SQCS);
}
{dqcs_start} {
  BEGIN(DQCS);
}
{uaqcs_start} {
  BEGIN(UAQCS);
}
{bsl_start} {
  BEGIN(BSL);
}
<SQCS>{sqcs_inside} {
  str_.append(yytext, yyleng);
}
<DQCS>{dqcs_inside} {
  str_.append(yytext, yyleng);
}
<UAQCS>{uaqcs_inside} {
  str_.append(yytext, yyleng);
}
<BSL>{bsl_inside} {
  std::string text(yytext, yyleng);
  boost::erase_all(text, " ");
  DCHECK_EQ(text.size() % 2, 0);
  std::string result(text.size() / 2, '\0');
  for (size_t i = 0; i < text.size() - 1; i += 2) {
    result[i / 2] = (std::strtoul(text.substr(i, 2).c_str(), nullptr, 16) & 0xFF);
  }
  str_.append(result);
}
<SQCS,DQCS,UAQCS>{escaped_reverse_solidus} {
  str_.push_back('\\');
}
<SQCS,DQCS,UAQCS>{escaped_quote} {
  str_.push_back('\'');
}
<SQCS,DQCS,UAQCS>{escaped_double_quote} {
  str_.push_back('\"');
}
<SQCS,DQCS,UAQCS>{escaped_tab} {
  str_.push_back('\t');
}
<SQCS,DQCS,UAQCS>{escaped_backspace} {
  str_.push_back('\b');
}
<SQCS,DQCS,UAQCS>{escaped_newline} {
  str_.push_back('\n');
}
<SQCS,DQCS,UAQCS>{escaped_carriage_return} {
  str_.push_back('\r');
}
<SQCS,DQCS,UAQCS>{escaped_form_feed} {
  str_.push_back('\f');
}
<SQCS,DQCS,UAQCS>{unicode_escape_value} {
  std::string text(yytext+2, yyleng-2);
  auto encoded = folly::codePointToUtf8(stoul(text, nullptr, 16));
  str_.append(encoded);
}
<SQCS>{sqcs_continue} {
  sqcsSeparated_ = true;
}
<DQCS>{dqcs_continue} {
  dqcsSeparated_ = true;
}
<BSL>{bsl_continue} {

}
<SQCS>{sqcs_stop} {
  yylval->build(str_);
  BEGIN(INITIAL);
  if (sqcsSeparated_) {
    sqcsSeparated_ = false;
    NG_RETURN_TOKEN(BROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE);
  }
  NG_RETURN_TOKEN(UNBROKEN_SINGLE_QUOTED_CHARACTER_SEQUENCE);
}
<DQCS>{dqcs_stop} {
  yylval->build(str_);
  BEGIN(INITIAL);
  if (dqcsSeparated_) {
    dqcsSeparated_ = false;
    NG_RETURN_TOKEN(BROKEN_DOUBLE_QUOTED_CHARACTER_SEQUENCE);
  }
  NG_RETURN_TOKEN(UNBROKEN_DOUBLE_QUOTED_CHARACTER_SEQUENCE);
}
<UAQCS>{uaqcs_stop} {
  yylval->build(str_);
  BEGIN(INITIAL);
  NG_RETURN_TOKEN(UNBROKEN_ACCENT_QUOTED_CHARACTER_SEQUENCE);
}
<BSL>{bsl_stop} {
  yylval->build(str_);
  BEGIN(INITIAL);
  NG_RETURN_TOKEN(BYTE_STRING_LITERAL);
}
<SQCS>[^'] {
  throw GraphParser::syntax_error(*yylloc, "Invalid unbroken single quoted character sequence: ");
}
<DQCS>[^"] {
  throw GraphParser::syntax_error(*yylloc, "Invalid unbroken double quoted character sequence: ");
}
<UAQCS>[^`] {
  throw GraphParser::syntax_error(*yylloc, "Invalid unbroken accent quoted character sequence: ");
}
<BSL>[^'] {
  throw GraphParser::syntax_error(*yylloc, "Invalid byte string literal: ");
}
<SQCS><<EOF>> {
  throw GraphParser::syntax_error(*yylloc, "Unterminated single quoted character sequence: ");
}
<DQCS><<EOF>> {
  throw GraphParser::syntax_error(*yylloc, "Unterminated double quoted character sequence: ");
}
<UAQCS><<EOF>> {
  throw GraphParser::syntax_error(*yylloc, "Unterminated accent quoted character sequence: ");
}
<BSL><<EOF>> {
  throw GraphParser::syntax_error(*yylloc, "Unterminated byte string literal: ");
}

  /* {delimited_identifier} {
    // yylval->build(parseDelimitedIdentifier(std::string(yytext, yyleng)));
    NG_RETURN_TOKEN(DELIMITED_IDENTIFIER);
  }

  {parameter_name} {
    // yylval->build(parseSeparatedIdentifier(std::strign(yytext+1, yyleng-1)));
    NG_RETURN_TOKEN(PARAMETER_NAME);
  } */

 /* Both of the following two patterns can match an <unbroken character string literal>,
  * but flex will choose the first pattern because it's listed first.
  * The reason why we do need the two patterns that might match the same input is because
  * some parser rules accept a <character string literal> while some just accept an <unbroken character string literal>.
  */
  /* {unbroken_character_string_literal} {
    yylval->build(std::string(yytext+1, yyleng - 2));
    NG_RETURN_TOKEN(UNBROKEN_CHARACTER_STRING_LITERAL);
  } */
  /* {character_string_literal} {
    // yylval->build(parseCharacterStringLiteral(std::string(yytext, yyleng)));
    NG_RETURN_TOKEN(CHARACTER_STRING_LITERAL);
  } */

 /* The pattern unsigned_floating_point could also match an <unsigned integer>.
  * Similar to what was said in the previous comment.
  */
{unsigned_decimal_integer} {
  std::string text(yytext, yyleng);
  boost::erase_all(text, "_");
  // TODO: GQL supports up to UINT256
  uint64_t val = folly::to<uint64_t>(text);
  yylval->build(val);
  std::cerr << "dec:" << val << std::endl;
  NG_RETURN_TOKEN(UNSIGNED_INTEGER);
}
{unsigned_hexadecimal_integer} {
  std::string text(yytext + 2, yyleng - 2);
  std::cerr << "hex: " << text << std::endl;
  boost::erase_all(text, "_");
  std::cerr << "hex2: " << text << std::endl;
  // TODO: GQL supports up to UINT256
  uint64_t val = 0;
  sscanf(text.c_str(), "%lx", &val);
  yylval->build(val);
  std::cerr << "hex:" << val << std::endl;
  NG_RETURN_TOKEN(UNSIGNED_INTEGER);
}
{unsigned_octal_integer} {
  std::string text(yytext + 2, yyleng - 2);
  std::cerr << "oct: " << text << std::endl;
  boost::erase_all(text, "_");
  std::cerr << "oct2: " << text << std::endl;
  // TODO: GQL supports up to UINT256
  uint64_t val = 0;
  sscanf(text.c_str(), "%lo", &val);
  yylval->build(val);
  std::cerr << "oct:" << val << std::endl;
  NG_RETURN_TOKEN(UNSIGNED_INTEGER);
}
{unsigned_binary_integer} {
  std::string text(yytext + 2, yyleng - 2);
  boost::erase_all(text, "_");
  // TODO: GQL supports up to UINT256
  uint64_t val = std::stoull(text, nullptr, 2);
  yylval->build(val);
  std::cerr << "bin:" << val << std::endl;
  NG_RETURN_TOKEN(UNSIGNED_INTEGER);
}
{unsigned_floating_point} {
  std::string text(yytext, yyleng);
  try {
    // TODO: GQL supports up to FLOAT256
    double val = folly::to<double>(text);
    yylval->build(val);
    std::cerr << "float:" << val << std::endl;
  } catch (...) {
    throw GraphParser::syntax_error(*yylloc, "Out of range:");
  }
  NG_RETURN_TOKEN(UNSIGNED_FLOATING_POINT);
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
