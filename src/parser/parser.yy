%language "C++"
%skeleton "lalr1.cc"
%no-lines 
%locations
%define api.namespace { nebula }
%define api.parser.class { GraphParser }
%lex-param { nebula::GraphScanner& scanner }
%parse-param { nebula::GraphScanner& scanner }
%parse-param { std::string &errmsg }
%parse-param { nebula::Sentence** sentences }
%parse-param { nebula::graph::QueryContext* qctx }

// Enable run-time traces (yydebug).
%define parse.trace
// %define parse.error verbose

// Define token.
// %define api.value.type variant
// %define api.token.constructor
%define api.token.prefix {TOK_}


%code requires {
#include <iostream>
#include <sstream>
#include <string>
#include <cstddef>
#include "parser/ExplainSentence.h"
#include "parser/SequentialSentences.h"
#include "interface/gen-cpp2/meta_types.h"
#include "common/expression/AttributeExpression.h"
#include "common/expression/LabelAttributeExpression.h"
#include "common/expression/VariableExpression.h"
#include "common/expression/CaseExpression.h"
#include "common/expression/TextSearchExpression.h"
#include "common/expression/PredicateExpression.h"
#include "common/expression/ListComprehensionExpression.h"
#include "common/expression/AggregateExpression.h"
#include "common/function/FunctionManager.h"
#include "common/expression/ReduceExpression.h"
#include "graph/util/ParserUtil.h"
#include "graph/util/ExpressionUtils.h"
#include "graph/context/QueryContext.h"
#include "graph/util/SchemaUtil.h"

namespace nebula {

class GraphScanner;

}

static constexpr size_t MAX_ABS_INTEGER = 9223372036854775808ULL;
static constexpr size_t kCommentLengthLimit = 256;

}

%code {
    #include "GraphScanner.h"
    static int yylex(nebula::GraphParser::semantic_type* yylval,
                     nebula::GraphParser::location_type *yylloc,
                     nebula::GraphScanner& scanner);

    void ifOutOfRange(const int64_t input,
                      const nebula::GraphParser::location_type& loc);
}

// case-sensitive reserved keyword
%token  endNode inDegree lTrim outDegree percentileCont percentileDist rTrim
        startNode stDev stDevP tail toLower toUpper

// case-insensitive reserved keyword
%token  ABS ACOS ADD AGGREGATE ALIAS ALL ALL_DIFFERENT AND ANY ARRAY AS
        ASC ASCENDING ASIN AT ATAN AVG
        BINARY BIGINT BOOL BOOLEAN BOTH BY BYTE_LENGTH BYTES
        CALL CASE CAST CATALOG CEIL CEILING CHARACTER CHARACTER_LENGTH CLEAR
        CLONE CLOSE COALESCE COLLECT COMMIT CONSTRAINT CONSTANT CONSTRUCT COPY
        COS COSH COST COT COUNT CURRENT_DATE CURRENT_GRAPH CURRENT_PROPERTY_GRAPH
        CURRENT_ROLE CURRENT_SCHEMA CURRENT_TIME CURRENT_TIMESTAMP CURRENT_USER CREATE
        DATA DATE DATETIME DAY DEC DECIMAL DEFAULT DEGREES DELETE DETACH DESC
        DESCENDING DIRECTORIES DIRECTORY DISTINCT DO DOUBLE DROP DURATION
        ELEMENT_ID ELSE END ENDS EMPTY_BINDING_TABLE EMPTY_GRAPH
        EMPTY_PROPERTY_GRAPH EMPTY_TABLE EXCEPT EXISTS EXISTING EXP EXPLAIN
        FALSE FILTER FLOAT FLOAT16 FLOAT32 FLOAT64 FLOAT128 FLOAT256
        FLOOR FOR FROM FUNCTION FUNCTIONS
        GQLSTATUS GRANT GROUP
        HAVING HOME_GRAPH HOME_PROPERTY_GRAPH HOME_SCHEMA HOUR
        IN INSERT INT INTEGER INT8 INTEGER8 INT16 INTEGER16 INT32 INTEGER32 INTERVAL
        INT64 INTEGER64 INT128 INTEGER128 INT256 INTEGER256 INTERSECT IF IS
        KEEP
        LEADING LEFT LENGTH LET LIKE LIKE_REGEX LIMIT LIST LN
        LOCALDATETIME LOCALTIME LOCALTIMESTAMP LOG LOG10 LOWER
        MANDATORY MAP MATCH MERGE MAX MIN MINUTE MOD MONTH MULTI MULTIPLE MULTISET
        NEW NOT NORMALIZE NOTHING NULL NULLS NULLIF NUMERIC
        OCCURRENCES_REGEX OCTET_LENGTH OF OFFSET ON OPTIONAL OR ORDER ORDERED OTHERWISE
        PARAMETER PATH PATHS PARTITION POSITION_REGEX POWER PRECISION PROCEDURE
        PROCEDURES PRODUCT PROFILE PROJECT
        QUERIES QUERY
        RADIANS REAL RECORD RECORDS REFERENCE REMOVE RENAME REPLACE REQUIRE
        RESET RESULT RETURN REVOKE RIGHT ROLLBACK
        SAME SCALAR SCHEMA SCHEMAS SCHEMATA SECOND SELECT SESSION SET SKIP SIGNED SIN
        SINGLE SINH SMALLINT SQRT START STARTS STRING SUBSTRING SUBSTRING_REGEX SUM
        TAN TANH THEN TIME TIMESTAMP TRAILING TRANSLATE_REGEX TRIM TRUE TRUNCATE
        UINT UINT8 UINT16 UINT32 UINT64 UINT128 UINT256 UNION UNIT
        UNIT_BINDING_TABLE UNIT_TABLE UNIQUE UNNEST UNKNOWN UNSIGNED UNWIND UPPER USE
        VALUE VALUES VARBINARY VARCHAR
        WHEN WHERE WITH WITHOUT
        XOR
        YEAR YIELD
        ZERO

// case-insensitive non-reserved keyword
%token  ACYCLIC
        BINDING
        CLASS_ORIGIN COMMAND_FUNCTION COMMAND_FUNCTION_CODE CONDITION_NUMBER CONNECTING
        DESTINATION DIRECTED
        EDGE EDGES
        FINAL FIRST
        GRAPH GRAPHS GROUPS
        INDEX
        LAST LABEL LABELED LABELS
        MESSAGE_TEXT MORE MUTABLE
        NFC NFD NFKC NFKD NODE NODES NORMALIZED NUMBER
        ONLY ORDINALITY
        PATTERN PATTERNS PROPERTY PROPERTIES
        READ RELATIONSHIP RELATIONSHIPS RETURNED_GQLSTATUS
        SHORTEST SIMPLE SOURCE SUBCLASS_ORIGIN
        TABLE TABLES TIES TO TRAIL TRANSACTION TYPE TYPES
        UNDIRECTED
        VERTEX VERTICES
        WALK WRITE
        ZONE

// special

%token IS_SOURCE IS_NOT_SOURCE IS_DESTINATION IS_NOT_DESTINATION IS_NULL IS_NOT_NULL IS_NOT IS_DIRECTED IS_NOT_DIRECTED IS_LABELED IS_NOT_LABELED
%token SESSION_CLEAR SESSION_CLOSE SESSION_REMOVE SESSION_SET
%token COMMA_OPTIONAL
%token GROUP_BY
%token LEFT_PAREN_ASTERISK_RIGHT_PAREN
%token NODE_SYNONYM EDGE_SYNONYM GRAPH_SYNONYM GRAPH_TYPE_SYNONYM BINDING_TABLE_SYNONYM
%token IF_EXISTS IF_NOT_EXISTS
%token OPTIONAL_MATCH OPTIONAL_INSERT OPTIONAL_CALL MANDATORY_MATCH MANDATORY_CALL
%token OPTIONAL_LET MANDATORY_LET OPTIONAL_FOR MANDATORY_FOR
%token SOLIDUS_DOUBLE_PERIOD // TODO CHECK if SOLIDUS and DOUBLE_PERIOD could be used separately
// 没有解决冲突的合并
// %token TIME_ZONE CATALOG_PROCEDURE COPY_OF
// %token EQUALS_OPERATOR_TRUE EQUALS_OPERATOR_FALSE EQUALS_OPERATOR_UNKNOWN EQUALS_OPERATOR_NULL
// %token NOT_EQUALS_OPERATOR_TRUE NOT_EQUALS_OPERATOR_FALSE NOT_EQUALS_OPERATOR_UNKNOWN NOT_EQUALS_OPERATOR_NULL
// %token IS_TRUE IS_FALSE IS_UNKNOWN IS_NOT_TRUE IS_NOT_FALSE IS_NOT_UNKWON

// dummy token
%token DUMMY_CATALOG_PROCEDURE_FLAG DUMMY_DATA_PROCEDURE_FLAG DUMMY_QUERY_FLAG DUMMY_FUNCTION_FLAG
%token DUMMY_AMBIENT_QUERY_STMT 

// single char operators
%token  AMPERSAND ASTERISK
        COLON COMMA
        EQUALS_OPERATOR EXCLAMATION_MARK
        LEFT_BRACE LEFT_BRACKET LEFT_PAREN LEFT_ANGLE_BRACKET
        MINUS_SIGN
        PERCENT PERIOD PLUS_SIGN
        QUESTION_MARK QUOTE
        RIGHT_ANGLE_BRACKET RIGHT_BRACE RIGHT_BRACKET RIGHT_PAREN
        SEMICOLON SOLIDUS
        TILDE
        VERTICAL_BAR

// multi char operators
%token  BRACKET_RIGHT_ARROW BRACKET_TILDE_RIGHT_ARROW
        CONCATENATION_OPERATOR
        DOUBLE_COLON DOUBLE_PERIOD
        GREATER_THAN_OR_EQUALS_OPERATOR
        LEFT_ARROW LEFT_ARROW_TILDE LEFT_ARROW_BRACKET LEFT_ARROW_TILDE_BRACKET
        LEFT_MINUS_RIGHT LEFT_MINUS_SLASH LEFT_TILDE_SLASH LESS_THAN_OR_EQUALS_OPERATOR
        MINUS_LEFT_BRACKET MINUS_SLASH MULTISET_ALTERNATION_OPERATOR
        NOT_EQUALS_OPERATOR
        RIGHT_ARROW RIGHT_BRACKET_MINUS RIGHT_BRACKET_TILDE
        SLASH_MINUS SLASH_MINUS_RIGHT SLASH_TILDE SLASH_TILDE_RIGHT
        TILDE_LEFT_BRACKET TILDE_RIGHT_ARROW TILDE_SLASH

%token REGULAR_IDENTIFIER DELIMITED_IDENTIFIER
%token PARAMETER_NAME
%token UNSIGNED_NUMERIC_LITERAL
%token BYTE_STRING_LITERAL
%token UNBROKEN_CHARACTER_STRING_LITERAL
%token CHARACTER_STRING_LITERAL
%token UNSIGNED_DECIMAL_INTEGER UNSIGNED_HEXADECIMAL_INTEGER UNSIGNED_OCTAL_INTEGER UNSIGNED_BINARY_INTEGER

// Precedence: lowest to highest.
// %nonassoc   SET
// %left       UNION EXCEPT
// %left       INTERSECT
// %left       OR
// %left       XOR
// %left       AND
// %right      NOT EXCLAMATION_MARK
// // %nonassoc   IS ISNULL NOTNULL                                // IS sets precedence for IS NULL, etc.
// %left       LEFT_ANGLE_BRACKET RIGHT_ANGLE_BRACKET EQUALS_OPERATOR LESS_THAN_OR_EQUALS_OPERATOR GREATER_THAN_OR_EQUALS_OPERATOR NOT_EQUALS_OPERATOR
// %nonassoc   LIKE

// %left   VERTICAL_BAR
// %left   AMPERSAND SOLIDUS PERCENT
// %left   MINUS_SIGN PLUS_SIGN
// %left   ASTERISK

%nonassoc LOWER_THAN_PROCEDURE_SPECIFICATION
%nonassoc AGGREGATE AT CALL CATALOG CREATE DELETE DETACH DO DROP END FILTER FOR FROM FUNCTION
          INSERT LET MANDATORY MATCH MERGE OPTIONAL PROCEDURE PROJECT QUERY
          REMOVE RETURN SELECT SET USE VALUE WHEN GRAPH_SYNONYM BINDING_TABLE_SYNONYM
          OPTIONAL_MATCH OPTIONAL_INSERT OPTIONAL_CALL MANDATORY_MATCH MANDATORY_CALL
          OPTIONAL_LET MANDATORY_LET OPTIONAL_FOR MANDATORY_FOR LEFT_BRACE
%nonassoc LOWER_THAN_LIMIT
%nonassoc ORDER LIMIT OFFSET SKIP
%nonassoc LOWER_THAN_END_TRANSACTION_COMMAND
%nonassoc COMMIT ROLLBACK
%nonassoc LOWER_THAN_RIGHT_PAREN
%nonassoc RIGHT_PAREN


%left       MULTISET_UNION MULTISET_EXCEPT
%left       MULTISET_INTERSECT

%left       CONCATENATION_OPERATOR  // TODO

%left       OR XOR  // TODO
%left       AND
%left       HIGHER_THAN_AND  // TODO: %left?
%right      NOT
%nonassoc   IS IS_NOT IS_NULL IS_NOT_NULL // TODO
%nonassoc   EQUALS_OPERATOR NOT_EQUALS_OPERATOR LEFT_ANGLE_BRACKET RIGHT_ANGLE_BRACKET LESS_THAN_OR_EQUALS_OPERATOR GREATER_THAN_OR_EQUALS_OPERATOR // TODO
%left       PLUS_SIGN MINUS_SIGN

%nonassoc   LOWER_THAN_SOLIDUS  // TODO
%left       ASTERISK SOLIDUS
%right      UNARY_MINUS // TODO %right?


%start GQL_request

%%

// Chapter 6 GQL-requests
// Section 6.1 <GQL-request>
GQL_request
    : GQL_program {

    }
    | request_parameter_set SEMICOLON GQL_program {

    }
    ;

// Section 6.2 <request parameter set>
request_parameter_set 
    : request_parameter {

    }
    | request_parameter_set COMMA request_parameter {

    }
    ;

request_parameter
    : parameter_definition {

    }
    ;

// Section 6.3 <GQL-program>
GQL_program
    : main_activity {

    }
    | preamble main_activity {

    }
    ;

main_activity
    : session_activity {

    }
    | transaction_session_activitiy_list opt_session_close_command {

    }
    | session_activity transaction_session_activitiy_list opt_session_close_command {

    }
    | session_close_command {

    }
    ;

opt_session_activity
    : %empty {

    }
    | session_activity {

    }
    ;

opt_session_close_command
    : %empty {

    }
    | session_close_command {

    }
    ;

transaction_session_activitiy_list
    : transaction_session_activity {

    }
    | transaction_session_activitiy_list transaction_session_activity {

    }
    ;

transaction_session_activity
    : transaction_activity {

    }
    | transaction_activity session_activity {

    }
    ;


session_activity
    : session_clear_command {

    }
    | session_clear_command session_parameter_command_list {

    }
    | session_parameter_command_list {

    }
    ;

opt_session_parameter_command_list
    : %empty {

    }
    | session_parameter_command_list {

    }
    ;

session_parameter_command_list
    : session_parameter_command {

    }
    | session_parameter_command_list session_parameter_command {

    }
    ;

session_parameter_command
    : session_set_command {

    }
    | session_remove_command {

    }
    ;

// TODO
transaction_activity
    : start_transaction_command %prec LOWER_THAN_PROCEDURE_SPECIFICATION {
    
    }
    | start_transaction_command procedure_specification %prec LOWER_THAN_END_TRANSACTION_COMMAND {
      
    }
    | start_transaction_command procedure_specification end_transaction_command {

    }
    | procedure_specification %prec LOWER_THAN_END_TRANSACTION_COMMAND {

    }
    | procedure_specification end_transaction_command {

    }
    | end_transaction_command {

    }
    ;

// Section 6.4 <preamble>
preamble
    : preamble_option {
    }
    | preamble COMMA preamble_option {

    }
    ;

preamble_option
    : PROFILE {

    }
    | EXPLAIN {

    }
    | preamble_option_identifier {
      
    }
    | preamble_option_identifier EQUALS_OPERATOR literal {

    }
    ;

preamble_option_identifier
    : identifier {

    }
    ;

// Chapter 7 Session management
// Section 7.1 <session set command>
session_set_command
    : SESSION_SET session_set_schema_clause {

    }
    | SESSION_SET session_set_graph_clause {

    }
    | SESSION_SET session_set_time_zone_clause {

    }
    | SESSION_SET session_set_parameter_clause {

    }
    ;

session_set_schema_clause
    : SCHEMA schema_reference {

    }
    ;

session_set_graph_clause
    : graph_resolution_expression {

    }
    ;

session_set_time_zone_clause
    : TIME ZONE set_time_zone_value {

    }
    ;

// TODO: string_value_expression is changed to untyped_value_expression
set_time_zone_value
    : untyped_value_expression {

    }
    ;

session_set_parameter_clause
    : session_parameter opt_if_not_exists {

    }
    | session_parameter_flag session_parameter opt_if_not_exists {

    }
    ;

opt_session_parameter_flag
    : %empty {

    }
    | session_parameter_flag {

    }
    ;

// TODO
session_parameter
    :
    // parameter_definition {

    // }
    // |
    PARAMETER parameter_definition {

    }
    ;

session_parameter_flag
    : MUTABLE {

    }
    | FINAL {

    }
    ;

// Section 7.2 <session remove command>
session_remove_command
    : SESSION_REMOVE parameter opt_if_exists {

    }
    // | REMOVE parameter opt_if_exists {

    // }
    ;

// Section 7.3 <session clear command>
session_clear_command
    : CLEAR
    | SESSION_CLEAR {

    }
    ;

// Section 7.4 <session close command>
session_close_command
    : CLOSE
    | SESSION_CLOSE {

    }
    ;

// Section 8.1 <start transaction command>
start_transaction_command
    : START TRANSACTION {

    }
    | START TRANSACTION transaction_characteristics {

    }
    ;

// Section 8.2 <end transaction command>
end_transaction_command
    : commit_command {

    }
    | rollback_command {

    }
    ;

// Section 8.3 <transaction_characteristics>
transaction_characteristics
    : transaction_mode {

    }
    | transaction_characteristics COMMA transaction_mode {

    }
    ;

transaction_mode
    : transaction_access_mode {

    }
    // TODO
    // | implementation_defined_access_mode {

    // }
    ;

transaction_access_mode
    : READ ONLY {

    }
    | READ WRITE {

    }
    ;

// TODO
/* implementation_defined_access_mode
    : !! See_the_Syntax_Rules.
    ; */


// Section 8.4 <rollback command>
rollback_command
    : ROLLBACK {

    }
    ;

// Section 8.5 <commit command>
commit_command
    : COMMIT {

    }
    ;

// Chapter 9 Procedures
// Section 9.1 <procedure specification>
nested_procedure_specification
    : LEFT_BRACE procedure_specification RIGHT_BRACE {

    }
    ;

// Rules for the derivation of the procedure signature of a <procedure specification>, a
// <catalog-modifying procedure specification>, a <data-modifying procedure specification>,
// a <query specification>, and a <function specification> from their <procedure body> need
// to be specified. See Possible Problem GQL-021 .
// TODO
procedure_specification
    : catalog_modifying_procedure_specification {

    }
    | data_modifying_procedure_specification {

    }
    | query_specification {

    }
    | function_specification {

    }
    ;

// INACTIVE PARSING RULES
// nested_catalog_modifying_procedure_specification
//     : LEFT_BRACE catalog_modifying_procedure_specification RIGHT_BRACE {

//     }
//     ;

catalog_modifying_procedure_specification
    : 
    // !! Predicative production rule.
    procedure_body stDev {

    }
    ;

nested_data_modifying_procedure_specification
    : LEFT_BRACE data_modifying_procedure_specification RIGHT_BRACE {

    }
    ;

data_modifying_procedure_specification
    :
    // !! Predicative production rule.
    procedure_body stDevP {

    }
    ;

// Section 9.2 <query specification>
nested_query_specification
    : LEFT_BRACE query_specification RIGHT_BRACE {

    }
    ;

query_specification
    :
    // !! Predicative production rule.
    procedure_body percentileCont {

    }
    ;

// Section 9.3 <function specification>
nested_function_specification
    : LEFT_BRACE function_specification RIGHT_BRACE {

    }
    ;

function_specification
    :
    // !! Predicative production rule.
    procedure_body percentileDist {

    }
    ;

// Section 9.4 <procedure body>
procedure_body
    : statement_block {

    }
    | static_variable_definition_block statement_block {

    }
    | binding_variable_definition_block statement_block {

    }
    | static_variable_definition_block binding_variable_definition_block statement_block {

    }
    ;

opt_static_variable_definition_block
    : %empty {

    }
    | static_variable_definition_block {

    }
    ;

opt_binding_variable_definition_block
    : %empty {

    }
    | binding_variable_definition_block {

    }
    ;

static_variable_definition_block
    : static_variable_definition {

    }
    | static_variable_definition_block static_variable_definition {

    }
    ;

binding_variable_definition_block
    : binding_variable_definition {

    }
    | binding_variable_definition_block binding_variable_definition {

    }
    ;

statement_block
    : statement {

    }
    | statement_block then_statement {

    }
    ;

then_statement
    : THEN statement {

    }
    | THEN yield_clause statement {

    }
    ;

// Chapter 10 Variable and parameter declarations and definitions
// Section 10.1 Static variable definitions
static_variable_definition
    : procedure_variable_definition {

    }
    | query_variable_definition {

    }
    | function_variable_definition {

    }
    ;

as_or_equals
    : AS {
      
    }
    | EQUALS_OPERATOR {

    }
    ;

// Section 10.2 Procedure variable definition
procedure_variable_definition
    : PROCEDURE procedure_variable of_type_signature procedure_initializer {

    }
    | CATALOG PROCEDURE procedure_variable of_type_signature procedure_initializer {

    }
    ;

procedure_variable
    : static_variable_name {

    }
    ;

procedure_initializer
    : as_or_equals procedure_reference {

    }
    | nested_procedure_specification {

    }
    | AS nested_procedure_specification {

    }
    | COLON catalog_procedure_reference {

    }
    ;

// Section 10.3 Query variable definition
query_variable_definition
    : QUERY query_variable of_type_signature query_initializer {

    }
    ;

query_variable
    : static_variable_name {

    }
    ;

query_initializer
    : as_or_equals query_reference {

    }
    | nested_query_specification {

    } AS nested_query_specification {

    }
    | COLON catalog_query_reference {

    }
    ;

// Section 10.4 Function variable definition
function_variable_definition
    : FUNCTION function_variable of_type_signature function_initializer {

    }
    ;

function_variable
    : static_variable_name {

    }
    ;

function_initializer
    : as_or_equals function_reference {

    }
    | nested_function_specification {

    } AS nested_function_specification {

    }
    | COLON catalog_function_reference {

    }
    ;

// Section 10.5 Binding variable and parameter declarations and definitions
// INACTIVE PARSING RULES
// compact_variable_declaration_list
//     : compact_variable_declaration {

//     }
//     | compact_variable_declaration_list COMMA compact_variable_declaration {

//     }
//     ;

compact_variable_declaration
    : binding_variable_declaration {
    }
    | value_variable {

    }
    ;

binding_variable_declaration
    : graph_variable_declaration {

    }
    | binding_table_variable_declaration {

    }
    | value_variable_declaration {

    }
    ;

compact_variable_definition_list
    : compact_variable_definition {

    }
    | compact_variable_definition_list COMMA compact_variable_definition {

    }
    ;

compact_variable_definition
    : compact_value_variable_definition {

    }
    | binding_variable_definition {

    }
    ;

compact_value_variable_definition_list
    : compact_value_variable_definition {
    }
    | compact_value_variable_definition_list COMMA compact_value_variable_definition {

    }
    ;

compact_value_variable_definition
    : value_variable EQUALS_OPERATOR untyped_value_expression {

    }
    ;

// INACTIVE PARSING RULES
// binding_variable_definition_list
//     : binding_variable_definition {

//     }
//     | binding_variable_definition_list COMMA binding_variable_definition {

//     }
//     ;

binding_variable_definition
    : graph_variable_definition {

    }
    | binding_table_variable_definition {

    }
    | value_variable_definition {

    }
    ;

// INACTIVE PARSING RULES
// optional_binding_variable_definition_list
//     : optional_binding_variable_definition {

//     }
//     | optional_binding_variable_definition_list COMMA optional_binding_variable_definition {

//     }
//     ;

// INACTIVE PARSING RULES
// optional_binding_variable_definition
//     : optional_graph_variable_definition {

//     }
//     | optional_binding_table_variable_definition {

//     }
//     | optional_value_variable_definition {

//     }
//     ;

parameter_definition
    : graph_parameter_definition {

    }
    | binding_table_parameter_definition {

    }
    | value_parameter_definition {

    }
    ;

// Section 10.6 Graph variable and parameter declaration and definition
graph_variable_declaration
    : GRAPH_SYNONYM graph_variable of_graph_type {

    }
    ;

// INACTIVE PARSING RULES
// optional_graph_variable_definition
//     : graph_variable_definition {

//     }
//     ;

graph_variable_definition
    : GRAPH_SYNONYM graph_variable of_graph_type graph_initializer {
      
    }
    ;

// TODO seems it should use <parameter> instead of PARAMETER_NAME here
graph_parameter_definition
    : GRAPH_SYNONYM PARAMETER_NAME opt_if_not_exists of_graph_type graph_initializer {

    }
    ;

graph_variable
    : binding_variable_name {

    }
    ;

graph_initializer
    : as_or_equals graph_expression {

    }
    | nested_graph_query_specification {

    }
    | AS nested_graph_query_specification {

    }
    | COLON catalog_graph_reference {

    }
    ;

// Section 10.7 Binding table variable and parameter declaration and definition
binding_table_variable_declaration
    : BINDING_TABLE_SYNONYM binding_table_variable of_binding_table_type
    ;

// INACTIVE PARSING RULES
// optional_binding_table_variable_definition
//     : binding_table_variable_definition {

//     }
//     ;

binding_table_variable_definition
    : BINDING_TABLE_SYNONYM binding_table_variable of_binding_table_type binding_table_initializer {

    }
    ;

binding_table_parameter_definition
    : BINDING_TABLE_SYNONYM parameter opt_if_not_exists of_binding_table_type binding_table_initializer {
      
    }
    ;

binding_table_variable
    : binding_variable_name {

    }
    ;

binding_table_initializer
    : as_or_equals binding_table_reference {

    }
    | nested_query_specification {

    }
    | AS nested_query_specification {
      
    }
    | COLON catalog_binding_table_reference {

    }
    ;

// Section 10.8 Value variable and parameter declaration and definition
value_variable_declaration
    : VALUE value_variable opt_of_value_type {

    }
    ;

// INACTIVE PARSING RULES
// optional_value_variable_definition
//     : value_variable_definition {

//     }
//     ;

value_variable_definition
    : VALUE value_variable value_initializer {

    }
    | VALUE value_variable of_value_type value_initializer {

    }
    ;

value_parameter_definition
    : VALUE parameter value_initializer {

    }
    | VALUE parameter IF_NOT_EXISTS value_initializer {

    }
    | VALUE parameter of_value_type value_initializer {

    }
    | VALUE parameter IF_NOT_EXISTS of_value_type value_initializer {

    }
    ;

opt_if_not_exists
    : %empty {

    }
    | IF_NOT_EXISTS {

    }
    ;

opt_of_value_type
    : %empty {

    }
    | of_value_type {

    }
    ;

value_variable
    : binding_variable_name {

    }
    ;

// TODO: conflicts: BINDING_TABLE_SYNONYM, `{`
// AS/EQUALS_OPERATOR untyped_value_expression => AS/EQUALS_OPERATOR untyped_value_expression
// If the user really want to declare the type of a value_variable, use the following rule instead:
// value_variable_definition ::= VALUE value_variable of_value_type value_initializer
value_initializer
    : AS untyped_value_expression {

    }
    | EQUALS_OPERATOR untyped_value_expression {

    }
    | nested_query_specification {

    }
    | AS nested_query_specification {

    }
    | COLON catalog_object_reference {

    }
    ;

// Chapter 11 Object expressions
// Section 11.2 <primary result object expression>
// TODO primary_result_object_expression is non-deterministic
// eg. graph_expression is conflicted with binding_table_reference here
// eg. both of them are conflicted with binding_variable -> non_parenthesized_value_expression_primary -> value_expression_primary -> generic_term
// primary_result_object_expression
//     : graph_expression {

//     }
//     | binding_table_reference {

//     }
//     ;
primary_result_object_expression
    : GRAPH_SYNONYM  graph_expression {

    }
    | BINDING_TABLE_SYNONYM binding_table_reference {

    }
    ;

// Section 11.3 <graph expression>
graph_expression
    : copy_graph_expression {

    }
    | graph_specification {

    }
    | graph_reference {

    }
    ;

copy_graph_expression
    : COPY OF graph_expression {

    }
    ;

// Section 11.4 <graph type expression>
graph_type_expression
    : copy_graph_type_expression {

    }
    | like_graph_expression {

    }
    | graph_type_specification {

    }
    | graph_type_reference {

    }
    ;

as_graph_type
    : as_or_equals graph_type_expression {

    }
    | like_graph_expression_shorthand {

    }
    | nested_graph_type_specification {

    }
    | AS nested_graph_type_specification {
      
    }
    ;

copy_graph_type_expression
    : COPY OF graph_type_reference {

    }
    ;

like_graph_expression
    : GRAPH_TYPE_SYNONYM like_graph_expression_shorthand {

    }
    ;

of_graph_type
    : opt_of_type_prefix graph_type_expression {

    }
    | like_graph_expression_shorthand {

    }
    | opt_of_type_prefix nested_graph_type_specification {
      
    }
    ;

like_graph_expression_shorthand
    : LIKE graph_expression {

    }
    ;

// Section 11.5 <binding table type expression>
of_binding_table_type
    : opt_of_type_prefix binding_table_type_expression {

    }
    | like_binding_table_shorthand {

    }
    ;

binding_table_type_expression
    : binding_table_type {

    }
    | like_binding_table_type {

    }
    ;

binding_table_type
    : BINDING_TABLE_SYNONYM record_value_type {

    }
    ;

like_binding_table_type
    : BINDING_TABLE_SYNONYM like_binding_table_shorthand {

    }
    ;

like_binding_table_shorthand
    : LIKE binding_table_reference {

    }
    ;

// Chapter 12 Statements
// Section 12.1 <statement>
statement
    : catalog_modifying_statement {

    }
    | at_schema_clause catalog_modifying_statement {

    }
    | data_modifying_statement {

    }
    | at_schema_clause data_modifying_statement {

    }
    | query_statement {

    }
    | at_schema_clause query_statement {

    }
    ;

opt_at_schema_clause
    : %empty {

    }
    | at_schema_clause {

    }
    ;

catalog_modifying_statement
    : linear_catalog_modifying_statement {

    }
    ;

data_modifying_statement
    : conditional_data_modifying_statement {

    }
    | linear_data_modifying_statement {

    }
    ;

query_statement
    : composite_query_statement {

    }
    | conditional_query_statement {

    }
    ;

// Section 12.2 <call procedure statement>
call_procedure_statement
    : CALL procedure_call {

    }
    | OPTIONAL_CALL procedure_call {

    }
    | MANDATORY_CALL procedure_call {

    }
    ;

opt_statement_mode
    : %empty {

    }
    | statement_mode {

    }
    ;

statement_mode
    : OPTIONAL {

    }
    | MANDATORY {

    }
    ;

// Section 12.3 Statement classes
simple_catalog_modifying_statement
    : primitive_catalog_modifying_statement {

    }
    | call_catalog_modifying_procedure_statement {

    }
    ;

// TODO create_schema_statement and drop_schema_statement are newly added here
primitive_catalog_modifying_statement
    : create_schema_statement {
    
    }
    | create_graph_statement {

    }
    | create_graph_type_statement {

    }
    | create_procedure_statement {
      
    }
    | create_query_statement {
      
    }
    | create_function_statement {
      
    }
    | drop_schema_statement {

    }
    | drop_graph_statement {
      
    }
    | drop_graph_type_statement {
      
    }
    | drop_procedure_statement {
      
    }
    | drop_query_statement {
      
    }
    | drop_function_statement {
      
    }
    ;

simple_data_accessing_statement
    : simple_query_statement {

    }
    | simple_data_modifying_statement {
      
    }
    ;

simple_data_modifying_statement
    : primitive_data_modifying_statement {

    }
    | do_statement {
      
    }
    | call_data_modifying_procedure_statement {
      
    }
    ;

primitive_data_modifying_statement
    : insert_statement {
      
    }
    | merge_statement {
      
    }
    | set_statement {
      
    }
    | remove_statement {
      
    }
    | delete_statement {
      
    }
    ;

simple_query_statement
    : simple_data_transforming_statement {
      
    }
    | simple_data_reading_statement {
      
    }
    ;

simple_data_reading_statement
    : match_statement {
      
    }
    | call_query_statement {
      
    }
    ;

simple_data_transforming_statement
    : primitive_data_transforming_statement {
      
    }
    | call_function_statement {
      
    }
    ;

primitive_data_transforming_statement
    : optional_statement {
      
    }
    | mandatory_statement {
      
    }
    | let_statement {
      
    }
    | for_statement {
      
    }
    | aggregate_statement {
      
    }
    | filter_statement {
      
    }
    | order_by_and_page_statement {
      
    }
    ;

// Chapter 13 Catalog-modifying statements
// Section 13.1 <linear catalog-modifying statement>
// TODO list, 原地展开, 还是加一条新规则: simple_catalog_modifying_statement_list
linear_catalog_modifying_statement
    : simple_catalog_modifying_statement_list {

    }
    ;

simple_catalog_modifying_statement_list
    : simple_catalog_modifying_statement {

    }
    | simple_catalog_modifying_statement_list simple_catalog_modifying_statement {

    }
    ;

// TODO This rule seems to have been forgotten by rule primitive_catalog_modifying_statement.
// Section 13.2 <create schema statement>
create_schema_statement
    : CREATE SCHEMA catalog_schema_parent_and_name opt_if_not_exists {

    }
    ;

// TODO This rule seems to have been forgotten by rule primitive_catalog_modifying_statement.
// Section 13.3 <drop schema statement>
drop_schema_statement
    : DROP SCHEMA catalog_schema_parent_and_name opt_if_exists {
      
    }
    ;

opt_if_exists
    : %empty {

    }
    | IF_EXISTS {

    }
    ;

// Section 13.4 <create graph statement>
create_graph_statement
    : CREATE GRAPH_SYNONYM catalog_graph_parent_and_name opt_if_not_exists opt_of_graph_type opt_graph_source {

    }
    | CREATE OR REPLACE GRAPH_SYNONYM catalog_graph_parent_and_name opt_of_graph_type opt_graph_source {

    }
    ;

opt_of_graph_type
    : %empty {

    }
    | of_graph_type {

    }
    ;

opt_graph_source
    : %empty {

    }
    | graph_source {

    }
    ;

graph_source
    : AS copy_graph_expression {

    }
    ;

// Section 13.5 <graph specification>
graph_specification
    : GRAPH_SYNONYM nested_graph_query_specification {

    }
    | GRAPH_SYNONYM nested_ambient_data_modifying_procedure_specification {

    }
    ;

nested_graph_query_specification
    : nested_query_specification {

    }
    ;

nested_ambient_data_modifying_procedure_specification
    : nested_data_modifying_procedure_specification {

    }
    ;

// Section 13.6 <drop graph statement>
drop_graph_statement
    : DROP GRAPH catalog_graph_parent_and_name opt_if_exists {

    }
    ;

// Section 13.7 <create graph type statement>
create_graph_type_statement
    : CREATE GRAPH_TYPE_SYNONYM opt_if_not_exists graph_type_initializer {

    }
    | CREATE OR REPLACE GRAPH_TYPE_SYNONYM graph_type_initializer {

    }
    ;

graph_type_initializer
    : as_graph_type {

    }
    | COLON catalog_graph_type_reference {

    }
    ;

// Section 13.8 <graph type specification>
graph_type_specification
    : GRAPH_TYPE_SYNONYM nested_graph_type_specification {

    }
    ;

nested_graph_type_specification
    : LEFT_BRACE graph_type_specification_body RIGHT_BRACE {

    }
    ;

graph_type_specification_body
    : element_type_definition_list {

    }
    ;

element_type_definition_list
    : element_type_definition {

    }
    | element_type_definition_list COMMA element_type_definition {

    }
    ;

element_type_definition
    : node_type_definition {

    }
    | edge_type_definition {

    }
    ;

// Section 13.9 <node type definition>
node_type_definition
    : LEFT_PAREN RIGHT_PAREN {

    }
    | LEFT_PAREN node_type_name RIGHT_PAREN {

    }
    | LEFT_PAREN node_type_name node_type_filler RIGHT_PAREN {

    }
    | LEFT_PAREN node_type_filler RIGHT_PAREN {

    }
    | NODE_SYNONYM node_type_name node_type_filler {

    }
    | NODE_SYNONYM TYPE node_type_name node_type_filler {
      
    }
    ;

opt_node_type_name
    : %empty {

    }
    | node_type_name {

    }
    ;

opt_node_type_filler
    : %empty {

    }
    | node_type_filler {

    }
    ;

node_type_name
    : // !! Predicative production rule.
    element_type_name {

    }
    ;

node_type_filler
    : node_type_label_set_definition {

    }
    | node_type_property_type_set_definition {

    }
    | node_type_label_set_definition node_type_property_type_set_definition {

    }
    ;

node_type_label_set_definition
    : // !! Predicative production rule.
    label_set_definition {

    }
    ;

node_type_property_type_set_definition
    : // !! Predicative production rule.
    property_type_set_definition {

    }
    ;

// Section 13.10 <edge type definition>
edge_type_definition
    : full_edge_type_pattern {

    }
    | abbreviated_edge_type_pattern {

    }
    | edge_kind EDGE_SYNONYM edge_type_name edge_type_filler endpoint_definition {

    }
    | edge_kind EDGE_SYNONYM TYPE edge_type_name edge_type_filler endpoint_definition {

    }
    ;

edge_type_name
    : // !! Predicative production rule.
    element_type_name {

    }
    ;

edge_type_filler
    : edge_type_label_set_definition {
      
    }
    | edge_type_property_type_set_definition {
      
    }
    | edge_type_label_set_definition edge_type_property_type_set_definition {
      
    }
    ;

edge_type_label_set_definition
    : // !! Predicative production rule.
    label_set_definition {

    }
    ;

edge_type_property_type_set_definition
    : // !! Predicative production rule.
    property_type_set_definition {
      
    }
    ;

full_edge_type_pattern
    : full_edge_type_pattern_pointing_right {
      
    }
    | full_edge_type_pattern_pointing_left {
      
    }
    | full_edge_type_pattern_any_direction {
      
    }
    ;

full_edge_type_pattern_pointing_right
    : source_node_type_reference arc_type_pointing_right destination_node_type_reference {

    }
    ;

full_edge_type_pattern_pointing_left
    : destination_node_type_reference arc_type_pointing_left source_node_type_reference {

    }
    ;

full_edge_type_pattern_any_direction
    : source_node_type_reference arc_type_any_direction destination_node_type_reference {
      
    }
    ;

arc_type_pointing_right
    : MINUS_LEFT_BRACKET arc_type_filler BRACKET_RIGHT_ARROW {

    }
    ;

arc_type_pointing_left
    : LEFT_ARROW_BRACKET arc_type_filler RIGHT_BRACKET_MINUS {

    }
    ;

arc_type_any_direction
    : TILDE_LEFT_BRACKET arc_type_filler RIGHT_BRACKET_TILDE {

    }
    ;

arc_type_filler
    : opt_edge_type_name opt_edge_type_filler {

    }
    ;

opt_edge_type_name
    : %empty {

    }
    | edge_type_name {

    }
    ;

opt_edge_type_filler
    : %empty {

    }
    | edge_type_filler {

    }
    ;

abbreviated_edge_type_pattern
    : abbreviated_edge_type_pattern_pointing_right {

    }
    | abbreviated_edge_type_pattern_pointing_left {
      
    }
    | abbreviated_edge_type_pattern_any_direction {
      
    }
    ;

abbreviated_edge_type_pattern_pointing_right
    : source_node_type_reference RIGHT_ARROW destination_node_type_reference {
      
    }
    ;

abbreviated_edge_type_pattern_pointing_left
    : destination_node_type_reference LEFT_ARROW source_node_type_reference {
      
    }
    ;

abbreviated_edge_type_pattern_any_direction
    : source_node_type_reference TILDE destination_node_type_reference {
      
    }
    ;

// TODO source_node_type_name => node_type_name
source_node_type_reference
    : LEFT_PAREN node_type_name RIGHT_PAREN {

    }
    | LEFT_PAREN RIGHT_PAREN {

    }
    | LEFT_PAREN node_type_filler RIGHT_PAREN {

    }
    ;

// TODO destination_node_type_name => node_type_name
destination_node_type_reference
    : LEFT_PAREN node_type_name RIGHT_PAREN {

    }
    | LEFT_PAREN RIGHT_PAREN {

    }
    | LEFT_PAREN node_type_filler RIGHT_PAREN {

    }
    ;

edge_kind
    : DIRECTED {

    }
    | UNDIRECTED {

    }
    ;

endpoint_definition
    : CONNECTING endpoint_pair_definition {

    }
    ;

endpoint_pair_definition
    : endpoint_pair_definition_pointing_right {

    }
    | endpoint_pair_definition_pointing_left {

    }
    | endpoint_pair_definition_any_direction {

    }
    | abbreviated_edge_type_pattern {

    }
    ;

// TODO error? conflict with endpoint_pair_definition_any_direction
endpoint_pair_definition_pointing_right
    : LEFT_PAREN source_node_type_name connector_pointing_right destination_node_type_name RIGHT_PAREN {

    }
    ;

endpoint_pair_definition_pointing_left
    : LEFT_PAREN destination_node_type_name LEFT_ARROW source_node_type_name RIGHT_PAREN {

    }
    ;

endpoint_pair_definition_any_direction
    : LEFT_PAREN source_node_type_name connector_any_direction destination_node_type_name RIGHT_PAREN {

    }
    ;

// TODO error?
connector_pointing_right
    : RIGHT_ARROW {

    }
    // | TO {

    // }
    ;

// TODO error?
connector_any_direction
    : TILDE {

    }
    // | TO {

    // }
    ;

source_node_type_name
    : // !! Predicative production rule.
    element_type_name {

    }
    ;

destination_node_type_name
    : // !! Predicative production rule.
    element_type_name {

    }
    ;

// Section 13.11 <label set definition>
label_set_definition
    : LABEL label {

    }
    | LABELS label_expression {

    }
    | is_label_expression {

    }
    ;

// Section 13.12 <property type set definition>
property_type_set_definition
    : LEFT_BRACE opt_property_type_definition_list RIGHT_BRACE {

    }
    ;

opt_property_type_definition_list
    : %empty {

    }
    | property_type_definition_list {

    }
    ;

property_type_definition_list
    : property_type_definition {
    }
    | property_type_definition_list COMMA property_type_definition {

    }
    ;

property_type_definition
    : property_name type_name {

    }
    ;

// Section 13.13 <drop graph type statement>
drop_graph_type_statement
    : DROP GRAPH_TYPE_SYNONYM catalog_graph_type_parent_and_name opt_if_exists {

    }
    ;

// Section 13.14 <create procedure statement>
create_procedure_statement
    : CREATE PROCEDURE catalog_procedure_parent_and_name of_type_signature opt_if_not_exists procedure_initializer {

    }
    | CREATE OR REPLACE PROCEDURE catalog_procedure_parent_and_name of_type_signature procedure_initializer {

    }
    ;

// Section 13.15 <drop procedure statement>
drop_procedure_statement
    : DROP PROCEDURE catalog_procedure_parent_and_name opt_if_exists {

    }
    ;

// Section 13.16 <create query statement>
create_query_statement
    : CREATE QUERY catalog_query_parent_and_name of_type_signature opt_if_not_exists query_initializer {

    }
    | CREATE OR REPLACE QUERY catalog_query_parent_and_name of_type_signature query_initializer {

    }
    ;

// Section 13.17 <drop query statement>
drop_query_statement
    : DROP QUERY catalog_query_parent_and_name opt_if_exists {

    }
    ;

// Section 13.18 <create function statement>
create_function_statement
    : CREATE FUNCTION catalog_function_parent_and_name of_type_signature opt_if_not_exists function_initializer {

    }
    | CREATE OR REPLACE FUNCTION catalog_function_parent_and_name of_type_signature function_initializer {

    }
    ;

// Section 13.19 <drop function statement>
drop_function_statement
    : DROP FUNCTION catalog_function_parent_and_name opt_if_exists {

    }
    ;


// Section 13.20 <call catalog-modifying procedure statement>
// TODO: We can't infer the kind of a call_procedure_statement
call_catalog_modifying_procedure_statement
    : call_procedure_statement DUMMY_CATALOG_PROCEDURE_FLAG {

    }
    ;

// Chapter 14 Data-modifying statements
// Section 14.1 <linear data-modifying statement>
linear_data_modifying_statement
    : focused_linear_data_modifying_statement {

    }
    | ambient_linear_data_modifying_statement {

    }
    ;

focused_linear_data_modifying_statement
    : use_graph_clause focused_linear_data_modifying_statement_body {

    }
    ;

// focused_linear_data_modifying_statement_body_list
//     : focused_linear_data_modifying_statement_body {

//     }
//     | focused_linear_data_modifying_statement_body_list focused_linear_data_modifying_statement_body {

//     }
//     ;

// // TODO?
// focused_linear_data_modifying_statement_body
//     : simple_data_modifying_statement opt_use_graph_clause_and_simple_data_accessing_statement_list {

//     }
//     | use_graph_clause_and_simple_linear_query_statement_list simple_data_modifying_statement opt_use_graph_clause_and_simple_data_accessing_statement_list {

//     }
//     | simple_data_modifying_statement opt_use_graph_clause_and_simple_data_accessing_statement_list primitive_result_statement {

//     }
//     | use_graph_clause_and_simple_linear_query_statement_list simple_data_modifying_statement opt_use_graph_clause_and_simple_data_accessing_statement_list primitive_result_statement {

//     }
//     | nested_data_modifying_procedure_specification {

//     }
//     ;

focused_linear_data_modifying_statement_body
    : focused_linear_data_modifying_statement_body_item {

    }
    | focused_linear_data_modifying_statement_body focused_linear_data_modifying_statement_body_item {

    }
    ;

focused_linear_data_modifying_statement_body_item
    : simple_data_accessing_statement {

    }
    | use_graph_clause simple_data_accessing_statement {

    }
    | primitive_result_statement {

    }
    ;

opt_simple_linear_query_statement
    : %empty {

    }
    | simple_linear_query_statement {

    }
    ;

opt_use_graph_clause_and_simple_linear_query_statement_list
    : %empty {

    }
    | use_graph_clause_and_simple_linear_query_statement_list {

    }
    ;

// TODO 原地展开 use_graph_clause_and_simple_linear_query_statement ?
use_graph_clause_and_simple_linear_query_statement_list
    : use_graph_clause simple_linear_query_statement {

    }
    | use_graph_clause_and_simple_linear_query_statement_list simple_linear_query_statement {

    }
    | use_graph_clause_and_simple_linear_query_statement_list use_graph_clause simple_linear_query_statement {

    }
    ;

// TODO remove a maybe reduant rule
// use_graph_clause_and_simple_linear_query_statement
//     : use_graph_clause simple_linear_query_statement {

//     }
//     ;

// opt_simple_data_accessing_statement_list
//     : %empty {

//     }
//     | simple_data_accessing_statement_list {

//     }
//     ;
  
// simple_data_accessing_statement_list
//     : simple_data_accessing_statement {

//     }
//     | simple_data_accessing_statement_list simple_data_accessing_statement {

//     }
//     ;

opt_use_graph_clause_and_simple_data_accessing_statement_list
    : %empty {

    }
    | opt_use_graph_clause_and_simple_data_accessing_statement_list simple_data_accessing_statement {

    }
    | opt_use_graph_clause_and_simple_data_accessing_statement_list use_graph_clause simple_data_accessing_statement {

    }
    ;

// use_graph_clause_and_simple_data_accessing_statement_list
//     : use_graph_clause simple_data_accessing_statement {

//     }
//     | use_graph_clause_and_simple_data_accessing_statement_list use_graph_clause simple_data_accessing_statement {

//     }
//     ;

// // TODO remove a maybe reduant rule
// use_graph_clause_and_simple_data_accessing_statement
//     : use_graph_clause simple_data_accessing_statement {

//     }
//     ;

opt_primitive_result_statement
    : %empty {

    }
    | primitive_result_statement {

    }
    ;

// TODO combine the rule, and do the check in the action
// ambient_linear_data_modifying_statement
//     : simple_data_modifying_statement opt_simple_data_accessing_statement_list opt_primitive_result_statement {

//     }
//     | simple_linear_query_statement simple_data_modifying_statement opt_simple_data_accessing_statement_list opt_primitive_result_statement {

//     }
//     | nested_data_modifying_procedure_specification {

//     }
//     ;

ambient_linear_data_modifying_statement
    : simple_data_accessing_statement_list { std::cerr << "hello"; } opt_primitive_result_statement {

    }
    | nested_data_modifying_procedure_specification {

    }
    ;

simple_data_accessing_statement_list
    : simple_data_accessing_statement {

    }
    | simple_data_accessing_statement_list simple_data_accessing_statement {
      
    }
    ;

// Section 14.2 <conditional data-modifying statement>
conditional_data_modifying_statement
    : when_then_linear_data_modifying_statement_branch_list opt_else_linear_data_modifying_statement_branch {

    }
    ;

when_then_linear_data_modifying_statement_branch_list
    : when_then_linear_data_modifying_statement_branch {

    }
    | when_then_linear_data_modifying_statement_branch_list when_then_linear_data_modifying_statement_branch {

    }
    ;

opt_else_linear_data_modifying_statement_branch
    : %empty {

    }
    | else_linear_data_modifying_statement_branch {

    }
    ;

when_then_linear_data_modifying_statement_branch
    : when_clause THEN linear_data_modifying_statement {

    }
    | when_clause nested_data_modifying_procedure_specification {

    }
    ;

else_linear_data_modifying_statement_branch
    : ELSE linear_data_modifying_statement {

    }
    ;

when_clause
    : WHEN search_condition {

    }
    ;

// Section 14.3 <do statement>
do_statement
    : DO nested_data_modifying_procedure_specification {

    }
    ;

// Section 14.4 <insert statement>
insert_statement
    : INSERT simple_graph_pattern {

    }
    | OPTIONAL_INSERT simple_graph_pattern opt_when_clause {

    }
    // | OPTIONAL_INSERT simple_graph_pattern where_clause {

    // }
    ;

opt_when_clause
    : %empty {

    }
    | where_clause {

    }
    ;

// Section 14.5 <merge statement>
merge_statement
    : MERGE simple_graph_pattern {

    }
    ;

// Section 14.6 <set statement>
set_statement
    : SET set_item_list opt_when_clause {

    }
    ;

set_item_list
    : set_item {
    }
    | set_item_list COMMA set_item {

    }
    ;

set_item
    : set_property_item {

    }
    | set_all_properties_item {

    }
    | set_label_item {

    }
    ;

set_property_item
    : binding_variable PERIOD property_name EQUALS_OPERATOR untyped_value_expression {
      
    }
    ;

set_all_properties_item
    : binding_variable EQUALS_OPERATOR untyped_value_expression {

    }
    ;

set_label_item
    : label_set_expression {

    }
    ;

// TODO error syntax?
// <label set expression> ::=
// <AMPERSAND> <label>... { <AMPERSAND> <label>... }

label_set_expression
    : AMPERSAND label_list {

    }
    | AMPERSAND label_list AMPERSAND label_list {

    }
    ;

label_list
    : label {

    }
    | label_list label {

    }
    ;

// Section 14.7 <remove statement>
remove_statement
    : REMOVE remove_item_list opt_when_clause {

    }
    ;

remove_item_list
    : remove_item {
    }
    | remove_item_list COMMA remove_item {

    }
    ;

remove_item
    : remove_property_item {

    }
    | remove_label_item {

    }
    ;

remove_property_item
    : binding_variable PERIOD property_name {

    }
    ;

remove_label_item
    : binding_variable COLON label_set_expression {

    }
    ;

// Section 14.8 <delete statement>
delete_statement
    : DELETE delete_item_list opt_when_clause {

    }
    | DETACH DELETE delete_item_list opt_when_clause {
      
    }
    ;

delete_item_list
    : delete_item {
    }
    | delete_item_list COMMA delete_item {

    }
    ;

delete_item
    : untyped_value_expression {

    }
    ;


// Section 14.9 <call data-modifying procedure statement>
call_data_modifying_procedure_statement
    : call_procedure_statement DUMMY_DATA_PROCEDURE_FLAG {

    }
    ;

// Chapter 15 Query statements
// Section 15.1 <composite query statement>
composite_query_statement
    : composite_query_expression {

    }
    ;

// Section 15.2 <conditional query statement>
conditional_query_statement
    : when_then_linear_query_branch_list opt_else_linear_query_branch {

    }
    ;

when_then_linear_query_branch_list
    : when_then_linear_query_branch {

    }
    | when_then_linear_query_branch_list when_then_linear_query_branch {

    }
    ;

opt_else_linear_query_branch
    : %empty {

    }
    | else_linear_query_branch {

    }
    ;

when_then_linear_query_branch
    : when_clause THEN linear_query_expression {

    }
    | when_clause nested_query_specification {

    }
    ;

else_linear_query_branch
    : ELSE linear_query_expression {

    }
    ;

// Section 15.3 <composite query expression>
composite_query_expression
    : composite_query_expression query_conjunction linear_query_expression {

    }
    | linear_query_expression {

    }
    ;

query_conjunction
    : set_operator {

    }
    | OTHERWISE {

    }
    ;

set_operator
    : UNION opt_set_quantifier {

    }
    | EXCEPT opt_set_quantifier {

    }
    | INTERSECT opt_set_quantifier {

    }
    ;

opt_set_quantifier
    : %empty {

    }
    | set_quantifier {

    }
    ;

// Section 15.4 <linear query expression>
linear_query_expression
    : linear_query_statement {

    }
    ;

// Section 15.5 <linear query statement>
linear_query_statement
    : focused_linear_query_statement {
      
    }
    | ambient_linear_query_statement {
      
    }
    ;

focused_linear_query_statement
    : from_graph_clause focused_linear_query_statement_body {

    }
    | select_statement {

    }
    ;

// TODO
focused_linear_query_statement_body
    : primitive_result_statement {

    }
    | simple_linear_query_statement primitive_result_statement {

    }
    | simple_linear_query_statement from_graph_clause_and_simple_linear_query_statement_list primitive_result_statement {

    }
    | nested_query_specification {

    }
    ;

from_graph_clause_and_simple_linear_query_statement_list
    : from_graph_clause simple_linear_query_statement {

    }
    | from_graph_clause_and_simple_linear_query_statement_list from_graph_clause simple_linear_query_statement {

    }
    ;

ambient_linear_query_statement
    : primitive_result_statement {

    }
    | simple_data_accessing_statement_list DUMMY_AMBIENT_QUERY_STMT primitive_result_statement {

    }
    | nested_query_specification {

    }
    ;

// TODO why remove simple_query_statement_list will cause more conflicts?
simple_linear_query_statement
    : simple_query_statement_list {

    }
    ;

simple_query_statement_list
    : simple_query_statement {

    }
    | simple_query_statement_list simple_query_statement {

    }
    ;

// Section 15.6 Data-reading statements
// Section 15.6.1 <match statement>
match_statement
    : MATCH graph_pattern {

    }
    | OPTIONAL_MATCH graph_pattern {

    }
    | MANDATORY_MATCH graph_pattern {

    }
    ;

// Section 15.6.2 <call query statement>
call_query_statement
    : call_procedure_statement DUMMY_QUERY_FLAG {

    }
    ;

// Section 15.7 Data-transforming statements
// Section 15.7.1 <mandatory statement>
mandatory_statement
    : MANDATORY procedure_call {

    }
    ;

// Section 15.7.2 <optional statement>
optional_statement
    : OPTIONAL procedure_call {

    }
    ;

// Section 15.7.3 <filter statement>
filter_statement
    : FILTER where_clause {

    }
    | FILTER search_condition {

    }
    ;

// Section 15.7.4 <let statement>
let_statement
    : LET compact_variable_definition_list {

    }
    | OPTIONAL_LET compact_variable_definition_list where_clause {
      
    }
    | MANDATORY_LET compact_variable_definition_list where_clause {
      
    }
    ;

// Section 15.7.5 <aggregate statement>
aggregate_statement
    : AGGREGATE compact_value_variable_definition_list where_clause {

    }
    ;

// Section 15.7.6 <for statement>
for_statement
    : FOR for_item_list opt_for_ordinality_or_index opt_where_clause {

    }
    | OPTIONAL_FOR for_item_list opt_for_ordinality_or_index opt_where_clause {

    }
    | MANDATORY_FOR for_item_list opt_for_ordinality_or_index opt_where_clause {

    }
    ;

opt_for_ordinality_or_index
    : %empty {

    }
    | for_ordinality_or_index {

    }
    ;

opt_where_clause
    : %empty {

    }
    | where_clause {

    }
    ;

for_item_list
    : for_item {
    
    }
    | for_item_list AND for_item {

    }
    ;

// TODO: collection_value_expression is changed to untyped_value_expression
for_item
    : for_item_alias untyped_value_expression %prec HIGHER_THAN_AND {

    }
    ;

for_item_alias
    : identifier IN {

    }
    ;

for_ordinality_or_index
    : WITH ordinality_or_index opt_identifier {

    }
    ;

ordinality_or_index
    : ORDINALITY {

    }
    | INDEX {

    }
    ;

opt_identifier
    : %empty {

    }
    | identifier {

    }
    ;

// Section 15.7.7 <order by and page statement>
order_by_and_page_statement
    : order_by_clause opt_offset_clause opt_limit_clause {

    }
    | offset_clause opt_limit_clause {

    }
    | limit_clause {

    }
    ;

// order_by_and_page_statement
//     : order_by_clause %prec LOWER_THAN_LIMIT {

//     }
//     | order_by_clause offset_clause %prec LOWER_THAN_LIMIT {

//     }
//     | order_by_clause offset_clause limit_clause {

//     }
//     | order_by_clause limit_clause %prec LOWER_THAN_LIMIT {

//     }
//     | offset_clause %prec LOWER_THAN_LIMIT {

//     }
//     | offset_clause limit_clause %prec LOWER_THAN_LIMIT {

//     }
//     | limit_clause %prec LOWER_THAN_LIMIT {

//     }
//     ;

opt_offset_clause
    : %empty %prec LOWER_THAN_LIMIT {

    }
    | offset_clause {

    }
    ;

opt_limit_clause
    : %empty %prec LOWER_THAN_LIMIT {

    }
    | limit_clause {

    }
    ;

// Section 15.7.8 <call function statement>
call_function_statement
    : call_procedure_statement DUMMY_FUNCTION_FLAG {

    }
    ;

// Section 15.8 Result projection statements
// Section 15.8.1 <primitive result statement>
primitive_result_statement
    : return_statement %prec LOWER_THAN_LIMIT {
    
    }
    | return_statement order_by_and_page_statement {

    }
    | project_statement {

    }
    | END {

    }
    ;

// Section 15.8.2 <return statement>
return_statement
    : RETURN return_statement_body {

    }
    ;

return_statement_body
    : opt_set_quantifier ASTERISK opt_group_by_clause {

    }
    | opt_set_quantifier return_item_list opt_group_by_clause {

    }
    ;

opt_group_by_clause
    : %empty {

    }
    | group_by_clause {

    }
    ;

return_item_list
    : return_item {
    
    }
    | return_item_list COMMA return_item {
    }
    ;

return_item
    : untyped_value_expression {
    }
    | untyped_value_expression return_item_alias {

    }
    ;

return_item_alias
    : AS identifier {

    }
    ;

// Section 15.8.3 <select statement>
// TODO remove opt_where_clause due to conflicts
select_statement
    :
    // SELECT opt_set_quantifier select_item_list select_statement_body opt_where_clause opt_group_by_clause opt_having_clause opt_order_by_clause opt_offset_clause opt_limit_clause {

    // }
    SELECT opt_set_quantifier select_item_list select_statement_body opt_group_by_clause opt_having_clause opt_order_by_clause opt_offset_clause opt_limit_clause {

    }
    ;

select_item_list
    : select_item {
    
    }
    | select_item_list COMMA select_item {

    }
    ;

select_item
    : untyped_value_expression {
    
    }
    | untyped_value_expression select_item_alias {

    }
    ;

select_item_alias
    : AS identifier {

    }
    ;

having_clause
    : HAVING search_condition {

    }
    ;

select_statement_body
    : FROM select_graph_match_list {

    }
    | select_query_specification {

    }
    ;

// TODO: distinguish the COMMA with yield_item_list
select_graph_match_list
    : select_graph_match {

    }
    // | select_graph_match_list COMMA select_graph_match {

    // }
    ;

select_graph_match
    : graph_expression match_statement {

    }
    ;

select_query_specification
    : FROM nested_query_specification {

    }
    | from_graph_clause nested_query_specification {

    }
    ;

opt_having_clause
    : %empty {

    }
    | having_clause {

    }
    ;

opt_order_by_clause
    : %empty {

    }
    | order_by_clause {

    }
    ;

// Section 15.8.4 <project statement>
// TODO untyped_value_expression => untyped_value_expression
project_statement
    : PROJECT untyped_value_expression {

    }
    ;

// Chapter 16 Common elements
// Section 16.1 <from graph clause>
from_graph_clause
    : FROM graph_expression {

    }
    ;

// Section 16.2 <use graph clause>
use_graph_clause
    : USE graph_expression {

    }
    ;

// Section 16.3 <at schema clause>
at_schema_clause
    : AT schema_reference {

    }
    ;

// Section 16.4 Named elements
// INACTIVE PARSING RULES
// static_variable
//     : static_variable_name {

//     }
//     ;

binding_variable
    : binding_variable_name {
      
    }
    ;

label
    : label_name {
      
    }
    ;

parameter
    : PARAMETER_NAME {
      
    }
    ;

// Section 16.5 <type signature>
of_type_signature
    : opt_of_type_prefix type_signature {

    }
    ;

opt_of_type_prefix
    : %empty {

    }
    | of_type_prefix {

    }
    ;

type_signature
    : parenthesized_formal_parameter_list opt_of_type_prefix procedure_result_type {

    }
    ;

parenthesized_formal_parameter_list
    : LEFT_PAREN opt_formal_parameter_list RIGHT_PAREN {

    }
    ;

opt_formal_parameter_list
    : %empty {

    }
    | formal_parameter_list {

    }
    ;

formal_parameter_list
    : mandatory_formal_parameter_list {

    }
    | mandatory_formal_parameter_list COMMA_OPTIONAL formal_parameter_definition_list {

    }
    | OPTIONAL formal_parameter_definition_list {

    }
    ;

mandatory_formal_parameter_list
    : formal_parameter_declaration_list {
      
    }
    ;

// optional_formal_parameter_list
//     : OPTIONAL formal_parameter_definition_list {

//     }
//     ;

formal_parameter_declaration_list
    : formal_parameter_declaration {
    
    }
    | formal_parameter_declaration_list COMMA formal_parameter_declaration {

    }
    ;

formal_parameter_definition_list
    : formal_parameter_definition {
      
    }
    | formal_parameter_definition_list COMMA formal_parameter_definition {

    }
    ;

formal_parameter_declaration
    : parameter_cardinality compact_variable_declaration {

    }
    ;

formal_parameter_definition
    : parameter_cardinality compact_variable_definition {

    }
    ;

// INACTIVE PARSING RULES
// optional_parameter_cardinality
//     : %empty {
    
//     }
//     | parameter_cardinality {

//     }
//     ;

parameter_cardinality
    : SINGLE {
    
    }
    | MULTI {
      
    }
    | MULTIPLE {

    }
    ;

procedure_result_type
    : value_type {

    }
    ;

// Section 16.6 <graph pattern>
graph_pattern
    : path_pattern_list opt_keep_clause opt_graph_pattern_where_clause opt_yield_clause {

    }
    ;

opt_keep_clause
    : %empty {

    }
    | keep_clause {

    }
    ;

opt_graph_pattern_where_clause
    : %empty {

    }
    | graph_pattern_where_clause {

    }
    ;

opt_yield_clause
    : %empty {

    }
    | yield_clause {

    }
    ;

path_pattern_list
    : path_pattern {
    
    }
    | path_pattern_list COMMA path_pattern {

    }
    ;

// TODO
path_pattern
    : opt_path_variable_declaration opt_path_pattern_prefix path_pattern_expression {

    }
    ;

opt_path_variable_declaration
    : %empty {

    }
    | path_variable_declaration {

    }
    ;

path_variable_declaration
    : path_variable EQUALS_OPERATOR {

    }
    ;

opt_path_pattern_prefix
    : %empty {

    }
    | path_pattern_prefix {

    }
    ;

keep_clause
    : KEEP path_pattern_prefix {

    }
    ;

graph_pattern_where_clause
    : WHERE search_condition {

    }
    ;

// Section 16.7 <path pattern expression>
path_pattern_expression
    : path_term {

    }
    | path_multiset_alternation {

    }
    | path_pattern_union {

    }
    ;

path_multiset_alternation
    : path_term MULTISET_ALTERNATION_OPERATOR path_term {
    
    }
    | path_multiset_alternation MULTISET_ALTERNATION_OPERATOR path_term {

    }
    ;

path_pattern_union
    : path_term VERTICAL_BAR path_term {
    
    }
    | path_pattern_union VERTICAL_BAR path_term {

    }
    ;

path_term
    : path_factor {

    }
    | path_concatenation {

    }
    ;

path_concatenation
    : path_term path_factor {

    }
    ;

path_factor
    : path_primary {

    }
    | quantified_path_primary {

    }
    | questioned_path_primary {

    }
    ;

quantified_path_primary
    : path_primary graph_pattern_quantifier {

    }
    ;

questioned_path_primary
    : path_primary QUESTION_MARK {

    }
    ;

path_primary
    : element_pattern {

    }
    | parenthesized_path_pattern_expression {

    }
    | simplified_path_pattern_expression {

    }
    ;

element_pattern
    : node_pattern {

    }
    | edge_pattern {

    }
    ;

node_pattern
    : LEFT_PAREN element_pattern_filler RIGHT_PAREN {

    }
    ;

element_pattern_filler
    : opt_element_variable_declaration opt_is_label_expression opt_element_pattern_predicate opt_element_pattern_cost_clause {

    }
    ;

opt_element_variable_declaration
    : %empty {

    }
    | element_variable_declaration {

    }
    ;

opt_is_label_expression
    : %empty {

    }
    | is_label_expression {

    }
    ;

opt_element_pattern_predicate
    : %empty {

    }
    | element_pattern_predicate {

    }
    ;

opt_element_pattern_cost_clause
    : %empty {

    }
    | element_pattern_cost_clause {

    }
    ;

element_variable_declaration
    : element_variable {

    }
    ;

is_label_expression
    : is_or_colon label_expression {

    }
    ;

is_or_colon
    : IS {

    }
    | COLON {

    }
    ;

element_pattern_predicate
    : element_pattern_where_clause {

    }
    | element_property_specification {

    }
    ;

element_pattern_where_clause
    : WHERE search_condition {

    }
    ;

element_property_specification
    : LEFT_BRACE property_key_value_pair_list RIGHT_BRACE {

    }
    ;

property_key_value_pair_list
    : property_key_value_pair {
      
    }
    | property_key_value_pair_list COMMA property_key_value_pair {

    }
    ;

property_key_value_pair
    : property_name COLON untyped_value_expression {

    }
    ;

element_pattern_cost_clause
    : cost_clause {

    }
    ;

cost_clause
    : COST untyped_value_expression {
    
    }
    | COST untyped_value_expression DEFAULT untyped_value_expression {

    }
    ;

edge_pattern
    : full_edge_pattern {

    }
    | abbreviated_edge_pattern {

    }
    ;

full_edge_pattern
    : full_edge_pointing_left {

    }
    | full_edge_undirected {
      
    }
    | full_edge_pointing_right {
      
    }
    | full_edge_left_or_undirected {
      
    }
    | full_edge_undirected_or_right {
      
    }
    | full_edge_left_or_right {
      
    }
    | full_edge_any_direction {
      
    }
    ;

full_edge_pointing_left
    : LEFT_ARROW_BRACKET element_pattern_filler RIGHT_BRACKET_MINUS {

    }
    ;

full_edge_undirected
    : TILDE_LEFT_BRACKET element_pattern_filler RIGHT_BRACKET_TILDE {

    }
    ;

full_edge_pointing_right
    :  MINUS_LEFT_BRACKET element_pattern_filler BRACKET_RIGHT_ARROW {

    }
    ;

full_edge_left_or_undirected
    : LEFT_ARROW_TILDE_BRACKET element_pattern_filler RIGHT_BRACKET_TILDE {

    }
    ;

full_edge_undirected_or_right
    : TILDE_LEFT_BRACKET element_pattern_filler BRACKET_TILDE_RIGHT_ARROW {

    }
    ;

full_edge_left_or_right
    : LEFT_ARROW_BRACKET element_pattern_filler BRACKET_RIGHT_ARROW {

    }
    ;

full_edge_any_direction
    :  MINUS_LEFT_BRACKET element_pattern_filler RIGHT_BRACKET_MINUS {

    }
    ;

abbreviated_edge_pattern
    : LEFT_ARROW {
      
    }
    | TILDE {

    }
    | RIGHT_ARROW {
      
    }
    | LEFT_ARROW_TILDE {
      
    }
    | TILDE_RIGHT_ARROW {
      
    }
    | LEFT_MINUS_RIGHT {
      
    }
    | MINUS_SIGN {
      
    }
    ;

graph_pattern_quantifier
    : ASTERISK {

    }
    | PLUS_SIGN {

    }
    | fixed_quantifier {

    }
    | general_quantifier {

    }
    ;

fixed_quantifier
    : LEFT_BRACE unsigned_integer RIGHT_BRACE {

    }
    ;

general_quantifier
    : LEFT_BRACE opt_lower_bound COMMA opt_upper_bound RIGHT_BRACE {

    }
    ;

opt_lower_bound
    : %empty {

    }
    | lower_bound {

    }
    ;

opt_upper_bound
    : %empty {

    }
    | upper_bound {

    }
    ;

lower_bound
    : unsigned_integer
    ;

upper_bound
    : unsigned_integer
    ;

parenthesized_path_pattern_expression
    : LEFT_PAREN opt_subpath_variable_declaration opt_path_mode_prefix path_pattern_expression opt_parenthesized_path_pattern_where_clause opt_parenthesized_path_pattern_cost_clause RIGHT_PAREN {

    }
    | LEFT_BRACKET opt_subpath_variable_declaration opt_path_mode_prefix path_pattern_expression opt_parenthesized_path_pattern_where_clause opt_parenthesized_path_pattern_cost_clause RIGHT_BRACKET {

    }
    ;

opt_subpath_variable_declaration
    : %empty {

    }
    | subpath_variable_declaration {

    }
    ;

opt_path_mode_prefix
    : %empty {

    }
    | path_mode_prefix {

    }
    ;

opt_parenthesized_path_pattern_where_clause
    : %empty {

    }
    | parenthesized_path_pattern_where_clause {

    }
    ;

opt_parenthesized_path_pattern_cost_clause
    : %empty {

    }
    | parenthesized_path_pattern_cost_clause {

    }
    ;

subpath_variable_declaration
    : subpath_variable EQUALS_OPERATOR {

    }
    ;

parenthesized_path_pattern_where_clause
    : WHERE search_condition {

    }
    ;

parenthesized_path_pattern_cost_clause
    : cost_clause {

    }
    ;

// Section 16.8 <path pattern prefix>
path_pattern_prefix
    : path_mode_prefix {

    }
    | path_search_prefix {

    }
    ;

path_mode_prefix
    : path_mode opt_path_or_paths {

    }
    ;

opt_path_or_paths
    : %empty {

    }
    | path_or_paths {

    }
    ;

path_mode
    : WALK {

    }
    | TRAIL {

    }
    | SIMPLE {

    }
    | ACYCLIC {

    }
    ;

path_search_prefix
    : all_path_search {

    }
    | any_path_search {

    }
    | shortest_path_search {

    }
    ;

all_path_search
    : ALL opt_path_mode opt_path_or_paths {

    }
    ;

path_or_paths
    : PATH {
    
    }
    | PATHS {

    }
    ;

any_path_search
    : ANY opt_number_of_paths opt_path_mode opt_path_or_paths {

    }
    ;

opt_number_of_paths
    : %empty {

    }
    | number_of_paths {

    }
    ;

opt_path_mode
    : %empty {

    }
    | path_mode {

    }
    ;

number_of_paths
    : unsigned_integer_specification {

    }
    ;

shortest_path_search
    : all_shortest_path_search {

    }
    | any_shortest_path_search {
      
    }
    | counted_shortest_path_search {
      
    }
    | counted_shortest_group_search {
      
    }
    ;

all_shortest_path_search
    : ALL SHORTEST opt_path_mode opt_path_or_paths {

    }
    ;

any_shortest_path_search
    : ANY SHORTEST opt_path_mode opt_path_or_paths {

    }
    ;

// TODO number_of_paths number_of_groups
counted_shortest_path_search
    : SHORTEST number_of_paths_or_groups opt_path_mode opt_path_or_paths {

    }
    ;

// TODO
counted_shortest_group_search
    : SHORTEST number_of_paths_or_groups opt_path_mode opt_path_or_paths group_or_groups {
      
    }
    ;

number_of_paths_or_groups 
    : unsigned_integer_specification {

    }
    ;

group_or_groups
    : GROUP {

    }
    | GROUPS {

    }
    ;

number_of_groups
    : unsigned_integer_specification {

    }
    ;

// Section 16.9 <simple graph pattern>
simple_graph_pattern
    : simple_path_pattern_list {

    }
    ;

simple_path_pattern_list
    : simple_path_pattern {
    
    }
    | simple_path_pattern_list COMMA simple_path_pattern {

    }
    ;

simple_path_pattern
    : // !! Predicative production rule.
    path_pattern_expression {

    }
    ;

// Section 16.10 <label expression>
label_expression
    : label_term {

    }
    | label_disjunction {

    }
    ;

label_disjunction
    : label_expression VERTICAL_BAR label_term {

    }
    ;

label_term
    : label_factor {

    }
    | label_conjunction {

    }
    ;

label_conjunction
    : label_term AMPERSAND label_factor {

    }
    ;

label_factor
    : label_primary {

    }
    | label_negation {

    }
    ;

label_negation
    : EXCLAMATION_MARK label_primary {

    }
    ;

label_primary
    : label {

    }
    | wildcard_label {

    }
    | parenthesized_label_expression {

    }
    ;

wildcard_label
    : PERCENT {

    }
    ;

parenthesized_label_expression
    : LEFT_PAREN label_expression RIGHT_PAREN {

    }
    | LEFT_BRACKET label_expression RIGHT_BRACKET {

    }
    ;

// Section 16.11 <simplified path pattern expression>
simplified_path_pattern_expression
    : simplified_defaulting_left {

    }
    | simplified_defaulting_undirected {
      
    }
    | simplified_defaulting_right {
      
    }
    | simplified_defaulting_left_or_undirected {
      
    }
    | simplified_defaulting_undirected_or_right {
      
    }
    | simplified_defaulting_left_or_right {
      
    }
    | simplified_defaulting_any_direction {
      
    }
    ;

simplified_defaulting_left
    : LEFT_MINUS_SLASH simplified_contents SLASH_MINUS {

    }
    ;

simplified_defaulting_undirected
    : TILDE_SLASH simplified_contents SLASH_TILDE {

    }
    ;

simplified_defaulting_right
    : MINUS_SLASH simplified_contents SLASH_MINUS_RIGHT {

    }
    ;

simplified_defaulting_left_or_undirected
    : LEFT_TILDE_SLASH simplified_contents SLASH_TILDE {

    }
    ;

simplified_defaulting_undirected_or_right
    : TILDE_SLASH simplified_contents SLASH_TILDE_RIGHT {

    }
    ;

simplified_defaulting_left_or_right
    : LEFT_MINUS_SLASH simplified_contents SLASH_MINUS_RIGHT {

    }
    ;

simplified_defaulting_any_direction
    : MINUS_SLASH simplified_contents SLASH_MINUS {

    }
    ;

simplified_contents
    : simplified_term {

    }
    | simplified_path_union {

    }
    | simplified_multiset_alternation {

    }
    ;

simplified_path_union
    : simplified_term VERTICAL_BAR simplified_term {
    
    }
    | simplified_path_union VERTICAL_BAR simplified_term {

    }
    ;

simplified_multiset_alternation
    : simplified_term MULTISET_ALTERNATION_OPERATOR simplified_term {
    
    }
    | simplified_multiset_alternation MULTISET_ALTERNATION_OPERATOR simplified_term {

    }
    ;

simplified_term
    : simplified_factor_low {

    }
    | simplified_concatenation {

    }
    ;

simplified_concatenation
    : simplified_term simplified_factor_low {

    }
    ;

simplified_factor_low
    : simplified_factor_high {

    }
    | simplified_conjunction {
      
    }
    ;

simplified_conjunction
    : simplified_factor_low AMPERSAND simplified_factor_high {
      
    }
    ;

simplified_factor_high
    : simplified_tertiary {
      
    }
    | simplified_quantified {
      
    }
    | simplified_questioned {
      
    }
    ;

simplified_quantified
    : simplified_tertiary graph_pattern_quantifier {

    }
    ;

simplified_questioned
    : simplified_tertiary QUESTION_MARK {

    }
    ;

simplified_tertiary
    : simplified_direction_override {
      
    }
    | simplified_secondary {
      
    }
    ;

simplified_direction_override
    : simplified_override_left {
      
    }
    | simplified_override_undirected {
      
    }
    | simplified_override_right {
      
    }
    | simplified_override_left_or_undirected {
      
    }
    | simplified_override_undirected_or_right {
      
    }
    | simplified_override_left_or_right {
      
    }
    | simplified_override_any_direction {
      
    }
    ;

simplified_override_left
    : LEFT_ANGLE_BRACKET simplified_secondary {
      
    }
    ;

simplified_override_undirected
    : TILDE simplified_secondary {
      
    }
    ;

simplified_override_right
    : simplified_secondary RIGHT_ANGLE_BRACKET {

    }
    ;

simplified_override_left_or_undirected
    : LEFT_ARROW_TILDE simplified_secondary {

    }
    ;

simplified_override_undirected_or_right
    : TILDE simplified_secondary RIGHT_ANGLE_BRACKET {

    }
    ;

simplified_override_left_or_right
    : LEFT_ANGLE_BRACKET simplified_secondary RIGHT_ANGLE_BRACKET {

    }
    ;

simplified_override_any_direction
    : MINUS_SIGN simplified_secondary {

    }
    ;

simplified_secondary
    : simplified_primary {

    }
    | simplified_negation {

    }
    ;

simplified_negation
    : EXCLAMATION_MARK simplified_primary {

    }
    ;

simplified_primary
    : label {

    }
    | LEFT_PAREN simplified_contents RIGHT_PAREN {

    }
    | LEFT_BRACKET simplified_contents RIGHT_BRACKET {

    }
    ;

// Section 16.12 <where clause>
where_clause
    : WHERE search_condition {

    }
    ;

// Section 16.13 <procedure call>
procedure_call
    : inline_procedure_call {

    }
    | named_procedure_call {

    }
    ;

// Section 16.14 <inline procedure call>
inline_procedure_call
    : nested_procedure_specification {

    }
    ;

// Section 16.15 <named procedure call>
// ** Editor’s Note (number 294) **
// This needs to be detailed further; in particular it is necessary to describe how PROC is to be resolved statically (to
// determine its signature) vs. dynamically (to execute it). This may require re-determining which Rules in this Subclause
// are SRs and which are GRs. See Possible Problem GQL-120 .
named_procedure_call
    : procedure_reference LEFT_PAREN opt_procedure_argument_list RIGHT_PAREN opt_yield_clause {

    }
    ;

opt_procedure_argument_list
    : %empty {

    }
    | procedure_argument_list {

    }
    ;

procedure_argument_list
    : procedure_argument {
    
    }
    | procedure_argument_list COMMA procedure_argument {

    }
    ;

procedure_argument
    : untyped_value_expression {

    }
    ;

// Section 16.16 <yield clause>
yield_clause
    : YIELD yield_item_list {

    }
    ;

yield_item_list
    : yield_item {
    
    }
    | yield_item_list COMMA yield_item {
    
    }
    ;

yield_item
    : yield_item_name opt_yield_item_alias {

    }
    ;

// TODO could expand opt_yield_item_alias?
opt_yield_item_alias
    : %empty {

    }
    | yield_item_alias {

    }
    ;

yield_item_name
    : identifier {

    }
    ;

// TODO variable_name? see return_item_alias
yield_item_alias
    : AS variable_name {

    }
    ;

// Section 16.17 <group by clause>
group_by_clause
    : GROUP_BY grouping_element_list {

    }
    ;

grouping_element_list
    : grouping_elements {

    }
    | empty_grouping_set
    ;

// TODO
grouping_elements
    : grouping_element {

    }
    | grouping_elements COMMA grouping_element {

    }
    ;

grouping_element
    : binding_variable {

    }
    ;

empty_grouping_set
    : LEFT_PAREN RIGHT_PAREN {

    }
    ;

// Section 16.18 <order by clause>
order_by_clause
    : ORDER BY sort_specification_list {

    }
    ;

// Section 16.19 <aggregate function>
aggregate_function
    : COUNT LEFT_PAREN_ASTERISK_RIGHT_PAREN {

    }
    | general_set_function {

    }
    | binary_set_function {

    }
    ;

general_set_function
    : general_set_function_type LEFT_PAREN set_quantifier untyped_value_expression RIGHT_PAREN {

    }
    ;

binary_set_function
    : binary_set_function_type LEFT_PAREN dependent_value_expression COMMA independent_value_expression RIGHT_PAREN {

    }
    ;

general_set_function_type
    : AVG {

    }
    | COUNT {

    }
    | MAX {

    }
    | MIN {

    }
    | SUM {

    }
    | PRODUCT {

    }
    | COLLECT {

    }
    | stDev {

    }
    | stDevP {

    }
    ;

set_quantifier
    : DISTINCT {

    }
    | ALL {

    }
    ;

binary_set_function_type
    : percentileCont {

    }
    | percentileDist {

    }
    ;

// TODO numeric_value_expression is changed to untyped_value_expression
dependent_value_expression
    : opt_set_quantifier untyped_value_expression {

    }
    ;

// TODO numeric_value_expression is changed to untyped_value_expression
independent_value_expression
    : untyped_value_expression {

    }
    ;

// Section 16.20 <sort specification list>
sort_specification_list
    : sort_specification {
    
    }
    | sort_specification_list COMMA sort_specification {

    }
    ;

sort_specification
    : sort_key opt_ordering_specification opt_null_ordering {

    }
    ;

opt_ordering_specification
    : %empty {

    }
    | ordering_specification {

    }
    ;

opt_null_ordering
    : %empty {

    }
    | null_ordering {

    }
    ;

sort_key
    : untyped_value_expression {

    }
    ;

ordering_specification
    : ASC {
      
    }
    | DESC {
      
    }
    ;

null_ordering
    : NULLS FIRST {
      
    }
    | NULLS LAST {
      
    }
    ;

// Section 16.21 <limit clause>
limit_clause
    : LIMIT unsigned_integer_specification {

    }
    ;

// Section 16.22 <offset clause>
offset_clause
    : offset_synonym unsigned_integer_specification {
    
    }
    ;

offset_synonym
    : OFFSET {
    
    }
    | SKIP {

    }
    ;

// Chapter 17 Object references
// Section 17.1 Schema references
schema_reference
    : predefined_schema_parameter {
    
    }
    | catalog_schema_parent_and_name {
    
    }
    | external_object_reference {
    
    }
    ;

// TODO eg. /a/b/c, c is schema_name; /a/b/c/d, d is schema_name
catalog_schema_parent_and_name
    : SOLIDUS simple_relative_url_path_and_schema_name {

    }
    | url_path_parameter {
    
    }
    ;

// TODO
simple_relative_url_path_and_schema_name
    : simple_relative_url_path {

    }
    ;

opt_absolute_url_path
    : %empty {

    }
    | absolute_url_path {

    }
    ;

// Section 17.2 Graph references
graph_reference
    : graph_resolution_expression {
    
    }
    | local_graph_reference {
    
    }
    ;

graph_resolution_expression
    : GRAPH_SYNONYM catalog_graph_reference {
    
    }
    ;

catalog_graph_reference
    : catalog_graph_parent_and_name {
    
    }
    | predefined_graph_parameter %prec LOWER_THAN_SOLIDUS {
    
    }
    | external_object_reference {
    
    }
    ;

catalog_graph_parent_and_name
    : parent_catalog_object_reference {

    }
    | parent_catalog_object_reference PERIOD qualified_graph_name {

    }
    ;

// TODO
qualified_graph_name
    : qualified_object_name {

    }
    ;

local_graph_reference
    : qualified_graph_name {

    }
    ;

// Section 17.3 Graph type references
graph_type_reference
    : graph_type_resolution_expression {

    }
    | local_graph_type_reference {

    }
    ;

graph_type_resolution_expression
    : GRAPH_TYPE_SYNONYM catalog_graph_type_reference {

    }
    ;

catalog_graph_type_reference
    : catalog_graph_type_parent_and_name {

    }
    | external_object_reference {

    }
    ;

catalog_graph_type_parent_and_name
    : parent_catalog_object_reference {

    }
    | parent_catalog_object_reference PERIOD qualified_graph_type_name {

    }
    ;

local_graph_type_reference
    : qualified_graph_type_name {

    }
    ;

// TODO REWRITE
qualified_graph_type_name
    : qualified_object_name {

    }
    ;

// Section 17.4 Binding table references
// TODO
binding_table_reference
    : binding_table_resolution_expression {

    }
    | local_binding_table_reference {

    }
    ;

binding_table_resolution_expression
    : BINDING_TABLE_SYNONYM catalog_binding_table_reference {

    }
    ;

catalog_binding_table_reference
    : catalog_binding_table_parent_and_name {

    }
    | predefined_table_parameter {

    }
    | external_object_reference {

    }
    ;


catalog_binding_table_parent_and_name
    : parent_catalog_object_reference {

    }
    | parent_catalog_object_reference PERIOD qualified_binding_table_name {

    }
    ;

local_binding_table_reference
    : qualified_binding_table_name {

    }
    ;

qualified_binding_table_name
    : qualified_object_name {

    }
    ;

// Section 17.5 Procedure references
procedure_reference
    : procedure_resolution_expression {

    }
    | local_procedure_reference {

    }
    ;

procedure_resolution_expression
    : PROCEDURE catalog_procedure_reference {

    }
    ;

catalog_procedure_reference
    : catalog_procedure_parent_and_name {

    }
    | external_object_reference {

    }
    ;

catalog_procedure_parent_and_name
    : parent_catalog_object_reference {

    }
    | parent_catalog_object_reference PERIOD qualified_procedure_name {

    }
    ;

local_procedure_reference
    : qualified_procedure_name {

    }
    ;

qualified_procedure_name
    : qualified_object_name {

    }
    ;

// Section 17.6 Query references
query_reference
    : query_resolution_expression {

    }
    | local_query_reference {

    }
    ;

query_resolution_expression
    : QUERY catalog_query_reference {

    }
    ;

catalog_query_reference
    : catalog_query_parent_and_name {

    }
    | external_object_reference {

    }
    ;

catalog_query_parent_and_name
    : parent_catalog_object_reference {

    }
    | parent_catalog_object_reference PERIOD qualified_query_name {

    }
    ;

local_query_reference
    : qualified_query_name {

    }
    ;

qualified_query_name
    : qualified_object_name {

    }
    ;

// Section 17.7 Function references
function_reference
    : function_resolution_expression {

    }
    | local_function_reference {

    }
    ;

function_resolution_expression
    : FUNCTION catalog_function_reference {

    }
    ;

catalog_function_reference
    : catalog_function_parent_and_name {

    }
    | external_object_reference {

    }
    ;

catalog_function_parent_and_name
    : parent_catalog_object_reference {

    }
    | parent_catalog_object_reference PERIOD qualified_function_name {

    }
    ;

local_function_reference
    : qualified_function_name {

    }
    ;

qualified_function_name
    : qualified_object_name {

    }
    ;

// Section 17.8 <catalog object reference>
catalog_object_reference
    : catalog_url_path {

    }
    ;
// TODO: Handle such case: a/b/c/d, a/b/c d.e.f
parent_catalog_object_reference
    : catalog_object_reference {

    }
    // | catalog_object_reference SOLIDUS {

    // }
    ;

catalog_url_path
    : absolute_url_path {
 
    }
    | relative_url_path {

    }
    | parameterized_url_path {

    }
    ;

// TODO
absolute_url_path
    :
    // SOLIDUS {

    // }
    // |
    SOLIDUS simple_url_path {

    }
    ;

relative_url_path
    : parent_object_relative_url_path {

    }
    | simple_relative_url_path {

    }
    // | PERIOD {

    // }
    ;

// TODO
parent_object_relative_url_path
    : predefined_schema_parameter SOLIDUS simple_url_path {

    }
    | predefined_graph_parameter SOLIDUS simple_url_path {

    }
    ;

simple_relative_url_path
    : DOUBLE_PERIOD opt_solidus_and_double_period_list opt_solidus_and_simple_url_path {
    
    }
    | simple_url_path {

    }
    ;

opt_solidus_and_double_period_list
    : %empty {

    }
    | solidus_and_double_period_list {

    }
    ;

// TODO REWRITE
solidus_and_double_period_list
    : solidus_and_double_period {

    }
    | solidus_and_double_period_list solidus_and_double_period {

    }
    ;

solidus_and_double_period
    : SOLIDUS_DOUBLE_PERIOD {

    }
    ;

opt_solidus_and_simple_url_path
    : %empty %prec LOWER_THAN_SOLIDUS {

    }
    | solidus_and_simple_url_path {

    }
    ;

solidus_and_simple_url_path
    : SOLIDUS simple_url_path {

    }
    ;

parameterized_url_path
    : url_path_parameter %prec LOWER_THAN_SOLIDUS {

    }
    | url_path_parameter solidus_and_simple_url_path {

    }
    ;

simple_url_path
    : url_segment_list %prec LOWER_THAN_SOLIDUS {
    
    }
    ;

url_segment_list
    : url_segment {

    }
    | url_segment_list SOLIDUS url_segment {

    }
    ;

url_segment
    : identifier {

    }
    ;

// Section 17.9 <qualified object name>
// TODO REWRITE!!!
qualified_object_name
    : qualified_name_prefix_and_object_name {

    }
    ;

qualified_name_prefix_and_object_name
    : object_name {

    }
    | qualified_name_prefix_and_object_name PERIOD object_name {

    }
    ;

// Section 17.10 <url path parameter>
url_path_parameter
    : parameter {

    }
    ;

// Section 17.11 <external object reference>
external_object_reference
    : external_object_url {

    }
    ;

// 3) EOU shall either be an absolute-URL character string or an absolute-URL-with-fragment character
// string as specified by URL or it alternatively shall be a URI with a mandatory scheme as specified by
// RFC 3986 and RFC 3978.
// 4) EOU shall not conform to the Format for a <catalog url path>.
external_object_url
    :   //!! See_the_Syntax_Rules. // TODO
    OCCURRENCES_REGEX OCTET_LENGTH OPTIONAL {

    }
    ;

// Section 17.12 <element reference>
element_reference
    : element_variable {

    }
    ;

// Chapter 18 Functions
// All built-in (predefined) functions need to be added here

// Chapter 19 Predicates
// Section 19.1 <search condition>
// TODO: boolean_value_expression is changed to untyped_value_expression
search_condition
    : untyped_value_expression {

    }
    ;

// Section 19.2 <predicate>
// predicate
//     : complex_predicate {

//     }
//     | simple_predicate {

//     }
//     ;

complex_predicate
    :
    comparison_predicate {
      
    }
    |
    null_predicate {
      
    }
    | normalized_predicate {
      
    }
    ;

simple_predicate
    : exists_predicate {

    }
    | directed_predicate {
      
    }
    | labeled_predicate {
      
    }
    | source_or_destination_predicate {

    }
    | all_different_predicate {

    }
    | same_predicate {

    }
    ;

// Section 19.3 <comparison predicate>
comparison_predicate
    : untyped_value_expression EQUALS_OPERATOR untyped_value_expression {

    }
    | untyped_value_expression NOT_EQUALS_OPERATOR untyped_value_expression {

    }
    | untyped_value_expression LESS_THAN_OPERATOR untyped_value_expression %prec LEFT_ANGLE_BRACKET {

    }
    | untyped_value_expression GREATER_THAN_OPERATOR untyped_value_expression %prec RIGHT_ANGLE_BRACKET {

    }
    | untyped_value_expression LESS_THAN_OR_EQUALS_OPERATOR untyped_value_expression {

    }
    | untyped_value_expression GREATER_THAN_OR_EQUALS_OPERATOR untyped_value_expression {

    }
    ;

comparison_predicate_part_2
    : comp_op untyped_value_expression {

    }
    ;

comp_op
    : EQUALS_OPERATOR {

    }
    | NOT_EQUALS_OPERATOR {
      
    }
    | LEFT_ANGLE_BRACKET {
      
    }
    | RIGHT_ANGLE_BRACKET {
      
    }
    | LESS_THAN_OR_EQUALS_OPERATOR {
      
    }
    | GREATER_THAN_OR_EQUALS_OPERATOR {

    }
    ;

// Section 19.4 <exists predicate>
exists_predicate
    : EXISTS LEFT_PAREN graph_pattern RIGHT_PAREN {

    }
    | EXISTS nested_query_specification {

    }
    ;

// Section 19.5 <null predicate>
null_predicate
    : untyped_value_expression null_predicate_part_2 {

    }
    ;

null_predicate_part_2
    : IS_NULL {

    }
    | IS_NOT_NULL {

    }
    ;

// Section 19.6 <normalized predicate>
normalized_predicate
    : untyped_value_expression normalized_predicate_part_2 {

    }
    ;

normalized_predicate_part_2
    : IS opt_normal_form NORMALIZED {

    }
    | IS_NOT opt_normal_form NORMALIZED {

    }
    ;

opt_normal_form
    : %empty {

    }
    | normal_form {

    }
    ;

// Section 19.7 <directed predicate>
// TO May also need wrap it to untyped value expression.
// eg. v is directed
// eg. startNode(v) is directed
directed_predicate
    : element_reference directed_predicate_part_2 {

    }
    ;

directed_predicate_part_2
    : IS_DIRECTED {

    }
    | IS_NOT_DIRECTED {

    }
    ;

// Section 19.8 <labeled predicate>
labeled_predicate
    : element_reference labeled_predicate_part_2 {

    }
    ;

labeled_predicate_part_2
    : IS_LABELED label_expression {

    }
    | IS_NOT_LABELED label_expression {

    }
    ;


// Section 19.9 <source/destination_predicate>
source_or_destination_predicate
    : node_reference source_predicate_part_2 {
      
    }
    | node_reference destination_predicate_part_2 {

    }
    ;

node_reference
    : element_reference {

    }
    ;

// TODO
source_predicate_part_2
    : IS_SOURCE opt_of edge_reference {
      
    }
    | IS_NOT_SOURCE opt_of edge_reference {
      
    }
    ;

opt_of
    : %empty {

    }
    | OF {

    }
    ;

destination_predicate_part_2
    : IS_DESTINATION opt_of edge_reference {

    }
    | IS_NOT_DESTINATION opt_of edge_reference {

    }
    ;

edge_reference
    : element_reference {

    }
    ;

// TODO, at least 2 elements
// Section 19.10 <all_different predicate>
all_different_predicate
    : ALL_DIFFERENT LEFT_PAREN element_reference element_reference_list RIGHT_PAREN {

    }
    ;

// TODO, at least 2 elements
// Section 19.11 <same predicate>
same_predicate
    : SAME LEFT_PAREN element_reference element_reference_list RIGHT_PAREN {

    }
    ;

element_reference_list
    : element_reference {

    }
    | element_reference_list COMMA element_reference {

    }
    ;

// Chapter 20 Value expressions
// Section 20.1 <value specification>
// INACTIVE PARSING RULES
// value_specification
//     : literal {

//     }
//     | parameter_value_specification {

//     }
//     ;

// TODO parameter_value_specification seems redudant
unsigned_value_specification
    : unsigned_literal {
      
    }
    | parameter_value_specification {
      
    }
    ;

unsigned_integer_specification
    : unsigned_integer {
      
    }
    | parameter {
      
    }
    ;

parameter_value_specification
    : parameter {
      
    }
    | predefined_parameter {
      
    }
    ;

predefined_parameter
    : predefined_parent_object_parameter {
      
    }
    | predefined_table_parameter {
      
    }
    | CURRENT_USER {
      
    }
    ;

predefined_parent_object_parameter
    : predefined_schema_parameter {
      
    }
    | predefined_graph_parameter {
      
    }
    ;

predefined_schema_parameter
    : HOME_SCHEMA {
      
    }
    | CURRENT_SCHEMA {
      
    }
    ;

predefined_graph_parameter
    : EMPTY_PROPERTY_GRAPH {
      
    }
    | EMPTY_GRAPH {
      
    }
    | HOME_PROPERTY_GRAPH {
      
    }
    | HOME_GRAPH {
      
    }
    | CURRENT_PROPERTY_GRAPH {
      
    }
    | CURRENT_GRAPH {
      
    }
    ;

predefined_table_parameter
    : EMPTY_BINDING_TABLE {
      
    }
    | EMPTY_TABLE {
      
    }
    | UNIT_BINDING_TABLE {
      
    }
    | UNIT_TABLE {
      
    }
    ;

// Section 20.2 <value expression>
value_expression
    : untyped_value_expression opt_of_value_type {

    }
    ;

untyped_value_expression
    : generic_primary {

    }
    | complex_predicate {

    }
    | untyped_value_expression OR untyped_value_expression {

    }
    | untyped_value_expression XOR untyped_value_expression {
      
    }
    | untyped_value_expression AND untyped_value_expression {

    }
    | NOT untyped_value_expression {

    }
    | untyped_value_expression IS truth_value {

    }
    | untyped_value_expression IS_NOT truth_value {

    }
    // Seems reduant, because they could also produced by comparison_predicate
    // | untyped_value_expression EQUALS_OPERATOR truth_value {

    // }
    // | untyped_value_expression NOT_EQUALS_OPERATOR truth_value {

    // }
    | untyped_value_expression PLUS_SIGN untyped_value_expression {

    }
    | untyped_value_expression MINUS_SIGN untyped_value_expression {

    }
    | untyped_value_expression ASTERISK untyped_value_expression {

    }
    | untyped_value_expression SOLIDUS untyped_value_expression {

    }
    // 可能需要展开sign
    | PLUS_SIGN untyped_value_expression %prec UNARY_MINUS {

    }
    | MINUS_SIGN untyped_value_expression %prec UNARY_MINUS {

    }
    | untyped_value_expression CONCATENATION_OPERATOR untyped_value_expression {

    }
    // | LEFT_PAREN datetime_value_expression MINUS_SIGN datetime_term RIGHT_PAREN {

    // }
    | untyped_value_expression MULTISET_UNION opt_all_or_distinct untyped_value_expression {

    }
    | untyped_value_expression MULTISET_EXCEPT opt_all_or_distinct untyped_value_expression {

    }
    | untyped_value_expression MULTISET_INTERSECT opt_all_or_distinct untyped_value_expression {

    }
    ;

// 叶子结点
generic_primary
    : value_expression_primary {

    }
    | simple_predicate {

    }
    | numeric_value_function {

    }
    | string_value_function {

    }
    | datetime_value_function {

    }
    | duration_value_function {

    }
    | graph_element_function {

    }
    | list_value_function {

    }
    | multiset_value_function {

    }
    | primary_result_object_expression {

    }
    // absolute_value_expression, duration_absolute_value_function
    | ABS LEFT_PAREN untyped_value_expression RIGHT_PAREN {

    }
    ;

// untyped_value_expression
//     : common_value_expression {

//     }
//     | boolean_value_expression %prec LOWER_THAN_RIGHT_PAREN {

//     }
//     ;

// common_value_expression
//     : numeric_value_expression {
      
//     }
//     | string_value_expression {
      
//     }
//     | datetime_value_expression {
      
//     }
//     | duration_value_expression {
      
//     }
//     | collection_value_expression {
      
//     }
//     | map_value_expression {
      
//     }
//     | record_value_expression {
      
//     }
//     | reference_value_expression {
      
//     }
//     ;

// reference_value_expression
//     : primary_result_object_expression {
      
//     }
//     | graph_element_value_expression {
      
//     }
//     ;

// // TODO Why doesn't collection_value_expression contain map_value_expression and record_value_expression
// // Because collection_value_constructor contains map_value_constructor and record_value_constructor
// collection_value_expression
//     : list_value_expression {
      
//     }
//     | multiset_value_expression {
      
//     }
//     | set_value_expression {
      
//     }
//     | ordered_set_value_expression {
      
//     }
//     ;

// set_value_expression
//     : value_expression_primary {
      
//     }
//     ;

// ordered_set_value_expression
//     : value_expression_primary {
      
//     }
//     ;

// map_value_expression
//     : value_expression_primary {
      
//     }
//     ;

// record_value_expression
//     : value_expression_primary {
      
//     }
//     ;

// // Section 20.3 <boolean value expression>
// boolean_value_expression
//     : boolean_term {
      
//     }
//     | boolean_value_expression OR boolean_term {
      
//     }
//     | boolean_value_expression XOR boolean_term {
      
//     }
//     ;

// boolean_term
//     : boolean_factor {
      
//     }
//     | boolean_term AND boolean_factor {
      
//     }
//     ;

// boolean_factor
//     : boolean_test {

//     }
//     | NOT boolean_test {

//     }
//     ;

// boolean_test
//     : boolean_primary {

//     }
//     | boolean_primary IS truth_value {

//     }
//     | boolean_primary IS_NOT truth_value {

//     }
//     | boolean_primary EQUALS_OPERATOR truth_value {

//     }
//     | boolean_primary NOT_EQUALS_OPERATOR truth_value {

//     }
//     ;

truth_value
    : TRUE {

    }
    | FALSE {

    }
    | UNKNOWN {

    }
    | NULL {

    }
    ;

// boolean_primary
//     : predicate {

//     }
//     | boolean_predicand {

//     }
//     ;

// // TODO Boolean?
// boolean_predicand
//     : parenthesized_Boolean_value_expression {

//     }
//     | non_parenthesized_value_expression_primary {

//     }
//     ;

// parenthesized_Boolean_value_expression
//     : LEFT_PAREN boolean_value_expression RIGHT_PAREN {

//     }
//     ;

// // Section 20.4 <numeric value expression>
// numeric_value_expression
//     : term {
      
//     }
//     | numeric_value_expression PLUS_SIGN term {
      
//     }
//     | numeric_value_expression MINUS_SIGN term {
      
//     }
//     ;

// term
//     : factor {
      
//     }
//     | term ASTERISK factor {
      
//     }
//     | term SOLIDUS factor {
      
//     }
//     ;

// factor
//     : numeric_primary {

//     }
//     | sign numeric_primary {

//     }
//     ;

opt_sign
    : %empty {

    }
    | sign {

    }
    ;

// numeric_primary
//     :
//     value_expression_primary {

//     }
//     |
//     numeric_value_function {

//     }
//     ;

// Section 20.5 <value expression primary>
value_expression_primary
    : parenthesized_value_expression {
      
    }
    | non_parenthesized_value_expression_primary {
      
    }
    ;

parenthesized_value_expression
    : LEFT_PAREN untyped_value_expression RIGHT_PAREN {

    }
    ;

non_parenthesized_value_expression_primary
    : property_reference {
      
    }
    | binding_variable {
      
    }
    // TODO parameter_value_specification is in unsigned_value_specification
    // | parameter_value_specification {
      
    // }
    | unsigned_value_specification {
      
    }
    | aggregate_function {
      
    }
    // TODO collection_value_constructor seesm reduant, it's already included in unsigned_value_specification
    // | collection_value_constructor {
      
    // }
    | value_query_expression {
      
    }
    | case_expression {
      
    }
    | cast_specification {
      
    }
    | element_id_function {
      
    }
    ;

// Section 20.6 <numeric value function>
numeric_value_function
    : length_expression {
      
    }
    // | absolute_value_expression {
      
    // }
    | modulus_expression {
      
    }
    | trigonometric_function {
      
    }
    | general_logarithm_function {
      
    }
    | common_logarithm {
      
    }
    | natural_logarithm {
      
    }
    | exponential_function {
      
    }
    | power_function {
      
    }
    | square_root {
      
    }
    | floor_function {
      
    }
    | ceiling_function {
      
    }
    | inDegree_function {
      
    }
    | outDegree_function {
      
    }
    ;

length_expression
    : char_length_expression {
      
    }
    | byte_length_expression {
      
    }
    | path_length_expression {
      
    }
    ;

// TODO: character_string_value_expression is changed to untyped_value_expression
char_length_expression
    : CHARACTER_LENGTH LEFT_PAREN untyped_value_expression RIGHT_PAREN {

    }
    ;

// TODO: string_value_expression is changed to untyped_value_expression
byte_length_expression
    : BYTE_LENGTH LEFT_PAREN untyped_value_expression RIGHT_PAREN {

    }
    | OCTET_LENGTH LEFT_PAREN untyped_value_expression RIGHT_PAREN {

    }
    ;

path_length_expression
    : LENGTH LEFT_PAREN binding_variable RIGHT_PAREN {

    }
    ;

// TODO numeric_value_expression is changed to untyped_value_expression
// TODO same with duration_absolute_value_function
// absolute_value_expression
//     : ABS LEFT_PAREN untyped_value_expression RIGHT_PAREN {

//     }
//     ;

modulus_expression
    : MOD LEFT_PAREN numeric_value_expression_dividend COMMA numeric_value_expression_divisor RIGHT_PAREN {

    }
    ;

// TODO numeric_value_expression is changed to untyped_value_expression
numeric_value_expression_dividend
    : untyped_value_expression {

    }
    ;

numeric_value_expression_divisor
    : untyped_value_expression {

    }
    ;

// TODO numeric_value_expression is changed to untyped_value_expression
trigonometric_function
    : trigonometric_function_name LEFT_PAREN untyped_value_expression RIGHT_PAREN {

    }
    ;

trigonometric_function_name
    : SIN | COS | TAN | COT | SINH | COSH | TANH | ASIN | ACOS | ATAN | DEGREES | RADIANS {

    }
    ;

general_logarithm_function
    : LOG LEFT_PAREN general_logarithm_base COMMA general_logarithm_argument RIGHT_PAREN {

    }
    ;
// TODO numeric_value_expression is changed to untyped_value_expression
general_logarithm_base
    : untyped_value_expression {

    }
    ;

// TODO numeric_value_expression is changed to untyped_value_expression
general_logarithm_argument
    : untyped_value_expression {

    }
    ;

// TODO numeric_value_expression is changed to untyped_value_expression
common_logarithm
    : LOG10 LEFT_PAREN untyped_value_expression RIGHT_PAREN {

    }
    ;

// TODO numeric_value_expression is changed to untyped_value_expression
natural_logarithm
    : LN LEFT_PAREN untyped_value_expression RIGHT_PAREN {

    }
    ;

// TODO numeric_value_expression is changed to untyped_value_expression
exponential_function
    : EXP LEFT_PAREN untyped_value_expression RIGHT_PAREN {

    }
    ;

// TODO numeric_value_expression is changed to untyped_value_expression
power_function
    : POWER LEFT_PAREN untyped_value_expression COMMA untyped_value_expression RIGHT_PAREN {

    }
    ;

// TODO numeric_value_expression is changed to untyped_value_expression
numeric_value_expression_base
    : untyped_value_expression {

    }
    ;

// TODO numeric_value_expression is changed to untyped_value_expression
numeric_value_expression_exponent
    : untyped_value_expression {

    }
    ;

// TODO numeric_value_expression is changed to untyped_value_expression
square_root
    : SQRT LEFT_PAREN untyped_value_expression RIGHT_PAREN {

    }
    ;

// TODO numeric_value_expression is changed to untyped_value_expression
floor_function
    : FLOOR LEFT_PAREN untyped_value_expression RIGHT_PAREN {

    }
    ;

// TODO numeric_value_expression is changed to untyped_value_expression
ceiling_function
    : ceil_synonym LEFT_PAREN untyped_value_expression RIGHT_PAREN {

    }
    ;

ceil_synonym
    : CEIL {

    }
    | CEILING {

    }
    ;

inDegree_function
    : inDegree LEFT_PAREN binding_variable RIGHT_PAREN {

    }
    ;

outDegree_function
    : outDegree LEFT_PAREN binding_variable RIGHT_PAREN {

    }
    ;

// Section 20.7 <string value expression>
// string_value_expression
//     : character_string_value_expression {

//     }
//     | byte_string_value_expression {

//     }
//     ;

// character_string_value_expression
//     : character_string_concatenation {
      
//     }
//     | character_string_factor {
      
//     }
//     ;

// character_string_concatenation
//     : character_string_value_expression CONCATENATION_OPERATOR character_string_factor {

//     }
//     ;

// character_string_factor
//     : character_string_primary {

//     }
//     ;

// character_string_primary
//     :
//     value_expression_primary {

//     }
//     |
//     string_value_function {

//     }
//     ;

// byte_string_value_expression
//     : byte_string_concatenation {
      
//     }
//     | byte_string_factor {
      
//     }
//     ;

// byte_string_factor
//     : byte_string_primary {
      
//     }
//     ;

// byte_string_primary
//     :
//     value_expression_primary {
      
//     }
//     |
//     string_value_function {
      
//     }
//     ;

// byte_string_concatenation
//     : byte_string_value_expression CONCATENATION_OPERATOR byte_string_factor {
      
//     }
//     ;

// Section 20.8 <string value function>
string_value_function
    : character_or_byte_string_function {
      
    }
    // | byte_string_function {
      
    // }
    ;

character_or_byte_string_function
    : substring_function {
      
    }
    | fold {
      
    }
    | trim_function {
      
    }
    | normalize_function {
      
    }
    ;

// TODO: character_string_value_expression is changed to untyped_value_expression
substring_function
    : SUBSTRING LEFT_PAREN untyped_value_expression COMMA start_position RIGHT_PAREN {
      
    }
    | SUBSTRING LEFT_PAREN untyped_value_expression COMMA start_position COMMA string_length RIGHT_PAREN {
      
    }
    | LEFT LEFT_PAREN untyped_value_expression COMMA string_length RIGHT_PAREN {
      
    }
    | RIGHT LEFT_PAREN untyped_value_expression COMMA string_length RIGHT_PAREN {
      
    }
    ;

// TODO: character_string_value_expression is changed to untyped_value_expression
fold
    : UPPER LEFT_PAREN untyped_value_expression RIGHT_PAREN {

    }
    | toUpper LEFT_PAREN untyped_value_expression RIGHT_PAREN {
      
    }
    | LOWER LEFT_PAREN untyped_value_expression RIGHT_PAREN {
      
    }
    | toLower LEFT_PAREN untyped_value_expression RIGHT_PAREN {
      
    }
    ;

trim_function
    : TRIM LEFT_PAREN untyped_value_expression RIGHT_PAREN {

    }
    | TRIM LEFT_PAREN untyped_value_expression COMMA trim_specification RIGHT_PAREN {

    }
    | TRIM LEFT_PAREN untyped_value_expression COMMA trim_specification untyped_value_expression RIGHT_PAREN {

    }
    | lTrim LEFT_PAREN untyped_value_expression RIGHT_PAREN {

    }
    | rTrim LEFT_PAREN untyped_value_expression RIGHT_PAREN {

    }
    ;

// TODO: character_string_value_expression is changed to untyped_value_expression
// trim_source
//     : untyped_value_expression {

//     }
//     ;

trim_specification
    : LEADING {
      
    }
    | TRAILING {
      
    }
    | BOTH {
      
    }
    ;

// TODO: character_string_value_expression is changed to untyped_value_expression
// TODO: trim_character_string is changed to trim_string, in order to merge with trim_byte_string
// trim_string
//     : untyped_value_expression {
      
//     }
//     ;

// TODO: character_string_value_expression is changed to untyped_value_expression
normalize_function
    : NORMALIZE LEFT_PAREN untyped_value_expression RIGHT_PAREN {
      
    }
    | NORMALIZE LEFT_PAREN untyped_value_expression COMMA normal_form RIGHT_PAREN {
      
    }
    ;

normal_form
    : NFC {

    }
    | NFD {

    }
    | NFKC {

    }
    | NFKD {

    }
    ;

// byte_string_function
//     : byte_substring_function {
      
//     }
//     | byte_string_trim_function {
      
//     }
//     ;

// // TODO: byte_string_value_expression is changed to untyped_value_expression
// // TODO: same with substring_function
// byte_substring_function
//     : SUBSTRING LEFT_PAREN untyped_value_expression COMMA start_position RIGHT_PAREN {

//     }
//     | SUBSTRING LEFT_PAREN untyped_value_expression COMMA start_position COMMA string_length RIGHT_PAREN {
      
//     }
//     | LEFT LEFT_PAREN untyped_value_expression COMMA string_length RIGHT_PAREN {

//     }
//     | RIGHT LEFT_PAREN untyped_value_expression COMMA string_length RIGHT_PAREN {

//     }
//     ;

// byte_string_trim_function
//     : TRIM LEFT_PAREN byte_string_trim_source RIGHT_PAREN {

//     }
//     | TRIM LEFT_PAREN byte_string_trim_source COMMA trim_specification RIGHT_PAREN {
      
//     }
//     | TRIM LEFT_PAREN byte_string_trim_source COMMA trim_specification trim_byte_string RIGHT_PAREN {
      
//     }
//     | lTrim LEFT_PAREN byte_string_trim_source RIGHT_PAREN {

//     }
//     | rTrim LEFT_PAREN byte_string_trim_source RIGHT_PAREN {

//     }
//     ;

// // TODO: byte_string_value_expression is changed to untyped_value_expression
// byte_string_trim_source
//     : untyped_value_expression {

//     }
//     ;

// trim_byte_string
//     : untyped_value_expression {

//     }
//     ;

// TODO numeric_value_expression is changed to untyped_value_expression
start_position
    : untyped_value_expression {

    }
    ;

// TODO numeric_value_expression is changed to untyped_value_expression
string_length
    : untyped_value_expression {

    }
    ;

// Section 20.9 <datetime value expression>
// datetime_value_expression
//     : datetime_term {

//     }
//     | duration_value_expression PLUS_SIGN datetime_term {

//     }
//     | datetime_value_expression PLUS_SIGN duration_term {

//     }
//     | datetime_value_expression MINUS_SIGN duration_term {

//     }
//     ;
    
// datetime_term
//     : datetime_factor {

//     }
//     ;

// datetime_factor
//     : datetime_primary {

//     }
//     ;

// datetime_primary
//     :
//     value_expression_primary {

//     }
//     |
//     datetime_value_function {

//     }
//     ;

// Section 20.10 <datetime value function>
datetime_value_function
    : date_function {
      
    }
    | time_function {
      
    }
    | datetime_function {
      
    }
    | local_time_function {
      
    }
    | local_datetime_function {
      
    }
    ;

date_function
    : CURRENT_DATE {
      
    }
    | DATE LEFT_PAREN RIGHT_PAREN {
      
    }
    | DATE LEFT_PAREN date_function_parameters RIGHT_PAREN {
      
    }
    ;

time_function
    : CURRENT_TIME {

    }
    | TIME LEFT_PAREN RIGHT_PAREN {

    }
    | TIME LEFT_PAREN time_function_parameters RIGHT_PAREN {

    }
    ;

local_time_function
    : LOCALTIME {

    }
    | LOCALTIME LEFT_PAREN RIGHT_PAREN {

    }
    | LOCALTIME LEFT_PAREN time_function_parameters RIGHT_PAREN {
      
    }
    ;

datetime_function
    : CURRENT_TIMESTAMP {

    }
    | DATETIME LEFT_PAREN RIGHT_PAREN {

    }
    | DATETIME LEFT_PAREN datetime_function_parameters RIGHT_PAREN {
      
    }
    ;

local_datetime_function
    : LOCALTIMESTAMP {

    }
    | LOCALDATETIME LEFT_PAREN RIGHT_PAREN {

    }
    | LOCALDATETIME LEFT_PAREN datetime_function_parameters RIGHT_PAREN {

    }
    ;

date_function_parameters
    : date_string {

    }
    | map_literal {
      
    }
    ;

time_function_parameters
    : time_string {
      
    }
    | map_literal {
      
    }
    ;

datetime_function_parameters
    : datetime_string {
      
    }
    | map_literal {
      
    }
    ;

// Section 20.11 <duration value expression>
// duration_value_expression
//     : duration_term {

//     }
//     | duration_value_expression_1 PLUS_SIGN duration_term_1 {

//     }
//     | duration_value_expression_1 MINUS_SIGN duration_term_1 {

//     }
//     | LEFT_PAREN datetime_value_expression MINUS_SIGN datetime_term RIGHT_PAREN {

//     }
//     ;

// duration_term
//     : duration_factor {

//     }
//     | duration_term_2 ASTERISK factor {

//     }
//     | duration_term_2 SOLIDUS factor {

//     }
//     | term ASTERISK duration_factor {

//     }
//     ;

// duration_factor
//     : duration_primary {

//     }
//     | sign duration_primary {
      
//     }
//     ;

// duration_primary
//     :
//     value_expression_primary {

//     }
//     |
//     duration_value_function {

//     }
//     ;

// duration_value_expression_1
//     : duration_value_expression {

//     }
//     ;

// duration_term_1
//     : duration_term {

//     }
//     ;

// duration_term_2
//     : duration_term {

//     }
//     ;

// Section 20.12 <duration value function>
duration_value_function
    : duration_function {

    }
    // TODO: merged to generic_term
    // | duration_absolute_value_function {

    // }
    ;

duration_function
    : DURATION LEFT_PAREN duration_function_parameters RIGHT_PAREN {

    }
    ;

duration_function_parameters
    : duration_string {

    }
    | map_literal {

    }
    ;

// TODO duration_value_expression is changed to untyped_value_expression
// TODO same with absolute_value_expression
// duration_absolute_value_function
//     : ABS LEFT_PAREN untyped_value_expression RIGHT_PAREN {

//     }
//     ;

// // Section 20.13 <graph element value expression>
// graph_element_value_expression
//     : graph_element_primary {

//     }
//     ;

graph_element_primary
    :
    graph_element_function {

    }
    |
    value_expression_primary {

    }
    ;

// Section 20.14 <graph element function>
graph_element_function
    : start_node_function {

    }
    | end_node_function {

    }
    ;

start_node_function
    : startNode LEFT_PAREN binding_variable RIGHT_PAREN {

    }
    ;

end_node_function
    : endNode LEFT_PAREN binding_variable RIGHT_PAREN {

    }
    ;

// Section 20.15 <collection value constructor>
// collection_value_constructor
//     : list_value_constructor {
      
//     }
//     | multiset_value_constructor {
      
//     }
//     | set_value_constructor {
      
//     }
//     | ordered_set_value_constructor {
      
//     }
//     | map_value_constructor {
      
//     }
//     | record_value_constructor {
      
//     }
//     ;

// Section 20.16 <list value expression>
// list_value_expression
//     : list_concatenation {
      
//     }
//     | list_primary {
      
//     }
//     ;

// list_concatenation
//     : list_value_expression_1 CONCATENATION_OPERATOR list_primary {
      
//     }
//     ;

// list_value_expression_1
//     : list_value_expression {
      
//     }
//     ;

// list_primary
//     :
//     list_value_function {
      
//     }
//     |
//     value_expression_primary {
      
//     }
//     ;

// Section 20.17 <list value function>
list_value_function
    : tail_list_function {
      
    }
    | trim_list_function {
      
    }
    ;

// TODO: list_value_expression is changed to untyped_value_expression
tail_list_function
    : tail LEFT_PAREN untyped_value_expression RIGHT_PAREN {
      
    }
    ;

// TODO: list_value_expression is changed to untyped_value_expression
// TODO numeric_value_expression is changed to untyped_value_expression
trim_list_function
    : TRIM LEFT_PAREN untyped_value_expression COMMA untyped_value_expression RIGHT_PAREN {
      
    }
    ;

// TODO xx_value_construct seems reduant
// Section 20.18 <list value constructor>
// list_value_constructor
//     : list_value_constructor_by_enumeration {
      
//     }
//     ;

list_value_constructor_by_enumeration
    : list_value_type_name LEFT_BRACKET list_element_list RIGHT_BRACKET {
      
    }
    ;

list_element_list
    : list_element {
    
    }
    | list_element_list COMMA list_element {

    }
    ;

list_element
    : untyped_value_expression {

    }
    ;

// Section 20.19 <multiset value expression>
// multiset_value_expression
//     : multiset_term {

//     }
//     | multiset_value_expression MULTISET_UNION opt_all_or_distinct multiset_term {

//     }
//     | multiset_value_expression MULTISET_EXCEPT opt_all_or_distinct multiset_term {

//     }
//     ;

// TODO
opt_all_or_distinct
    : %empty {

    }
    | all_or_distinct {

    }
    ;

all_or_distinct
    : ALL {

    }
    | DISTINCT {

    }
    ;

// multiset_term
//     : multiset_primary {

//     }
//     | multiset_term MULTISET_INTERSECT opt_all_or_distinct multiset_primary {

//     }
//     ;

// multiset_primary
//     :
//     multiset_value_function {

//     }
//     |
//     value_expression_primary {

//     }
//     ;

// Section 20.20 <multiset value function>
multiset_value_function
    : multiset_set_function {
      
    }
    ;

// TODO: multiset_value_expression is changed to untyped_value_expression
multiset_set_function
    : SET LEFT_PAREN untyped_value_expression RIGHT_PAREN {

    }
    ;

// TODO xx_value_construct seems reduant
// Section 20.21 <multiset value constructor>
// multiset_value_constructor
//     : multiset_value_constructor_by_enumeration {

//     }
//     ;

multiset_value_constructor_by_enumeration
    : MULTISET LEFT_BRACE multiset_element_list RIGHT_BRACE {

    }
    ;

multiset_element_list
    : multiset_element {
    
    }
    | multiset_element_list COMMA multiset_element {

    }
    ;

multiset_element
    : untyped_value_expression {

    }
    ;

// TODO xx_value_construct seems reduant
// Section 20.22 <set value constructor>
// set_value_constructor
//     : set_value_constructor_by_enumeration {

//     }
//     ;

set_value_constructor_by_enumeration
    : SET LEFT_BRACE set_element_list RIGHT_BRACE {

    }
    ;

set_element_list
    : set_element {
    
    }
    | set_element_list COMMA set_element {

    }
    ;

set_element
    : untyped_value_expression {

    }
    ;

// TODO xx_value_construct seems reduant
// Section 20.23 <ordered set value constructor>
// ordered_set_value_constructor
//     : ordered_set_value_constructor_by_enumeration {

//     }
//     ;

ordered_set_value_constructor_by_enumeration
    : ORDERED SET LEFT_BRACE ordered_set_element_list RIGHT_BRACE {

    }
    | ORDERED SET LEFT_BRACKET ordered_set_element_list RIGHT_BRACKET {

    }
    ;

ordered_set_element_list
    : ordered_set_element {
    
    }
    | ordered_set_element_list COMMA ordered_set_element {

    }
    ;

ordered_set_element
    : untyped_value_expression {

    }
    ;

// TODO xx_value_construct seems reduant
// Section 20.24 <map value constructor>
// map_value_constructor
//     : map_value_constructor_by_enumeration {

//     }
//     ;

map_value_constructor_by_enumeration
    : MAP LEFT_BRACE map_element_list RIGHT_BRACE {

    }
    ;

map_element_list
    : map_element {
    
    }
    | map_element_list COMMA map_element {

    }
    ;

map_element
    : map_key map_value {

    }
    ;

map_key
    : untyped_value_expression COLON {

    }
    ;

map_value
    : untyped_value_expression {

    }
    ;

// TODO xx_value_construct seems reduant
// Section 20.25 <record value constructor>
// record_value_constructor
//     : record_value_constructor_by_enumeration {

//     }
//     | UNIT {

//     }
//     ;

// opt_record
record_value_constructor_by_enumeration
    : LEFT_BRACE field_list RIGHT_BRACE {

    }
    | RECORD LEFT_BRACE field_list RIGHT_BRACE {
      
    }
    ;

field_list
    : field {
    
    }
    | field_list COMMA field {

    }
    ;

field
    : field_name field_value {

    }
    ;

field_value
    : untyped_value_expression {

    }
    ;

// Section 20.26 <property reference>
// TODO: WARNING
property_reference
    : graph_element_primary PERIOD property_name {

    }
    ;

// Section 20.27 <value query expression>
value_query_expression
    : VALUE nested_query_specification {

    }
    ;

// Section 20.28 <case expression>
case_expression
    : case_abbreviation {

    }
    | case_specification {

    }
    ;

// TODO
case_abbreviation
    : NULLIF LEFT_PAREN untyped_value_expression COMMA untyped_value_expression RIGHT_PAREN {

    }
    | COALESCE LEFT_PAREN value_expression_list RIGHT_PAREN {

    }
    ;
  
value_expression_list
    : untyped_value_expression {

    }
    | value_expression_list COMMA untyped_value_expression {

    }
    ;

case_specification
    : simple_case {

    }
    | searched_case {

    }
    ;
    
simple_case
    : CASE case_operand simple_when_clause_list opt_else_clause END {

    }
    ;

simple_when_clause_list
    : simple_when_clause {

    }
    | simple_when_clause_list simple_when_clause {

    }
    ;

opt_else_clause
    : %empty {

    }
    | else_clause {

    }
    ;

searched_case
    : CASE searched_when_clause_list opt_else_clause END {

    }
    ;

searched_when_clause_list
    : searched_when_clause {

    }
    | searched_when_clause_list searched_when_clause {

    }
    ;

simple_when_clause
    : WHEN when_operand_list THEN result {

    }
    ;

searched_when_clause
    : WHEN search_condition THEN result {

    }
    ;

else_clause
    : ELSE result {

    }
    ;

case_operand
    : non_parenthesized_value_expression_primary {

    }
    // TODO: conflicted with binding_variable of non_parenthesized_value_expression_primary
    // | element_reference {

    // }
    ;

when_operand_list
    : when_operand {
    
    }
    | when_operand_list COMMA when_operand {

    }
    ;

when_operand
    : non_parenthesized_value_expression_primary {

    }
    | comparison_predicate_part_2 {
      
    }
    | null_predicate_part_2 {
      
    }
    | directed_predicate_part_2 {
      
    }
    | labeled_predicate_part_2 {
      
    }
    | source_predicate_part_2 {
      
    }
    | destination_predicate_part_2 {
      
    }
    ;

// TODO NULL seems redudant
result
    : result_expression {
      
    }
    // | NULL {
      
    // }
    ;

result_expression
    : untyped_value_expression {
      
    }
    ;

// Section 20.29 <cast specification>
cast_specification
    : CAST LEFT_PAREN cast_operand AS cast_target RIGHT_PAREN {
      
    }
    ;

// TODO null_literal seems redudant here
cast_operand
    : untyped_value_expression {
      
    }
    // | null_literal {
      
    // }
    ;

cast_target
    : predefined_type {
      
    }
    ;

// Section 20.30 <element id function>
element_id_function
    : ELEMENT_ID LEFT_PAREN element_reference RIGHT_PAREN {
      
    }
    ;

// Chapter 21 Lexical elements
// Section 21.1 <literal>
literal
    : signed_numeric_literal {
      
    }
    | general_literal {
      
    }
    ;

// TODO conflict: record_literal record_value_constructor...
general_literal
    : predefined_type_literal {
      
    }
    | list_literal {
      
    }
    | set_literal {
      
    }
    | multiset_literal {
      
    }
    | ordered_set_literal {
      
    }
    | map_literal {
      
    }
    | record_literal {
      
    }
    ;

// TODO
// character_string_literal is changed to UNBROKEN_CHARACTER_STRING_LITERAL | CHARACTER_STRING_LITERAL here.
// The original rule is:
// predefined_type_literal
//     : boolean_literal
//     | character_string_literal
//     | byte_string_literal
//     | temporal_literal
//     | duration_literal
//     | null_literal
//     ;
predefined_type_literal
    : boolean_literal {
      
    }
    | UNBROKEN_CHARACTER_STRING_LITERAL {
      
    }
    | CHARACTER_STRING_LITERAL {
      
    }
    | BYTE_STRING_LITERAL {
      
    }
    | temporal_literal {
      
    }
    | duration_literal {
      
    }
    | null_literal {
      
    }
    ;

unsigned_literal
    : UNSIGNED_NUMERIC_LITERAL {
      
    }
    | general_literal {
      
    }
    ;

boolean_literal
    : TRUE {
    
    }
    | FALSE {
    
    }
    | UNKNOWN {
    
    }
    ;

signed_numeric_literal
    : opt_sign UNSIGNED_NUMERIC_LITERAL {

    }
    ;

sign
    : PLUS_SIGN {

    }
    | MINUS_SIGN {

    }
    ;

unsigned_integer
    : UNSIGNED_DECIMAL_INTEGER {

    }
    | UNSIGNED_HEXADECIMAL_INTEGER {

    }
    | UNSIGNED_OCTAL_INTEGER {

    }
    | UNSIGNED_BINARY_INTEGER {

    }
    ;

temporal_literal
    : date_literal {

    }
    | time_literal {

    }
    | datetime_literal {

    }
    ;

date_literal
    : DATE date_string {

    }
    ;

time_literal
    : TIME time_string {
      
    }
    ;

datetime_literal
    : DATETIME datetime_string {
      
    }
    | TIMESTAMP datetime_string {
      
    }
    ;

date_string
    : UNBROKEN_CHARACTER_STRING_LITERAL {

    }
    ;

time_string
    : UNBROKEN_CHARACTER_STRING_LITERAL {

    }
    ;

datetime_string
    : UNBROKEN_CHARACTER_STRING_LITERAL {

    }
    ;

duration_literal
    : DURATION duration_string {

    }
    // | SQL_interval_literal {

    // }
    ;

duration_string
    : UNBROKEN_CHARACTER_STRING_LITERAL {

    }
    ;

// // <SQL-interval literal> shall conform to the Syntax Rules of <interval literal> in ISO/IEC 9075-2:202x.
// SQL_interval_literal
//     : interval_literal {

//     }
//     ;

// interval_literal
//     : INTERVAL opt_sign interval_string interval_qualifier {

//     }
//     ;

// interval_string
//     : QUOTE unquoted_interval_string QUOTE {

//     }
//     ;

// unquoted_interval_string
//     : opt_sign year_month_literal {
    
//     }
//     | opt_sign day_time_literal {

//     }
//     ;

// year_month_literal
//     : years_value {
    
//     }
//     | years_value MINUS_SIGN months_value {

//     }
//     | months_value {

//     }
//     ;
  
// day_time_literal
//     : day_time_interval {

//     }
//     | time_interval {

//     }
//     ;

// // TODO space? shift/reduce error
// day_time_interval
//     : days_value {

//     }
//     | days_value space hours_value {

//     }
//     | days_value space hours_value COLON minutes_value {

//     }
//     | days_value space hours_value COLON minutes_value COLON seconds_value {

//     }
//     ;

// day_time_interval
//     : days_value {

//     }
//     | days_value hours_value {

//     }
//     | days_value hours_value COLON minutes_value {

//     }
//     | days_value hours_value COLON minutes_value COLON seconds_value {

//     }
//     ;

// time_interval
//     : hours_value {
      
//     }
//     | hours_value COLON minutes_value {

//     }
//     | hours_value COLON minutes_value COLON seconds_value {

//     }
//     | minutes_value {

//     }
//     | minutes_value COLON seconds_value {

//     }
//     | seconds_value {

//     }
//     ;

// years_value
//     : datetime_value {

//     }
//     ;

// months_value
//     : datetime_value {

//     }
//     ;

// days_value
//     : datetime_value {

//     }
//     ;

// hours_value
//     : datetime_value {

//     }
//     ;

// minutes_value
//     : datetime_value {

//     }
//     ;

// seconds_value
//     : seconds_integer_value {
      
//     }
//     | seconds_integer_value PERIOD {

//     }
//     | seconds_integer_value PERIOD seconds_fraction {

//     }
//     ;

// seconds_integer_value
//     : unsigned_integer {

//     }
//     ;

// seconds_fraction
//     : unsigned_integer {

//     }
//     ;

// datetime_value
//     : unsigned_integer {

//     }
//     ;


// interval_qualifier
//     : start_field TO end_field {

//     }
//     | single_datetime_field {

//     }
//     ;

// start_field
//     : non_second_primary_datetime_field {

//     }
//     | non_second_primary_datetime_field LEFT_PAREN interval_leading_field_precision RIGHT_PAREN {

//     }
//     ;

// end_field
//     : non_second_primary_datetime_field {

//     }
//     | SECOND {
    
//     }
//     | SECOND LEFT_PAREN interval_fractional_seconds_precision RIGHT_PAREN {

//     }
//     ;

// single_datetime_field
//     : non_second_primary_datetime_field {

//     }
//     | non_second_primary_datetime_field LEFT_PAREN interval_leading_field_precision RIGHT_PAREN {

//     }
//     | SECOND {
    
//     }
//     | SECOND LEFT_PAREN interval_leading_field_precision RIGHT_PAREN {

//     }
//     | SECOND LEFT_PAREN interval_leading_field_precision COMMA interval_fractional_seconds_precision RIGHT_PAREN {

//     }
//     ;

// non_second_primary_datetime_field
//     : YEAR {

//     }
//     | MONTH {
      
//     }
//     | DAY {
      
//     }
//     | HOUR {
      
//     }
//     | MINUTE {
      
//     }
//     ;

// interval_leading_field_precision
//     : unsigned_integer {

//     }
//     ;

// interval_fractional_seconds_precision
//     : unsigned_integer {

//     }
//     ;


null_literal
    : NULL {

    }
    ;

list_literal
    : list_value_constructor_by_enumeration {
      
    }
    ;

set_literal
    : set_value_constructor_by_enumeration {
      
    }
    ;

multiset_literal
    : multiset_value_constructor_by_enumeration {
      
    }
    ;

ordered_set_literal
    : ordered_set_value_constructor_by_enumeration {
      
    }
    ;

map_literal
    : map_value_constructor_by_enumeration {
      
    }
    ;

record_literal
    : record_value_constructor_by_enumeration {
      
    }
    | UNIT {
      
    }
    ;

// Section 21.2 <value type>
value_type
    : ANY {
      
    }
    | predefined_type {
      
    }
    | graph_element_type {
      
    }
    | collection_type {
      
    }
    | map_value_type {
      
    }
    | record_value_type {
      
    }
    | graph_type_expression {
      
    }
    | binding_table_type_expression {
      
    }
    | NOTHING {
      
    }
    ;

of_value_type
    : value_type {
      
    }
    | of_type_prefix value_type {
      
    }
    ;

of_type_prefix
    : DOUBLE_COLON {
      
    }
    | OF {

    }
    ;

predefined_type
    : boolean_type {
      
    }
    | character_string_type {
      
    }
    | byte_string_type {
      
    }
    | numeric_type {
      
    }
    | temporal_type {
      
    }
    ;

boolean_type
    : BOOL  {
      
    }
    | BOOLEAN {
      
    }
    ;

character_string_type
    : string_or_varchar {
    
    }
    | string_or_varchar LEFT_PAREN max_length RIGHT_PAREN {

    }
    ;

byte_string_type
    : BYTES {
    
    }
    | BYTES  LEFT_PAREN max_length RIGHT_PAREN {

    }
    | BYTES  LEFT_PAREN min_length COMMA max_length RIGHT_PAREN {

    }
    | BINARY {
    
    }
    | BINARY fixed_length {

    }
    | VARBINARY {
    
    }
    | VARBINARY max_length {

    }
    ;

min_length
    : UNSIGNED_DECIMAL_INTEGER {

    }
    ;

max_length
    : UNSIGNED_DECIMAL_INTEGER {
      
    }
    ;

fixed_length
    : UNSIGNED_DECIMAL_INTEGER {
      
    }
    ;

numeric_type
    : exact_numeric_type {
      
    }
    | approximate_numeric_type {
      
    }
    ;

exact_numeric_type
    : binary_exact_numeric_type {
      
    }
    | decimal_exact_numeric_type {
      
    }
    ;

binary_exact_numeric_type
    : binary_exact_signed_numeric_type {
      
    }
    | binary_exact_unsigned_numeric_type {
      
    }
    ;

binary_exact_signed_numeric_type
    : INT8 {
      
    }
    | INT16 {
      
    }
    | INT32 {
      
    }
    | INT64 {
      
    }
    | INT128 {
      
    }
    | INT256 {
      
    }
    | SMALLINT {
      
    }
    | INT {
    
    }
    | INT LEFT_PAREN precision RIGHT_PAREN {
      
    }
    | BIGINT {

    }
    | verbose_binary_exact_numeric_type {

    }
    | SIGNED verbose_binary_exact_numeric_type {

    }
    ;

binary_exact_unsigned_numeric_type
    : UINT8 {

    }
    | UINT16 {

    }
    | UINT32 {

    }
    | UINT64 {

    }
    | UINT128 {

    }
    | UINT256 {

    }
    | UINT {
    
    }
    | UINT LEFT_PAREN precision RIGHT_PAREN {

    }
    | UNSIGNED verbose_binary_exact_numeric_type {

    }
    ;

verbose_binary_exact_numeric_type
    : INTEGER8 {

    }
    | INTEGER16 {

    }
    | INTEGER32 {

    }
    | INTEGER64 {

    }
    | INTEGER128 {

    }
    | INTEGER256 {

    }
    | INTEGER {
    
    }
    | INTEGER LEFT_PAREN precision RIGHT_PAREN {

    }
    ;

decimal_exact_numeric_type
    : decimal_synonym LEFT_PAREN precision RIGHT_PAREN {

    }
    | decimal_synonym LEFT_PAREN precision COMMA scale RIGHT_PAREN {

    }
    ;

precision
    : UNSIGNED_DECIMAL_INTEGER {

    }
    ;

scale
    : UNSIGNED_DECIMAL_INTEGER {

    }
    ;

approximate_numeric_type
    : FLOAT16 {
      
    }
    | FLOAT32 {
      
    }
    | FLOAT64 {
      
    }
    | FLOAT128 {

    }
    | FLOAT256 {

    }
    | FLOAT {
    
    }
    | FLOAT LEFT_PAREN precision RIGHT_PAREN {

    }
    | FLOAT LEFT_PAREN precision COMMA scale RIGHT_PAREN {

    }
    | REAL {

    }
    | DOUBLE {
    
    }
    | DOUBLE PRECISION {

    }
    ;

temporal_type
    : DATETIME {

    }
    | LOCALDATETIME {
      
    }
    | DATE {
      
    }
    | TIME {
      
    }
    | LOCALTIME {
      
    }
    | DURATION {
      
    }
    ;

graph_element_type
    : NODE_SYNONYM {

    }
    | EDGE_SYNONYM {

    }
    ;

collection_type
    : list_value_type {

    }
    | multiset_value_type {

    }
    | set_value_type {

    }
    | ordered_set_value_type {

    }
    ;

list_value_type
    : value_type list_value_type_name {

    }
    ;

list_value_type_name
    : LIST {

    }
    | ARRAY {
      
    }
    ;

multiset_value_type
    : value_type MULTISET {
      
    }
    ;

set_value_type
    : value_type SET {
      
    }
    ;

ordered_set_value_type
    : value_type ORDERED SET {

    }
    ;

map_value_type
    : MAP LEFT_ANGLE_BRACKET map_key_type COMMA value_type RIGHT_ANGLE_BRACKET {

    }
    ;

map_key_type
    : predefined_type {

    }
    ;

// TODO opt_record
record_value_type
    : LEFT_BRACE opt_field_type_list RIGHT_BRACE {

    }
    | RECORD LEFT_BRACE opt_field_type_list RIGHT_BRACE {
      
    }
    ;

opt_field_type_list
    : %empty {

    }
    | field_type_list {

    }
    ;
  
field_type_list
    : field_type {
    
    }
    | field_type_list COMMA field_type {

    }
    ;

field_type
    : field_name opt_of_type_prefix value_type {

    }
    ;

// Section 21.3 Names and identifiers
object_name
    : identifier {

    }
    ;

schema_name
    : identifier {

    }
    ;

graph_name
    : identifier {

    }
    ;

element_type_name
    : type_name {
      
    }
    ;

graph_type_name
    : identifier {
      
    }
    ;

type_name
    : identifier {
      
    }
    ;

binding_table_name
    : identifier {
      
    }
    ;

// INACTIVE PARSING RULES
// value_name
//     : identifier {
      
//     }
//     ;

procedure_name
    : identifier {
      
    }
    ;

query_name
    : identifier {
      
    }
    ;

function_name
    : identifier {
      
    }
    ;

label_name
    : identifier {
      
    }
    ;

property_name
    : identifier {
      
    }
    ;

field_name
    : identifier {
      
    }
    ;

// INACTIVE PARSING RULES
// path_pattern_name
//     : identifier {
      
//     }
//     ;


element_variable
    : variable_name {
      
    }
    ;

path_variable
    : variable_name {
      
    }
    ;

subpath_variable
    : variable_name {
      
    }
    ;

static_variable_name
    : variable_name {
      
    }
    ;

binding_variable_name
    : variable_name {
      
    }
    ;

variable_name
    : REGULAR_IDENTIFIER {
      
    }
    ;

identifier
    : REGULAR_IDENTIFIER {
      
    }
    | DELIMITED_IDENTIFIER {

    }
    ;


// separated_identifier
//     : extended_identifier
//     | delimited_identifier
//     ;

string_or_varchar
    : STRING {

    }
    | VARCHAR {

    }
    ;

decimal_synonym
    : DECIMAL {

    }
    | DEC {

    }
    ;

// moved_from_gql.ll
GREATER_THAN_OPERATOR
    : RIGHT_ANGLE_BRACKET
    ;

LESS_THAN_OPERATOR
    : LEFT_ANGLE_BRACKET
    ;

%%


void nebula::GraphParser::error(const nebula::GraphParser::location_type& loc,
                                const std::string &msg) {
    std::ostringstream os;
    if (msg.empty()) {
        os << "syntax error";
    } else {
        os << msg;
    }

    auto *query = scanner.query();
    if (query == nullptr) {
        os << " at " << loc;
        errmsg = os.str();
        return;
    }

    auto begin = loc.begin.column > 0 ? loc.begin.column - 1 : 0;
    if ((loc.end.filename
        && (!loc.begin.filename
            || *loc.begin.filename != *loc.end.filename))
        || loc.begin.line < loc.end.line
        || begin >= query->size()) {
        os << " at " << loc;
    } else if (loc.begin.column < (loc.end.column ? loc.end.column - 1 : 0)) {
        uint32_t len = loc.end.column - loc.begin.column;
        if (len > 80) {
            len = 80;
        }
        os << " near `" << query->substr(begin, len) << "'";
    } else {
        os << " near `" << query->substr(begin, 8) << "'";
    }

    errmsg = os.str();
}

// check the positive integer boundary
// parameter input accept the INTEGER value
// which filled as uint64_t
// so the conversion is expected
void ifOutOfRange(const int64_t input,
                  const nebula::GraphParser::location_type& loc) {
    if ((uint64_t)input >= MAX_ABS_INTEGER) {
        throw nebula::GraphParser::syntax_error(loc, "Out of range:");
    }
}

static int yylex(nebula::GraphParser::semantic_type* yylval,
                 nebula::GraphParser::location_type *yylloc,
                 nebula::GraphScanner& scanner) {
    auto token = scanner.yylex(yylval, yylloc);
    return token;
}
