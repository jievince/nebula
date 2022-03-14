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


%start GQL_request

%%

// Section_6.1_GQL_request
GQL_request
    : GQL_program {

    }
    | request_parameter_set GQL_program {

    }
    ;


// Section_6.2_request_parameter_set
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


// Section_6.3_GQL_program
GQL_program
    : main_activity {
    }
    | preamble main_activity {

    }
    ;

main_activity
    : session_activity {

    }
    | opt_session_activity transaction_session_activities opt_session_close_command {

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

transaction_session_activities
    : transaction_session_activity {

    }
    | transaction_session_activities transaction_session_activity {

    }
    ;

transaction_session_activity
    : transaction_activity {

    }
    | transaction_activity session_activity {

    }
    ;


session_activity
    : session_clear_command session_parameter_commands {

    }
    | session_parameter_commands {

    }
    ;

session_parameter_commands
    : session_parameter_command {

    }
    | session_parameter_commands session_parameter_command {

    }
    ;

session_parameter_command
    : session_set_command {

    }
    | session_remove_command {

    }
    ;

transaction_activity
    : start_transaction_command {
    
    }
    | start_transaction_command procedure_specification {
      
    }
    | start_transaction_command procedure_specification end_transaction_command {

    }
    | procedure_specification {

    }
    | procedure_specification end_transaction_command {

    }
    | end_transaction_command {

    }
    ;


// Section_6.4_preamble
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
    : IDENTIFIER {

    }
    ;


// Section_7.1_session_set_command
session_set_command
    : SESSION SET session_set_schema_clause {

    }
    | SESSION SET session_set_graph_clause {

    }
    | SESSION SET session_set_time_zone_clause {

    }
    | SESSION SET session_set_parameter_clause {

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

set_time_zone_value
    : string_value_expression {

    }
    ;

session_set_parameter_clause
    : session_parameter {

    }
    | session_parameter_flag session_parameter {

    }
    | session_parameter_flag session_parameter IF_NOT_EXISTS {

    }
    ;

session_parameter
    : parameter_definition {

    }
    | PARAMETER parameter_definition {

    }
    ;

session_parameter_flag
    : MUTABLE {

    }
    | FINAL {

    }
    ;


// Section_7.2_session_remove_command
session_remove_command
    : REMOVE parameter {

    }
    | SESSION REMOVE parameter {

    }
    | SESSION REMOVE parameter IF_EXISTS {

    }
    ;


// Section_7.3_session_clear_command
session_clear_command
    : CLEAR
    | SESSION CLEAR {

    }
    ;


// Section_7.4_session_close_command
session_close_command
    : CLOSE
    | SESSION CLOSE {

    }
    ;


// Section_8.1_start_transaction_command
start_transaction_command
    : START TRANSACTION {

    }
    | START TRANSACTION transaction_characteristics {

    }
    ;


// Section_8.2_end_transaction_command
end_transaction_command
    : commit_command {

    }
    | rollback_command {

    }
    ;


// Section_8.3_transaction_characteristics
transaction_characteristics
    : transaction_mode {

    }
    | transaction_characteristics COMMA transaction_mode {

    }
    ;

transaction_mode
    : transaction_access_mode {

    }
    | implementation_defined_access_mode {

    }
    ;

transaction_access_mode
    : READ ONLY {

    }
    | READ WRITE {

    }
    ;

implementation_defined_access_mode
    : !! See_the_Syntax_Rules.
    ;


// Section_8.4_rollback_command
rollback_command
    : ROLLBACK {

    }
    ;


// Section_8.5_commit_command
commit_command
    : COMMIT {

    }
    ;


// Section_9.1_procedure_specification
nested_procedure_specification
    : LEFT_BRACE procedure_specification RIGHT_BRACE {

    }
    ;

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

nested_catalog_modifying_procedure_specification
    : LEFT_BRACE catalog_modifying_procedure_specification RIGHT_BRACE {

    }
    ;

nested_catalog_modifying_procedure_specification
    : 
    !! Predicative_production_rule.
    procedure_body {

    }
    ;

nested_data_modifying_procedure_specification
    : LEFT_BRACE data_modifying_procedure_specification RIGHT_BRACE {

    }
    ;

data_modifying_procedure_specification
    :
    !! Predicative_production_rule.
    procedure_body {

    }
    ;


// Section_9.2_query_specification
nested_query_specification
    : LEFT_BRACE query_specification RIGHT_BRACE {

    }
    ;

query_specification
    :
    !! Predicative_production_rule.
    procedure_body {

    }
    ;


// Section_9.3_function_specification
nested_function_specification
    : LEFT_BRACE function_specification RIGHT_BRACE {

    }
    ;

function_specification
    :
    !! Predicative_production_rule.
    procedure_body {

    }
    ;


// Section_9.4_procedure_body
procedure_body
    : opt_static_variable_definition_block opt_binding_variable_definition_block statement_block {

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


// Section_10.1_Static_variable_definitions
static_variable_definition
    : procedure_variable_definition {

    }
    | query_variable_definition {

    }
    | function_variable_definition {

    }
    ;

as_or_equals
    : AS
    | EQUALS_OPERATOR {

    }
    ;


// Section_10.2_Procedure_variable_definition
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


// Section_10.3_Query_variable_definition
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


// Section_10.4_Function_variable_definition
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


// Section_10.5_Binding_variable_and parameter_declarations_and_definitions
compact_variable_declaration_list
    : compact_variable_declaration {

    }
    | compact_variable_declaration_list COMMA compact_variable_declaration {

    }
    ;

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
    : value_variable EQUALS_OPERATOR value_expression {

    }
    ;

binding_variable_definition_list
    : binding_variable_definition {

    }
    | binding_variable_definition_list COMMA binding_variable_definition {

    }
    ;

binding_variable_definition
    : graph_variable_definition {

    }
    | binding_table_variable_definition {

    }
    | value_variable_definition {

    }
    ;

optional_binding_variable_definition_list
    : optional_binding_variable_definition {

    }
    | optional_binding_variable_definition_list COMMA optional_binding_variable_definition {

    }
    ;

optional_binding_variable_definition
    : optional_graph_variable_definition {

    }
    | optional_binding_table_variable_definition {

    }
    | optional_value_variable_definition {

    }
    ;

parameter_definition
    : graph_parameter_definition {

    }
    | binding_table_parameter_definition {

    }
    | value_parameter_definition {

    }
    ;



// Section_10.6_Graph_variable_and parameter_declaration_and_definition
graph_variable_declaration
    : PROPERTY_GRAPH graph_variable of_graph_type {

    }
    ;

optional_graph_variable_definition
    : graph_variable_definition {

    }
    ;

graph_variable_definition
    : PROPERTY_GRAP _graph_variable of_graph_type graph_initializer {
      
    }
    ;

graph_parameter_definition
    : PROPERTY_GRAPH PARAMETER_NAME of_graph_type graph_initializer {

    }
    | PROPERTY_GRAPH PARAMETER_NAME IF_NOT_EXISTS of_graph_type graph_initializer {

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



// Section_10.7_Binding_table_variable and_parameter_declaration_and definition
binding_table_variable_declaration
    : BINDING_TABLE binding_table_variable of_binding_table_type
    ;

optional_binding_table_variable_definition
    : binding_table_variable_definition {

    }
    ;

binding_table_variable_definition
    : BINDING_TABLE binding_table_variable of_binding_table_type binding_table_initializer {

    }
    ;

binding_table_parameter_definition
    : BINDING_TABLE parameter of_binding_table_type binding_table_initializer {

    }
    | BINDING_TABLE parameter IF_NOT_EXISTS of_binding_table_type binding_table_initializer {
      
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


// Section_10.8_Value_variable_and parameter_declaration_and_definition
value_variable_declaration
    : VALUE value_variable {

    }
    | VALUE value_variable of_value_type {
      
    }
    ;

optional_value_variable_definition
    : value_variable_definition {

    }
    ;

value_variable_definition
    : VALUE value_variable value_initializer {

    }
    | VALUE value_variable of_value_type value_initializer {

    }
    ;

value_parameter_definition
    : VALUE parameter opt_IF_NOT_EXISTS opt_of_value_type value_initializer {

    }
    ;

opt_IF_NOT_EXISTS
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

value_initializer
    : as_or_equals value_expression {

    }
    | nested_query_specification {

    }
    | AS nested_query_specification {

    }
    | COLON catalog_object_reference {

    }
    ;


// Section_11.2_primary_result_object_expression
primary_result_object_expression
    : graph_expression {

    }
    | binding_table_reference {

    }
    ;



// Section_11.3_graph_expression
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



// Section_11.4_graph_type_expression
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
    : PROPERTY_GRAPH TYPE like_graph_expression_shorthand {

    }
    ;

of_graph_type
    : graph_type_expression {

    }
    | of_type_prefix graph_type_expression {

    }
    | like_graph_expression_shorthand {

    }
    | nested_graph_type_specification {

    }
    | of_type_prefix nested_graph_type_specification {
      
    }
    ;

like_graph_expression_shorthand
    : LIKE graph_expression {

    }
    ;



// Section_11.5_binding_table_type_expression
of_binding_table_type
    : binding_table_type_expression {

    }
    | of_type_prefix binding_table_type_expression {

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
    : BINDING_TABLE record_value_type {

    }
    ;

like_binding_table_type
    : BINDING_TABLE like_binding_table_shorthand {

    }
    ;

like_binding_table_shorthand
    : LIKE binding_table_reference {

    }
    ;


// Section_12.1_statement
statement
    : opt_at_schema_clause catalog_modifying_statement {

    }
    | opt_at_schema_clause data_modifying_statement {

    }
    | opt_at_schema_clause query_statement {

    }
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



// Section_12.2_call_procedure_statement
call_procedure_statement
    : CALL procedure_call {

    }
    | statement_mode CALL procedure_call {

    }
    ;

statement_mode
    : OPTIONAL {

    }
    | MANDATORY {

    }
    ;


// Section_12.3_Statement_classes
simple_catalog_modifying_statement
    : primitive_catalog_modifying_statement {

    }
    | call_catalog_modifying_procedure_statement {

    }
    ;

primitive_catalog_modifying_statement
    : create_graph_statement {

    }
    | create_graph_type_statement {

    }
    | create_procedure_statement {
      
    }
    | create_query_statement {
      
    }
    | create_function_statement {
      
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
    | order_by_and_page statement {
      
    }
    ;



// Section_13.1_linear_catalog_modifying_statement
linear_catalog_modifying_statement
    : simple_catalog_modifying_statement {

    }
    | linear_catalog_modifying_statement simple_catalog_modifying_statement {

    }
    ;



// Section_13.2_create_schema_statement
create_schema_statement
    : CREATE SCHEMA catalog_schema_parent_and_name opt_IF_NOT_EXISTS {

    }
    ;


// Section_13.3_drop_schema_statement
drop_schema_statement
    : DROP SCHEMA catalog_schema_parent_and_name opt_IF_EXISTS {
      
    }
    ;


// Section_13.4_create_graph_statement
create_graph_statement
    : CREATE PROPERTY_GRAPH catalog_graph_parent_and_name opt_IF_NOT_EXISTS opt_of_graph_type opt_graph_source {

    }
    | CREATE OR REPLACE PROPERTY_GRAPH catalog_graph_parent_and_name opt_of_graph_type opt_graph_source {

    }
    ;

opt_of_graph_type
    : %empty {

    }
    | of_graph_type {

    }
    ;

opt_graph_source
    : %emtpy {

    }
    | graph_source {

    }
    ;

graph_source
    : AS copy_graph_expression {

    }
    ;


// Section_13.5_graph_specification
graph_specification
    : PROPERTY_GRAPH nested_graph_query_specification {

    }
    | PROPERTY_GRAPH nested_ambient_data_modifying_procedure_specification {

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


// Section_13.6_drop_graph_statement
drop_graph_statement
    : DROP GRAPH catalog_graph_parent_and_name opt_IF_EXISTS {

    }
    ;


// Section_13.7_create_graph_type_statement
create_graph_type_statement
    : CREATE PROPERTY_GRAPH TYPE opt_IF_NOT_EXISTS graph_type_initializer {

    }
    | CREATE OR REPLACE PROPERTY_GRAPH TYPE graph_type_initializer {

    }
    ;

graph_type_initializer
    : as_graph_type {

    }
    | COLON catalog_graph_type_reference {

    }
    ;



// Section_13.8_graph_type_specification
graph_type_specification
    : PROPERTY_GRAPH TYPE nested_graph_type_specification {

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


// Section_13.9_node_type_definition
node_type_definition
    : LEFT_PAREN opt_node_type_name opt_node_type_filler RIGHT_PAREN {

    }
    | node_synonym node_type_name node_type_filler {

    }
    | node_synonym TYPE node_type_name node_type_filler {
      
    }
    ;

opt_node_type_name
    : %emtpy {

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
    : !! Predicative_production_rule.
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
    : !! Predicative_production_rule.
    label_set_definition {

    }
    ;

node_type_property_type_set_definition
    : !! Predicative_production_rule.
    property_type_set_definition {

    }
    ;



// Section_13.10_edge_type_definition
edge_type_definition
    : full_edge_type_pattern {

    }
    | abbreviated_edge_type_pattern {

    }
    | edge_kind edge_synonym edge_type_name edge_type_filler endpoint_definition {

    }
    | edge_kind edge_synonym TYPE edge_type_name edge_type_filler endpoint_definition {

    }
    ;

edge_type_name
    : !! Predicative_production_rule.
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
    : !! Predicative_production_rule.
    label_set_definition {

    }
    ;

edge_type_property_type_set_definition
    : !! Predicative_production_rule.
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
    : %epmty {

    }
    | edge_type_name {

    }
    ;

abbreviated_edge_type_pattern
    : abbreviated_edge_type_pattern pointing_right
    | abbreviated_edge_type_pattern pointing_left
    | abbreviated_edge_type_pattern any_direction
    ;

abbreviated_edge_type_pattern pointing_right
    : source_node_type_reference RIGHT_ARROW__destination_node type_reference
    ;

abbreviated_edge_type_pattern pointing_left
    : destination_node_type_reference LEFT_ARROW__source_node type_reference
    ;

abbreviated_edge_type_pattern any_direction
    : source_node_type_reference TILDE__destination_node_type reference
    ;

source_node_type_reference
    : LEFT_PAREN source_node_type_name RIGHT_PAREN {

    }
    | LEFT_PAREN opt_node_type_filler RIGHT_PAREN {

    }
    ;

destination_node_type_reference
    : LEFT_PAREN destination_node_type_name RIGHT_PAREN {

    }
    | LEFT_PAREN opt_node_type_filler RIGHT_PAREN {

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

endpoint_pair_definition_pointing_right
    : LEFT_PAREN source_node_type_name connector_pointing_right destination_node_type_name RIGHT_PAREN {

    }
    ;

endpoint_pair_definition_pointing left
    : LEFT_PAREN destination_node_type_name LEFT_ARROW source_node_type_name RIGHT_PAREN {

    }
    ;

endpoint_pair_definition_any direction
    : LEFT_PAREN source_node_type_name connector_any_direction destination_node_type_name RIGHT_PAREN {

    }
    ;

connector_pointing_right
    : TO
    | RIGHT_ARROW
    ;

connector_any_direction
    : TO
    | TILDE
    ;

source_node_type_name
    : !! Predicative_production_rule.
    element_type_name {

    }
    ;

destination_node_type_name
    : !! Predicative_production_rule.
    element_type_name {

    }
    ;


// Section_13.11_label_set_definition
label_set_definition
    : LABEL label {

    }
    | LABELS label_expression {

    }
    | is_label_expression {

    }
    ;


// Section_13.12_property_type_set definition
property_type_set_definition
    : LEFT_BRACE opt_property_type_definition_list RIGHT_BRACE {

    }
    ;

opt_property_type_definition_list
    : %emtpy {

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


// Section_13.13_drop_graph_type statement
drop_graph_type_statement
    : DROP PROPERTY_GRAPH TYPE ; opt_IF_EXISTS {

    }
    ;


// Section_13.14_create_procedure_statement
create_procedure_statement
    : CREATE PROCEDURE_catalog_procedure_parent_and_name of_type_signature opt_IF_NOT_EXISTS procedure_initializer {

    }
    | CREATE OR REPLACE PROCEDURE catalog_procedure_parent_and_name of_type_signature procedure_initializer {

    }
    ;


// Section_13.15_drop_procedure_statement
drop_procedure_statement
    : DROP PROCEDURE catalog_procedure_parent_and_name opt_IF_EXISTS {

    }
    ;


// Section_13.16_create_query_statement
create_query_statement
    : CREATE QUERY catalog_query_parent_and_name of_type_signature opt_IF_NOT_EXISTS query_initializer {

    }
    | CREATE OR REPLACE QUERY catalog_query_parent_and_name of_type_signature query_initializer {

    }
    ;


// Section_13.17_drop_query_statement
drop_query_statement
    : DROP QUERY catalog_query_parent_and_name opt_IF_EXISTS {

    }
    ;


// Section_13.18_create_function_statement
create_function_statement
    : CREATE FUNCTION catalog_function_parent_and_name of_type_signature opt_IF_NOT_EXISTS function_initializer {

    }
    | CREATE OR REPLACE FUNCTION catalog_function_parent_and_name of_type_signature function_initializer {

    }
    ;


// Section_13.19_drop_function_statement
drop_function_statement
    : DROP FUNCTION catalog_function_parent_and_name opt_IF_EXISTS {

    }
    ;


// Section_13.20_call_catalog_modifying_procedure_statement
call_catalog_modifying_procedure_statement
    : call_procedure_statement {

    }
    ;


// Section_14.1_linear_data_modifying_statement
linear_data_modifying_statement
    : focused_linear_data_modifying_statement {

    }
    | ambient_linear_data_modifying_statement {

    }
    ;

focused_linear_data_modifying_statement
    : use_graph_clause focused_linear_data_modifying_statement_bodies {

    }
    ;

focused_linear_data_modifying_statement_bodies
    : focused_linear_data_modifying_statement_body {

    }
    | focused_linear_data_modifying_statement_bodies focused_linear_data_modifying_statement_body {

    }
    ;

// TODO?
focused_linear_data_modifying_statement_body
    : opt_simple_linear_query_statement opt_use_graph_clause_and_simple_linear_query_statements simple_data_modifying_statement opt_simple_data_accessing_statements opt_use_graph_clause_and_simple_data_accessing_statements opt_primitive_result_statement {

    }
    | nested_data_modifying_procedure_specification {

    }
    ;

opt_simple_linear_query_statement
    : %empty {

    }
    | simple_linear_query_statement {

    }
    ;

opt_use_graph_clause_and_simple_linear_query_statements
    : %empty {

    }
    | use_graph_clause_and_simple_linear_query_statements {

    }
    ;

use_graph_clause_and_simple_linear_query_statements
    : use_graph_clause_and_simple_linear_query_statement {

    }
    | use_graph_clause_and_simple_linear_query_statements use_graph_clause_and_simple_linear_query_statement {

    }
    ;

use_graph_clause_and_simple_linear_query_statement
    : use_graph_clause simple_linear_query_statement {

    }
    ;

opt_simple_data_accessing_statements
    : %empty {

    }
    | simple_data_accessing_statements {

    }
    ;
  
simple_data_accessing_statements
    : %empty {

    }
    | simple_data_accessing_statements simple_data_accessing_statement {

    }
    ;

opt_use_graph_clause_and_simple_data_accessing_statements
    : %empty {

    }
    | use_graph_clause_and_simple_data_accessing_statements {

    }
    ;

use_graph_clause_and_simple_data_accessing_statements
    : use_graph_clause_and_simple_data_accessing_statement {

    }
    | use_graph_clause_and_simple_data_accessing_statements use_graph_clause_and_simple_data_accessing_statement {

    }
    ;

use_graph_clause_and_simple_data_accessing_statement
    : use_graph_clause simple_data_accessing_statement {

    }
    ;

opt_primitive_result_statement
    : %empty {

    }
    | primitive_result_statement {

    }
    ;

ambient_linear_data_modifying_statement
    : opt_simple_linear_query_statement simple_data_modifying_statement opt_simple_data_accessing_statements opt_primitive_result_statement {

    }
    | nested_data_modifying_procedure_specification {

    }
    ;


// Section_14.2_conditional_data_modifying_statement
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


// Section_14.3_do_statement
do_statement
    : DO nested_data_modifying_procedure_specification {

    }
    ;


// Section_14.4_insert_statement
insert_statement
    : INSERT simple_graph_pattern {

    }
    | OPTIONAL INSERT simple_graph_pattern opt_when_clause {

    }
    ;


// Section_14.5_merge_statement
merge_statement
    : MERGE simple_graph_pattern {

    }
    ;



// Section_14.6_set_statement
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
    : binding_variable PERIOD property_name EQUALS_OPERATOR value_expression {
      
    }
    ;

set_all_properties_item
    : binding_variable EQUALS_OPERATOR value_expression {

    }
    ;

set_label_item
    : label_set_expression {

    }
    ;

/* TODO
<label set expression> ::=
<AMPERSAND> <label>... { <AMPERSAND> <label>... }
*/
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

// Section_14.7_remove_statement
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


// Section_14.8_delete_statement
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
    : value_expression {

    }
    ;


// Section_14.9_call_data_modifying_procedure statement
call_data_modifying_procedure_statement
    : call_procedure_statement {

    }
    ;


// Section_15.1_composite_query_statement
composite_query_statement
    : composite_query_expression {

    }
    ;


// Section_15.2_conditional_query_statement
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
    : %emtpy {

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


// Section_15.3_composite_query_expression
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


// Section_15.4_linear_query_expression
linear_query_expression
    : linear_query_statement {

    }
    ;



// Section_15.5_linear_query_statement
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
    : opt_simple_linear_query_statement primitive_result_statement {

    }
    | nested_query_specification {

    }
    ;

// TODO
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


/* Section_15.6_Data_reading_statements */
// Section_15.6.1_match_statement
match_statement
    : opt_statement_mode MATCH graph_pattern {

    }
    ;

opt_statement_mode
    : %empty {

    }
    | statement_mode {

    }
    ;

// Section_15.6.2_call_query_statement
call_query_statement
    : call_procedure_statement {

    }
    ;


/* Section_15.7_Data_transforming_statements */
// Section_15.7.1_mandatory_statement
mandatory_statement
    : MANDATORY procedure_call {

    }
    ;



// Section_15.7.2_optional_statement
optional_statement
    : OPTIONAL procedure_call {

    }
    ;

// Section_15.7.3_filter_statement
filter_statement
    : FILTER where_clause {

    }
    | FILTER search_condition {

    }
    ;


// Section_15.7.4_let_statement
let_statement
    : LET compact_variable_definition_list {

    }
    | statement_mode LET compact_variable_definition_list where_clause {
      
    }
    ;


// Section_15.7.5_aggregate_statement
aggregate_statement
    : AGGREGATE_compact_value_variable_definition_list_where clause
    ;


// Section_15.7.6_for_statement
for_statement
    : opt_statement_mode FOR for_item_list opt_for_ordinality_or_index opt_where_clause {

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

for_item
    : for_item_alias collection_value_expression {

    }
    ;

for_item_alias
    : IDENTIFIER IN {

    }
    ;

for_ordinality_or_index
    : WITH ORDINALITY opt_identifier {

    }
    | WITH INDEX opt_identifier {

    }
    ;


// Section_15.7.7_order_by_and page_statement
order_by_and_page_statement
    : order_by_clause opt_offset_clause opt_limit_clause {

    }
    | offset_clause opt_limit_clause {

    }
    | limit_clause {

    }
    ;

opt_offset_clause
    : %empty {

    }
    | offset_clause {

    }
    ;

opt_limit_clause
    : %empty {

    }
    | limit_clause {

    }
    ;

// Section_15.7.8_call_function_statement
call_function_statement
    : call_procedure_statement {

    }
    ;


/* Section_15.8_Result_projection_statements */
// Section_15.8.1_primitive_result_statement
primitive_result_statement
    : return_statement {
    
    }
    | return_statement order_by_and_page_statement {

    }
    | project_statement {

    }
    | END {

    }
    ;


// Section_15.8.2_return_statement
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

opt_set_quantifier
    : %empty {

    }
    | set_quantifier {

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
    : value_expression {
    }
    | value_expression return_item_alias {

    }
    ;

return_item_alias
    : AS IDENTIFIER {

    }
    ;


// Section_15.8.3_select_statement
select_statement
    : SELECT opt_set_quantifier select_item_list select_statement_body opt_where_clause opt_group_by_clause opt_having_clause opt_order_by_clause opt_offset_clause opt_limit_clause {

    }
    ;

select_item_list
    : select_item {
    
    }
    | select_item_list COMMA select_item {

    }
    ;

select_item
    : value_expression {
    
    }
    | value_expression select_item_alias {

    }
    ;

select_item_alias
    : AS IDENTIFIER {

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

select_graph_match_list
    : select_graph_match {

    }
    | select_graph_match_list COMMA select_graph_match {

    }
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

// Section_16.1_from_graph_clause
from_graph_clause
    : FROM graph_expression {

    }
    ;


// Section_16.2_use_graph_clause
use_graph_clause
    : USE graph_expression {

    }
    ;


// Section_16.3_at_schema_clause
at_schema_clause
    : AT schema_reference {

    }
    ;


// Section_16.4_Named_elements
static_variable
    : static_variable_name {

    }
    ;

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


// Section_16.5_type_signature
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
    | mandatory_formal_parameter_list COMMA optional_formal_parameter_list {

    }
    | optional_formal_parameter_list {

    }
    ;

mandatory_formal_parameter_list
    : formal_parameter_declaration_list {
      
    }
    ;

optional_formal_parameter_list
    : OPTIONAL formal_parameter_definition_list {

    }
    ;

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

optional_parameter_cardinality
    : %empty {
    
    }
    | parameter_cardinality {

    }
    ;

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


// Section_16.6_graph_pattern
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
    : %empty {

    }
    | path_variable EQUALS_OPERATOR {

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


// Section_16.7_path_pattern_expression
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
    | opt_element_pattern_cost_clause {

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
    : property_name COLON value_expression {

    }
    ;

element_pattern_cost_clause
    : cost_clause {

    }
    ;

cost_clause
    : COST value_expression {
    
    }
    | COST value_expression DEFAULT value_expression {

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


// Section_16.8_path_pattern_prefix
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

counted_shortest_path_search
    : SHORTEST number_of_paths opt_path_mode opt_path_or_paths {

    }
    ;

counted_shortest_group_search
    : SHORTEST number_of_groups opt_path_mode opt_path_or_paths group_or_groups {
      
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


// Section_16.9_simple_graph_pattern
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
    : !! Predicative_production_rule.
    path_pattern_expression {

    }
    ;


// Section_16.10_label_expression
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


// Section_16.11_simplified_path_pattern expression
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


// Section_16.12_where_clause
where_clause
    : WHERE search_condition {

    }
    ;


// Section_16.13_procedure_call
procedure_call
    : inline_procedure_call {

    }
    | named_procedure_call {

    }
    ;


// Section_16.14_inline_procedure_call
inline_procedure_call
    : nested_procedure_specification {

    }
    ;


// Section_16.15_named_procedure_call
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
    : value_expression {

    }
    ;


// Section_16.16_yield_clause
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

opt_yield_item_alias
    : %empty {

    }
    | yield_item_alias {

    }
    ;

yield_item_name
    : IDENTIFIER {

    }
    ;

yield_item_alias
    : AS variable_name {

    }
    ;


// Section_16.17_group_by_clause
group_by_clause
    : GROUP BY grouping_element_list {

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


// Section_16.18_order_by_clause
order_by_clause
    : ORDER_BY sort_specification_list {

    }
    ;


// Section_16.19_aggregate_function
aggregate_function
    : COUNT LEFT_PAREN ASTERISK RIGHT_PAREN {

    }
    | general_set_function {

    }
    | binary_set_function {

    }
    ;

general_set_function
    : general_set_function_type LEFT_PAREN set_quantifier value_expression RIGHT_PAREN {

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

dependent_value_expression
    : opt_set_quantifier numeric_value_expression {

    }
    ;

independent_value_expression
    : numeric_value_expression {

    }
    ;

// Section_16.20_sort_specification_list
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
    : value_expression {

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

// Section_16.21_limit_clause
limit_clause
    : LIMIT unsigned_integer_specification {

    }
    ;


// Section_16.22_offset_clause
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


// Section_17.1_Schema_references
schema_reference
    : predefined_schema_parameter {
    
    }
    | catalog_schema_parent_and_name {
    
    }
    | external_object_reference {
    
    }
    ;

catalog_schema_parent_and_name
    : opt_absolute_url_path SOLIDUS schema_name {

    }
    | url_path_parameter {
    
    }
    ;


// Section_17.2_Graph_references
graph_reference
    : graph_resolution_expression {
    
    }
    | local_graph_reference {
    
    }
    ;

graph_resolution_expression
    : PROPERTY_GRAPH catalog_graph_reference {
    
    }
    ;

catalog_graph_reference
    : catalog_graph_parent_and_name {
    
    }
    | predefined_graph_parameter {
    
    }
    | external_object_reference {
    
    }
    ;

catalog_graph_parent_and_name
    : graph_parent_specification graph_name {
    
    }
    | url_path_parameter {
    
    }
    ;

// TODO
graph_parent_specification
    : opt_parent_catalog_object_reference opt_qualified_object_name_period {
    
    }
    ;

opt_qualified_object_name_period
    : %empty {

    }
    | qualified_object_name PERIOD {

    }
    ;


opt_parent_catalog_object_reference
    : %empty {

    }
    | parent_catalog_object_reference {

    }
    ;

local_graph_reference
    : qualified_graph_name {

    }
    ;

qualified_graph_name
    : graph_name {

    }
    ;



// Section_17.3_Graph_type_references
graph_type_reference
    : graph_type_resolution_expression {

    }
    | local_graph_type_reference {

    }
    ;

graph_type_resolution_expression
    : PROPERTY_GRAPH TYPE catalog_graph_type_reference {

    }
    ;

catalog_graph_type_reference
    : catalog_graph_type_parent_and_name {

    }
    | external_object_reference {

    }
    ;

catalog_graph_type_parent_and_name
    : graph_type_parent_specification graph_type_name {

    }
    | url_path_parameter {

    }
    ;

// TODO
graph_type_parent_specification
    : opt_parent_catalog_object_reference opt_qualified_object_name_period {

    }
    ;

local_graph_type_reference
    : qualified_graph_type_name {

    }
    ;

qualified_graph_type_name
    : opt_qualified_object_name_period graph_type_name {

    }
    ;


// Section_17.4_Binding_table_references
binding_table_reference
    : binding_table_resolution_expression {

    }
    | local_binding_table_reference {

    }
    ;

binding_table_resolution_expression
    : BINDING_TABLE catalog_binding_table_reference {

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
    : binding_table_parent_specification binding_table_name {

    }
    | url_path_parameter {

    }
    ;

binding_table_parent_specification
    : opt_parent_catalog_object_reference opt_qualified_object_name_period {

    }
    ;

local_binding_table_reference
    : qualified_binding_table_name {

    }
    ;

qualified_binding_table_name
    : opt_qualified_object_name_period binding_table_name {

    }
    ;


// Section_17.5_Procedure_references
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
    : procedure_parent_specification procedure_name {

    }
    | url_path_parameter {

    }
    ;

procedure_parent_specification
    : opt_parent_catalog_object_reference opt_qualified_object_name_period {

    }
    ;

local_procedure_reference
    : qualified_procedure_name {

    }
    ;

qualified_procedure_name
    : opt_qualified_object_name_period procedure_name {

    }
    ;



// Section_17.6_Query_references
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
    : query_parent_specification query_name {

    }
    | url_path_parameter {

    }
    ;

query_parent_specification
    : opt_parent_catalog_object_reference opt_qualified_object_name_period {

    }
    ;

local_query_reference
    : qualified_query_name
    ;

qualified_query_name
    : opt_qualified_object_name_period query_name {

    }
    ;


// Section_17.7_Function_references
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
    : catalog_function_parent_and name
    | external_object_reference
    ;

catalog_function_parent_and_name
    : function_parent_specification function_name {

    }
    | url_path_parameter {

    }
    ;

function_parent_specification
    : opt_parent_catalog_object_reference opt_qualified_object_name_period {

    }
    ;

local_function_reference
    : qualified_function_name {

    }
    ;

qualified_function_name
    : opt_qualified_object_name_period function_name {

    }
    ;



// Section_17.8_catalog_object_reference
catalog_object_reference
    : catalog_url_path {

    }
    ;

parent_catalog_object_reference
    : catalog_object_reference {

    }
    | catalog_object_reference SOLIDUS {

    }
    ;

catalog_url_path
    : absolute_url_path {

    }
    | relative_url_path {

    }
    | parameterized_url_path {

    }
    ;

absolute_url_path
    : SOLIDUS {

    }
    | SOLIDUS simple_url_path {

    }
    ;

relative_url_path
    : parent_object_relative_url_path {

    }
    | simple_relative_url_path {

    }
    | PERIOD {

    }
    ;

parent_object_relative_url_path
    : predefined_parent_object_parameter {
    
    }
    | predefined_parent_object_parameter SOLIDUS simple_url_path {

    }
    ;

simple_relative_url_path
    : DOUBLE_PERIOD opt_solidus_double_period_list opt_solidus_simple_url_path {
    
    }                 [ { SOLIDUS__DOUBLE_PERIOD }... ] [ SOLIDUS__simple_url_path ]
    | simple_url_path
    ;

opt_solidus_double_period_list
    : %empty {

    }
    | solidus_double_period_list {

    }
    ;

solidus_double_period_list
    : solidus_double_period {

    }
    | solidus_double_period_list solidus_double_period {

    }
    ;

solidus_double_period
    : SOLIDUS DOUBLE_PERIOD {

    }
    ;

opt_solidus_simple_url_path
    : %empty {

    }
    | solidus_simple_url_path {

    }
    ;

solidus_simple_url_path
    : SOLIDUS simple_url_path {

    }
    ;

parameterized_url_path
    : url_path_parameter opt_solidus_simple_url_path {

    }
    ;

simple_url_path
    : url_segment opt_solidus_url_segment_list {

    }
    ;

opt_solidus_url_segment_list
    : %empty {

    }
    | solidus_url_segment_list {

    }
    ;

solidus_url_segment_list
    : solidus_url_segment {

    }
    | solidus_url_segment_list solidus_url_segment {

    }
    ;

solidus_url_segment
    : SOLIDUS url_segment {

    }
    ;

url_segment
    : IDENTIFIER {

    }
    ;


// Section_17.9_qualified_object_name
qualified_object_name
    : qualified_name_prefix object_name {

    }
    ;

qualified_name_prefix
    : opt_object_name_period_list {

    }
    ;

opt_object_name_period_list
    : %empty {

    }
    | object_name_period_list {

    }
    ;

object_name_period_list
    : object_name_period {

    }
    | object_name_period_list object_name_period {

    }
    ;

object_name_period
    : object_name PERIOD {

    }
    ;

// Section_17.10_url_path_parameter
url_path_parameter
    : parameter {

    }
    ;


// Section_17.11_external_object_reference
external_object_reference
    : external_object_url {

    }
    ;

external_object_url
    : !! See_the_Syntax_Rules.
    ;


// Section_17.12_element_reference
element_reference
    : element_variable {

    }
    ;



// Section_19.1_search_condition
search_condition
    : boolean_value_expression {

    }
    ;


// Section_19.2_predicate
predicate
    : comparison_predicate {
      
    }
    | exists_predicate {
      
    }
    | null_predicate {
      
    }
    | normalized_predicate {
      
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


// Section_19.3_comparison_predicate
comparison_predicate
    : non_parenthesized_value_expression_primary comparison_predicate_part_2 {

    }
    ;

comparison_predicate_part_2
    : comp_op non_parenthesized_value_expression_primary {

    }
    ;

comp_op
    : EQUALS_OPERATOR {

    }
    | NOT_EQUALS_OPERATOR {
      
    }
    | LESS_THAN_OPERATOR {
      
    }
    | GREATER_THAN_OPERATOR {
      
    }
    | LESS_THAN_OR_EQUALS_OPERATOR {
      
    }
    | GREATER_THAN_OR_EQUALS_OPERATOR {

    }
    ;


// Section_19.4_exists_predicate
exists_predicate
    : EXISTS LEFT_PAREN_graph_pattern RIGHT_PAREN {

    }
    | EXISTS nested_query_specification {

    }
    ;



// Section_19.5_null_predicate
null_predicate
    : value_expression_primary null_predicate_part_2 {

    }
    ;

null_predicate_part_2
    : IS  NULL {

    }
    | IS NOT NULL {

    }
    ;


// Section_19.6_normalized_predicate
normalized_predicate
    : string_value_expression normalized_predicate_part_2 {

    }
    ;

normalized_predicate_part_2
    : IS opt_normal_form NORMALIZED {

    }
    | IS NOT opt_normal_form NORMALIZED {

    }
    ;

opt_normal_form
    : %empty {

    }
    | normal_form {

    }
    ;

// Section_19.7_directed_predicate
directed_predicate
    : element_reference directed_predicate_part_2 {

    }
    ;

directed_predicate_part_2
    : IS DIRECTED {

    }
    | IS NOT DIRECTED {

    }
    ;



// Section_19.8_labeled_predicate
labeled_predicate
    : element_reference labeled_predicate_part_2 {

    }
    ;

labeled_predicate_part_2
    : IS LABELED label_expression {

    }
    | IS NOT LABELED label_expression {

    }
    ;


// Section_19.9 <source/destination_predicate>
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
    : IS [ NOT ] SOURCE [ OF ] edge_reference {
      
    }
    ;

destination_predicate_part_2
    : IS [ NOT ] DESTINATION [ OF ] edge_reference {

    }
    ;

edge_reference
    : element_reference {

    }
    ;


// TODO, at least 2 elements
// Section_19.10_all_different_predicate
all_different_predicate
    : ALL_DIFFERENT LEFT_PAREN element_reference_list RIGHT_PAREN {

    }
    ;


// TODO, at least 2 elements
// Section_19.11_same_predicate
same_predicate
    : SAME LEFT_PAREN element_reference_list RIGHT_PAREN {

    }
    ;


element_reference_list
    : element_reference {

    }
    | element_reference_list COMMA element_reference {

    }
    ;

// Section_20.1_value_specification
value_specification
    : literal {

    }
    | parameter_value_specification {

    }
    ;

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


// Section_20.2_value_expression
value_expression
    : untyped_value_expression opt_of_value_type {

    }
    ;

untyped_value_expression
    : common_value_expression {

    }
    | boolean_value_expression {
      
    }
    ;

common_value_expression
    : numeric_value_expression {
      
    }
    | string_value_expression {
      
    }
    | datetime_value_expression {
      
    }
    | duration_value_expression {
      
    }
    | collection_value_expression {
      
    }
    | map_value_expression {
      
    }
    | record_value_expression {
      
    }
    | reference_value_expression {
      
    }
    ;

reference_value_expression
    : primary_result_object_expression {
      
    }
    | graph_element_value_expression {
      
    }
    ;

collection_value_expression
    : list_value_expression {
      
    }
    | multiset_value_expression {
      
    }
    | set_value_expression {
      
    }
    | ordered_set_value_expression {
      
    }
    ;

set_value_expression
    : value_expression_primary {
      
    }
    ;

map_value_expression
    : value_expression_primary {
      
    }
    ;

record_value_expression
    : value_expression_primary {
      
    }
    ;

// Section_20.3_boolean_value_expression
boolean_value_expression
    : boolean_term {
      
    }
    | boolean_value_expression OR boolean_term {
      
    }
    | boolean_value_expression XOR boolean_term {
      
    }
    ;

boolean_term
    : boolean_factor {
      
    }
    | boolean_term AND boolean_factor {
      
    }
    ;

boolean_factor
    : boolean_test {

    }
    | NOT boolean_test {

    }
    ;

boolean_test
    : boolean_primary {

    }
    | boolean_primary IS truth_value {

    }
    | boolean_primary IS NOT truth_value {

    }
    | boolean_primary EQUALS_OPERATOR truth_value {

    }
    | boolean_primary NOT_EQUALS_OPERATOR truth_value {

    }
    ;

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

boolean_primary
    : predicate {

    }
    | boolean_predicand {

    }
    ;

// TODO Boolean?
boolean_predicand
    : parenthesized_Boolean_value_expression {

    }
    | non_parenthesized_value_expression_primary {

    }
    ;

parenthesized_Boolean_value_expression
    : LEFT_PAREN boolean_value_expression RIGHT_PAREN {

    }
    ;


// Section_20.4_numeric_value_expression
numeric_value_expression
    : term {
      
    }
    | numeric_value_expression PLUS_SIGN term {
      
    }
    | numeric_value_expression MINUS_SIGN term {
      
    }
    ;

term
    : factor {
      
    }
    | term ASTERISK factor {
      
    }
    | term SOLIDUS factor {
      
    }
    ;

factor
    : opt_sign numeric_primary {

    }
    ;

opt_sign
    : %empty {

    }
    | sign {

    }
    ;

numeric_primary
    : value_expression_primary {

    }
    | numeric_value_function {

    }
    ;


// Section_20.5_value_expression_primary
value_expression_primary
    : parenthesized_value_expression {
      
    }
    | non_parenthesized_value_expression_primary {
      
    }
    ;

parenthesized_value_expression
    : LEFT_PAREN value_expression RIGHT_PAREN {

    }
    ;

non_parenthesized_value_expression_primary
    : property_reference {
      
    }
    | binding_variable {
      
    }
    | parameter_value_specification {
      
    }
    | unsigned_value_specification {
      
    }
    | aggregate_function {
      
    }
    | collection_value_constructor {
      
    }
    | value_query_expression {
      
    }
    | case_expression {
      
    }
    | cast_specification {
      
    }
    | element_id_function {
      
    }
    ;


// Section_20.6_numeric_value_function
numeric_value_function
    : length_expression {
      
    }
    | absolute_value_expression {
      
    }
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

char_length_expression
    : CHARACTER_LENGTH LEFT_PAREN character_string_value_expression RIGHT_PAREN {

    }
    ;

byte_length_expression
    : BYTE_LENGTH LEFT_PAREN string_value_expression RIGHT_PAREN {

    }
    | OCTET_LENGTH LEFT_PAREN string_value_expression RIGHT_PAREN {

    }
    ;

path_length_expression
    : LENGTH LEFT_PAREN binding_variable RIGHT_PAREN {

    }
    ;

absolute_value_expression
    : ABS LEFT_PAREN numeric_value_expression RIGHT_PAREN {

    }
    ;

modulus_expression
    : MOD LEFT_PAREN numeric_value_expression_dividend COMMA numeric_value_expression_divisor RIGHT_PAREN {

    }
    ;

numeric_value_expression_dividend
    : numeric_value_expression {

    }
    ;

numeric_value_expression_divisor
    : numeric_value_expression {

    }
    ;

trigonometric_function
    : trigonometric_function_name LEFT_PAREN numeric_value_expression RIGHT_PAREN {

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

general_logarithm_base
    : numeric_value_expression {

    }
    ;

general_logarithm_argument
    : numeric_value_expression {

    }
    ;

common_logarithm
    : LOG10 LEFT_PAREN numeric_value_expression RIGHT_PAREN {

    }
    ;

natural_logarithm
    : LN LEFT_PAREN numeric_value_expression RIGHT_PAREN {

    }
    ;

exponential_function
    : EXP LEFT_PAREN numeric_value_expression RIGHT_PAREN {

    }
    ;

power_function
    : POWER LEFT_PAREN numeric_value_expression_base COMMA numeric_value_expression_exponent RIGHT_PAREN {

    }
    ;

numeric_value_expression_base
    : numeric_value_expression {

    }
    ;

numeric_value_expression_exponent
    : numeric_value_expression {

    }
    ;

square_root
    : SQRT LEFT_PAREN numeric_value_expression RIGHT_PAREN {

    }
    ;

floor_function
    : FLOOR LEFT_PAREN numeric_value_expression RIGHT_PAREN {

    }
    ;

ceiling_function
    : CEIL LEFT_PAREN numeric_value_expression RIGHT_PAREN {

    }
    | CEILING LEFT_PAREN numeric_value_expression RIGHT_PAREN {
      
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



// Section_20.7_string_value_expression
string_value_expression
    : character_string_value_expression {

    }
    | byte_string_value_expression {

    }
    ;

character_string_value_expression
    : character_string_concatenation {
      
    }
    | character_string_factor {
      
    }
    ;

character_string_concatenation
    : character_string_value_expression CONCATENATION_OPERATOR character_string_factor {

    }
    ;

character_string_factor
    : character_string_primary {

    }
    ;

character_string_primary
    : value_expression_primary {

    }
    | string_value_function {

    }
    ;

byte_string_value_expression
    : byte_string_concatenation {
      
    }
    | byte_string_factor {
      
    }
    ;

byte_string_factor
    : byte_string_primary {
      
    }
    ;

byte_string_primary
    : value_expression_primary {
      
    }
    | string_value_function {
      
    }
    ;

byte_string_concatenation
    : byte_string_value_expression CONCATENATION_OPERATOR byte_string_factor {
      
    }
    ;


// Section_20.8_string_value_function
string_value_function
    : character_string_function {
      
    }
    | byte_string_function {
      
    }
    ;

character_string_function
    : substring_function {
      
    }
    | fold {
      
    }
    | trim_function {
      
    }
    | normalize_function {
      
    }
    ;

substring_function
    : SUBSTRING LEFT_PAREN character_string_value_expression COMMA start_position RIGHT_PAREN {
      
    }
    | SUBSTRING LEFT_PAREN character_string_value_expression COMMA start_position COMMA string_length RIGHT_PAREN {
      
    }
    | LEFT LEFT_PAREN character_string_value_expression COMMA string_length RIGHT_PAREN {
      
    }
    | RIGHT LEFT_PAREN character_string_value_expression COMMA string_length RIGHT_PAREN {
      
    }
    ;

fold
    : UPPER LEFT_PAREN character_string_value_expression RIGHT_PAREN {

    }
    | toUpper LEFT_PAREN character_string_value_expression RIGHT_PAREN {
      
    }
    | LOWER LEFT_PAREN character_string_value_expression RIGHT_PAREN {
      
    }
    | toLower LEFT_PAREN character_string_value_expression RIGHT_PAREN {
      
    }
    ;

trim_function
    : TRIM LEFT_PAREN trim_source RIGHT_PAREN {

    }
    | TRIM LEFT_PAREN trim_source COMMA trim_specification RIGHT_PAREN {

    }
    | TRIM LEFT_PAREN trim_source COMMA trim_specification trim_character_string RIGHT_PAREN {

    }
    | lTrim LEFT_PAREN trim_source RIGHT_PAREN {

    }
    | rTrim LEFT_PAREN trim_source RIGHT_PAREN {

    }
    ;

trim_source
    : character_string_value_expression {

    }
    ;

trim_specification
    : LEADING {
      
    }
    | TRAILING {
      
    }
    | BOTH {
      
    }
    ;

trim_character_string
    : character_string_value_expression {
      
    }
    ;

normalize_function
    : NORMALIZE LEFT_PAREN character_string_value_expression RIGHT_PAREN {
      
    }
    | NORMALIZE LEFT_PAREN character_string_value_expression COMMA normal_form RIGHT_PAREN {
      
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

byte_string_function
    : byte_substring_function {
      
    }
    | byte_string_trim_function {
      
    }
    ;

byte_substring_function
    : SUBSTRING LEFT_PAREN byte_string_value_expression COMMA start_position RIGHT_PAREN {

    }
    | SUBSTRING LEFT_PAREN byte_string_value_expression COMMA start_position COMMA string_length RIGHT_PAREN {
      
    }
    | LEFT LEFT_PAREN byte_string_value_expression COMMA string_length RIGHT_PAREN {

    }
    | RIGHT LEFT_PAREN byte_string_value_expression COMMA string_length RIGHT_PAREN {

    }
    ;

byte_string_trim_function
    : TRIM LEFT_PAREN byte_string_trim_source RIGHT_PAREN {

    }
    | TRIM LEFT_PAREN byte_string_trim_source COMMA trim_specification RIGHT_PAREN {
      
    }
    | TRIM LEFT_PAREN byte_string_trim_source COMMA trim_specification trim_byte_string RIGHT_PAREN {
      
    }
    | lTrim LEFT_PAREN byte_string_trim_source RIGHT_PAREN {

    }
    | rTrim LEFT_PAREN byte_string_trim_source RIGHT_PAREN {

    }
    ;

byte_string_trim_source
    : byte_string_value_expression {

    }
    ;

trim_byte_string
    : byte_string_value_expression {

    }
    ;

start_position
    : numeric_value_expression {

    }
    ;

string_length
    : numeric_value_expression {

    }
    ;


// Section_20.9_datetime_value_expression
datetime_value_expression
    : datetime_term {

    }
    | duration_value_expression PLUS_SIGN datetime_term {

    }
    | datetime_value_expression PLUS_SIGN duration_term {

    }
    | datetime_value_expression MINUS_SIGN duration_term {

    }
    ;
    
datetime_term
    : datetime_factor {

    }
    ;

datetime_factor
    : datetime_primary {

    }
    ;

datetime_primary
    : value_expression_primary {

    }
    | datetime_value_function {

    }
    ;



// Section_20.10_datetime_value_function
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
    | map_value_constructor {
      
    }
    ;

time_function_parameters
    : time_string {
      
    }
    | map_value_constructor {
      
    }
    ;

datetime_function_parameters
    : datetime_string {
      
    }
    | map_value_constructor {
      
    }
    ;



// Section_20.11_duration_value_expression
duration_value_expression
    : duration_term {

    }
    | duration_value_expression_1 PLUS_SIGN duration_term_1 {

    }
    | duration_value_expression_1 MINUS_SIGN duration_term_1 {

    }
    | LEFT_PAREN datetime_value_expression MINUS_SIGN datetime_term RIGHT_PAREN {

    }
    ;

duration_term
    : duration_factor {

    }
    | duration_term_2 ASTERISK factor {

    }
    | duration_term_2 SOLIDUS factor {

    }
    | term ASTERISK duration_factor {

    }
    ;

duration_factor
    : opt_sign duration_primary {

    }
    ;

duration_primary
    : value_expression_primary {

    }
    | duration_value_function {

    }
    ;

duration_value_expression_1
    : duration_value_expression {

    }
    ;

duration_term_1
    : duration_term {

    }
    ;

duration_term_2
    : duration_term {

    }
    ;


// Section_20.12_duration_value_function
duration_value_function
    : duration_function {

    }
    | duration_absolute_value_function {

    }
    ;

duration_function
    : DURATION LEFT_PAREN duration_function_parameters RIGHT_PAREN {

    }
    ;

duration_function_parameters
    : duration_string {

    }
    | map_value_constructor {

    }
    ;

duration_absolute_value_function
    : ABS LEFT_PAREN duration_value_expression RIGHT_PAREN {

    }
    ;



// Section_20.13_graph_element_value expression
graph_element_value_expression
    : graph_element_primary {

    }
    ;

graph_element_primary
    : graph_element_function {

    }
    | value_expression_primary {

    }
    ;

// Section_20.14_graph_element_function
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

// Section_20.15_collection_value_constructor
collection_value_constructor
    : list_value_constructor {
      
    }
    | multiset_value_constructor {
      
    }
    | set_value_constructor {
      
    }
    | ordered_set_value_constructor {
      
    }
    | map_value_constructor {
      
    }
    | record_value_constructor {
      
    }
    ;


// Section_20.16_list_value_expression
list_value_expression
    : list_concatenation {
      
    }
    | list_primary {
      
    }
    ;

list_concatenation
    : list_value_expression_1 CONCATENATION_OPERATOR list_primary {
      
    }
    ;

list_value_expression_1
    : list_value_expression {
      
    }
    ;

list_primary
    : list_value_function {
      
    }
    | value_expression_primary {
      
    }
    ;


// Section_20.17_list_value_function
list_value_function
    : tail_list_function {
      
    }
    | trim_list_function {
      
    }
    ;

tail_list_function
    : tail LEFT_PAREN list_value_expression RIGHT_PAREN {
      
    }
    ;

trim_list_function
    : TRIM LEFT_PAREN list_value_expression COMMA numeric_value_expression RIGHT_PAREN {
      
    }
    ;



// Section_20.18_list_value_constructor
list_value_constructor
    : list_value_constructor_by_enumeration {
      
    }
    ;

list_value_constructor_by_enumeration
    : list_value_type_name LEFT_BRACKET list_element_list RIGHT_BRACKET {
      
    }
    ;

list_element_list
    : list_element {
    
    } list_element_list COMMA list_element {

    }
    ;

list_element
    : value_expression {

    }
    ;



// Section_20.19_multiset_value_expression
multiset_value_expression
    : multiset_term {

    }
    | multiset_value_expression MULTISET UNION opt_all_or_distinct multiset_term {

    }
    | multiset_value_expression MULTISET EXCEPT opt_all_or_distinct multiset_term {

    }
    ;

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

multiset_term
    : multiset_primary {

    }
    | multiset_term MULTISET_INTERSECT opt_all_or_distinct multiset_primary {

    }
    ;

multiset_primary
    : multiset_value_function {

    }
    | value_expression_primary {

    }
    ;



// Section_20.20_multiset_value_function
multiset_value_function
    : multiset_set_function {
      
    }
    ;

multiset_set_function
    : SET LEFT_PAREN multiset_value_expression RIGHT_PAREN {

    }
    ;


// Section_20.21_multiset_value_constructor
multiset_value_constructor
    : multiset_value_constructor_by_enumeration {

    }
    ;

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
    : value_expression {

    }
    ;



// Section_20.22_set_value_constructor
set_value_constructor
    : set_value_constructor_by_enumeration {

    }
    ;

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
    : value_expression {

    }
    ;


// Section_20.23_ordered_set_value constructor
ordered_set_value_constructor
    : ordered_set_value_constructor_by_enumeration {

    }
    ;

ordered_set_value_constructor_by_enumeration
    : ORDERED SET LEFT_BRACE ordered_set_element_list RIGHT_BRACE {

    }
    | ORDERED SET LEFT_BRACKET ordered_set_element_list RIGHT_BRACKET {

    }
    }
    ;

ordered_set_element_list
    : ordered_set_element {
    
    }
    | ordered_set_element_list COMMA ordered_set_element {

    }
    ;

ordered_set_element
    : value_expression {

    }
    ;



// Section_20.24_map_value_constructor
map_value_constructor
    : map_value_constructor_by_enumeration {

    }
    ;

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
    : value_expression COLON {

    }
    ;

map_value
    : value_expression {

    }
    ;



// Section_20.25_record_value_constructor
record_value_constructor
    : record_value_constructor_by_enumeration {

    }
    | UNIT {

    }
    ;

record_value_constructor_by enumeration
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
    : value_expression {

    }
    ;



// Section_20.26_property_reference
property_reference
    : graph_element_primary PERIOD property_name {

    }
    ;



// Section_20.27_value_query_expression
value_query_expression
    : VALUE nested_query_specification {

    }
    ;


// Section_20.28_case_expression
case_expression
    : case_abbreviation {

    }
    | case_specification {

    }
    ;

// TODO
case_abbreviation
    : NULLIF LEFT_PAREN value_expression COMMA value_expression RIGHT_PAREN {

    }
    | COALESCE LEFT_PAREN value_expression_list RIGHT_PAREN {

    }
    ;
  
value_expression_list
    : value_expression {

    }
    | value_expression_list COMMA value_expression {

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
    | element_reference {

    }
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

result
    : result_expression {
      
    }
    | NULL {
      
    }
    ;

result_expression
    : value_expression {
      
    }
    ;



// Section_20.29_cast_specification
cast_specification
    : CAST LEFT_PAREN cast_operand AS cast_target RIGHT_PAREN {
      
    }
    ;

cast_operand
    : value_expression {
      
    }
    | null_literal {
      
    }
    ;

cast_target
    : predefined_type {
      
    }
    ;



// Section_20.30_element_id_function
element_id_function
    : ELEMENT_ID LEFT_PAREN element_reference RIGHT_PAREN {
      
    }
    ;



// Section_21.1_literal
literal
    : signed_numeric_literal {
      
    }
    | general_literal {
      
    }
    ;

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

// The_following_rule_is modified_to
/* predefined_type_literal
    : boolean_literal
    | character_string_literal
    | byte_string_literal
    | temporal_literal
    | duration_literal
    | null_literal
    ; */

predefined_type_literal
    : boolean_literal {
      
    }
    | unbroken_character_string_literal {
      
    }
    | character_string_literal {
      
    }
    | byte_string_literal {
      
    }
    | temporal_literal {
      
    }
    | duration_literal {
      
    }
    | null_literal {
      
    }
    ;

unsigned_literal
    : unsigned_numeric_literal {
      
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
    }
    ;

/* character_string_literal
    : single_quoted_character_sequence
    | double_quoted_character_sequence
    ; */

/* unbroken_character_string_literal
    : unbroken_single_quoted_character sequence
    | unbroken_double_quoted_character sequence
    ; */

/* single_quoted_character_sequence
    : unbroken_single_quoted_character sequence [ { separator__unbroken_single_quoted character_sequence }... ]
    ;

double_quoted_character_sequence
    : unbroken_double_quoted_character sequence [ { separator__unbroken_double_quoted character_sequence }... ]
    ; */

/* unbroken_single_quoted_character sequence
    : quote [ single_quoted_character_representation_... ] quote
    ;

unbroken_double_quoted_character sequence
    : double_quote [ double_quoted_character_representation_... ] double_quote
    ; */

/* unbroken_accent_quoted_character_sequence
    : grave_accent [ accent_quoted_character_representation_... ] grave_accent
    ; */
/* 
single_quoted_character_representation
    : character_representation
    ; */

/* !! See_the_Syntax_Rules.
double_quoted_character_representation
    : character_representation
!! See_the_Syntax_Rules.

accent_quoted_character_representation
    : character_representation
    ; */

!! See_the_Syntax_Rules.
character_representation
    : string_literal_character
    | escaped_character
    ;

string_literal_character
    :
    !! See_the_Syntax_Rules.

escaped_character
    : escaped_reverse_SOLIDUS
    | escaped_quote
    | escaped_double_quote
    | escaped_tab
    | escaped_backspace
    | escaped_newline
    | escaped_carriage_return
    | escaped_form_feed
    | unicode_escape_value

escaped_reverse_SOLIDUS
    : reverse_SOLIDUS__reverse_SOLIDUS
    ;

escaped_quote
    : reverse_SOLIDUS__quote
    ;

escaped_double_quote
    : reverse_SOLIDUS__double_quote
    ;

escaped_tab
    : reverse_SOLIDUS__t
    ;

escaped_backspace
    : reverse_SOLIDUS__b

escaped_newline
    : reverse_SOLIDUS__n

escaped_carriage_return
    : reverse_SOLIDUS__r

escaped_form_feed
    : reverse_SOLIDUS__f
    ;

unicode_escape_value
    : unicode_4_digit_escape value
    | unicode_6_digit_escape value
    ;

unicode_4_digit_escape value
    : reverse_SOLIDUS__u_hex digit__hex_digit__hex digit__hex_digit
    ;

unicode_6_digit_escape value
    : reverse_SOLIDUS__U_hex digit__hex_digit__hex digit__hex_digit__hex digit__hex_digit
    ;

/* byte_string_literal
    : X_quote [ space_... ] [ { hex_digit [ space_... ] hex_digit [ space_... ] }... ] quote [ { separator__quote [ space_... ] [ { hex_digit [ space_... ] hex_digit [ space_... ] }... ] quote }... ]
    ; */

numeric_literal
    : signed_numeric_literal
    | unsigned_numeric_literal
    ;

signed_numeric_literal
    : opt_sign unsigned_numeric_literal {

    }
    ;

/* unsigned_numeric_literal
    : exact_numeric_literal {

    }
    | approximate_numeric_literal {

    }
    ;

exact_numeric_literal
    : unsigned_integer {
      
    }
    | unsigned_decimal_integer [ PERIOD [ unsigned_decimal_integer ] ]
    | PERIOD__unsigned_decimal_integer
    ; */

sign
    : PLUS_SIGN {

    }
    | MINUS_SIGN {

    }
    ;

unsigned_integer
    : unsigned_decimal_integer {

    }
    | unsigned_hexadecimal_integer {

    }
    | unsigned_octal_integer {

    }
    | unsigned_binary_integer {

    }
    ;

unsigned_decimal_integer
    : digit [ { [ underscore ] digit }... ]
    ;

unsigned_hexadecimal_integer
    : 0x { [ underscore ] hex_digit }...
    ;

unsigned_octal_integer
    : 0o { [ underscore ] octal_digit }...
    ;

unsigned_binary_integer
    : 0b { [ underscore ] binary_digit }...
    ;

signed_decimal_integer
    : opt_sign unsigned_decimal_integer {

    }
    ;

approximate_numeric_literal
    :
    mantissa__E_exponent
    ;

mantissa
    : exact_numeric_literal
    ;

exponent
    : signed_decimal_integer
    ;

temporal_literal
    : date_literal
    | time_literal
    | datetime_literal
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
    : unbroken_character_string_literal {

    }
    ;

time_string
    : unbroken_character_string_literal {

    }
    ;

datetime_string
    : unbroken_character_string_literal {

    }
    ;

duration_literal
    : DURATION duration_string {

    }
    | SQL_interval_literal {

    }
    ;

duration_string
    : unbroken_character_string_literal {

    }
    ;

// <SQL-interval literal> shall conform to the Syntax Rules of <interval literal> in ISO/IEC 9075-2:202x.
SQL_interval_literal
    : interval_literal {

    }
    ;

interval_literal
    : INTERVAL opt_sign interval_string interval_qualifier {

    }
    ;

interval_string
    : QUOTE unquoted_interval_string QUOTE {

    }
    ;

unquoted_interval_string
    : opt_sign year_month_literal {
    
    }
    | opt_sign day_time_literal {

    }
    ;

year_month_literal
    : years_value {
    
    }
    | years_value MINUS_SIGN months_value {

    }
    | months_value {

    }
    ;
  
day_time_literal
    : day_time_interval {

    }
    | time_interval {

    }
    ;

// TODO space? shift/reduce error
day_time_interval
    : days_value {
    
    }
    | days_value space hours_value {

    }
    | days_value space hours_value COLON minutes_value {

    }
    | days_value space hours_value COLON minutes_value COLON seconds_value {

    }
    ;

time_interval
    : hours_value {
      
    }
    | hours_value COLON minutes_value {

    }
    | hours_value COLON minutes_value COLON seconds_value {

    }
    | minutes_value {

    }
    | minutes_value COLON seconds_value {

    }
    | seconds_value {

    }
    ;

years_value
    : datetime_value {

    }
    ;

months_value
    : datetime_value {

    }
    ;

days_value
    : datetime_value {

    }
    ;

hours_value
    : datetime_value {

    }
    ;

minutes_value
    : datetime_value {

    }
    ;

seconds_value
    : seconds_integer_value {
      
    }
    | seconds_integer_value PERIOD {

    }
    | seconds_integer_value PERIOD seconds_fraction {

    }
    ;

seconds_integer_value
    : unsigned_integer {

    }
    ;

seconds_fraction
    : unsigned_integer {

    }
    ;

datetime_value
    : unsigned_integer {

    }
    ;


interval_qualifier
    : start_field TO end_field {

    }
    | single_datetime_field {

    }
    ;

start_field
    : non_second_primary_datetime_field {

    }
    | non_second_primary_datetime_field LEFT_PAREN interval_leading_field_precision RIGHT_PAREN {

    }
    ;

end_field
    : non_second_primary_datetime_field {

    }
    | SECOND {
    
    }
    | SECOND LEFT_PAREN interval_fractional_seconds_precision RIGHT_PAREN {

    }
    ;

single_datetime_field
    : non_second_primary_datetime_field {

    }
    | non_second_primary_datetime_field LEFT_PAREN interval_leading_field_precision RIGHT_PAREN {

    }
    | SECOND {
    
    }
    | SECOND LEFT_PAREN interval_leading_field_precision RIGHT_PAREN {

    }
    | SECOND LEFT_PAREN interval_leading_field_precision COMMA interval_fractional_seconds_precision RIGHT_PAREN {

    }
    ;

non_second_primary_datetime_field
    : YEAR {

    }
    | MONTH {
      
    }
    | DAY {
      
    }
    | HOUR {
      
    }
    | MINUTE {
      
    }
    ;

interval_leading_field_precision
    : unsigned_integer {

    }
    ;

interval_fractional_seconds_precision
    : unsigned_integer {

    }
    ;


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
    ;


// Section_21.2_value_type
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
    : opt_of_type_prefix value_type {
      
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
    : character_string_synonym {
    
    }
    | character_string_synonym LEFT_PAREN max_length RIGHT_PAREN {

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
    : unsigned_decimal_integer {

    }
    ;

max_length
    : unsigned_decimal_integer {
      
    }
    ;

fixed_length
    : unsigned_decimal_integer {
      
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

decimal_synonym
    : DECIMAL {

    }
    | DEC {

    }
    ;

precision
    : unsigned_decimal_integer {

    }
    ;

scale
    : unsigned_decimal_integer {

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
    | FLOAT LEFT_PAREN precision COMMA scala RIGHT_PAREN {

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
    : NODE {

    }
    | VERTEX {

    }
    | EDGE {

    }
    | RELATIONSHIP {

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



// Section_21.3_Names_and_identifiers
object_name
    : IDENTIFIER {

    }
    ;

schema_name
    : IDENTIFIER {

    }
    ;

graph_name
    : IDENTIFIER {

    }
    ;

element_type_name
    : type_name {
      
    }
    ;

graph_type_name
    : IDENTIFIER {
      
    }
    ;

type_name
    : IDENTIFIER {
      
    }
    ;

binding_table_name
    : IDENTIFIER {
      
    }
    ;

value_name
    : IDENTIFIER {
      
    }
    ;

procedure_name
    : IDENTIFIER {
      
    }
    ;

query_name
    : IDENTIFIER {
      
    }
    ;

function_name
    : IDENTIFIER {
      
    }
    ;

label_name
    : IDENTIFIER {
      
    }
    ;

property_name
    : IDENTIFIER {
      
    }
    ;

field_name
    : IDENTIFIER {
      
    }
    ;

path_pattern_name
    : IDENTIFIER {
      
    }
    ;

/* PARAMETER_NAME
    : dollar_sign__separated_identifier
    ; */

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
    : regular_identifier {
      
    }
    ;

/* IDENTIFIER
    : regular_identifier
    | delimited_identifier
    ;

separated_identifier
    : extended_identifier
    | delimited_identifier
    ; */

edge_synonym
    : EDGE {
      
    }
    | RELATIONSHIP {
      
    }
    ;

node_synonym
    : NODE {
      
    }
    | VERTEX {
      
    }
    ;

BINDING_TABLE
    : TABLE {

    }
    | BINDING_TABLE {

    }
    ;

PROPERTY_GRAPH
    : GRAPH {

    }
    | PROPERTY_GRAPH {

    }
    ;

IF_EXISTS
    : IF EXISTS {

    }
    ;

IF_NOT_EXISTS
    : IF NOT EXISTS {

    }
    ;

character_string_synonym
    : STRING {

    }
    | VARCHAR {

    }
    ;

// moved_from_gql.ll
GREATER_THAN_OPERATOR
    : RIGHT_ANGLE_BRACKET
    ;

LESS_THAN_OPERATOR
    : LEFT_ANGLE_BRACKET
    ;


//unbroken_character_string_literal {unbroken_single_quoted_character_sequence|unbroken_double_quoted_character_sequence}

date_string {unbroken_character_string_literal}
time_string {unbroken_character_string_literal}
datetime_string {unbroken_character_string_literal}
duration_string {unbroken_character_string_literal}

single_quoted_character_sequence {unbroken_single_quoted_character_sequence}({separator}{unbroken_single_quoted_character_sequence})*
double_quoted_character_sequence {unbroken_double_quoted_character_sequence}({separator}{unbroken_double_quoted_character_sequence})*

// character_string_literal {single_quoted_character_sequence}|{double_quoted_character_sequence}

%%
