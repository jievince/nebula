// Section 6.1 <GQL-request>
<GQL-request>
    : [ <request parameter set> ] <GQL-program>
    ;


// Section 6.2 <request parameter set>
<request parameter set> 
    : <request parameter> [ { <comma> <request parameter> }... ]
    ;

<request parameter>
    : <parameter definition>
    ;


// Section 6.3 <GQL-program>
<GQL-program>
    : [ <preamble> ] <main activity>
    ;

<main activity>
    : <session activity>
    | [ <session activity> ] { <transaction activity> [ <session activity> ] }... [ <session close command> ]
    | <session close command>
    ;

<session activity>
    : <session clear command> [ <session parameter command>... ]
    | <session parameter command>...
    ;

<session parameter command>
    : <session set command>
    | <session remove command>
    ;

<transaction activity>
    : <start transaction command> [ <procedure specification> [ <end transaction command> ] ]
    | <procedure specification> [ <end transaction command> ]
    | <end transaction command>
    ;


// Section 6.4 <preamble>
<preamble>
    : <preamble option> [ { <comma> <preamble option> }... ]
    ;

<preamble option>
    : PROFILE
    | EXPLAIN
    | <preamble option identifier> [ <equals operator> <literal> ]
    ;

<preamble option identifier>
    : <identifier>
    ;


// Section 7.1 <session set command>
<session set command>
    : SESSION SET {
      <session set schema clause>
    | <session set graph clause>
    | <session set time zone clause>
    | <session set parameter clause>
    }
    ;

<session set schema clause>
    : SCHEMA <schema reference>
    ;

<session set graph clause>
    : <graph resolution expression>
    ;

<session set time zone clause>
    : TIME ZONE <set time zone value>
    ;

<set time zone value>
    : <string value expression>
    ;

<session set parameter clause>
    : [ <session parameter flag> ] <session parameter> [ IF NOT EXISTS ]
    ;

<session parameter>
    : [ PARAMETER ] <parameter definition>
    ;

<session parameter flag>
    : MUTABLE | FINAL
    ;


// Section 7.2 <session remove command>
<session remove command
    : [ SESSION ] REMOVE <parameter> [ IF EXISTS ]
    ;


// Section 7.3 <session clear command>
<session clear command>
    : [ SESSION ] CLEAR
    ;


// Section 7.4 <session close command>
<session close command>
    : [ SESSION ] CLOSE
    ;


// Section 8.1 <start transaction command>
<start transaction command>
    : START TRANSACTION [ <transaction characteristics> ]
    ;


// Section 8.2 <end transaction command>
<end transaction command>
    : <commit command>
    | <rollback command>
    ;


// Section 8.3 <transaction characteristics>
<transaction characteristics>
    : <transaction mode> [ { <comma> <transaction mode> }... ]
    ;

<transaction mode>
    : <transaction access mode>
    | <implementation-defined access mode>
    ;

<transaction access mode>
    : READ ONLY
    | READ WRITE
    ;

<implementation-defined access mode>
    : !! See the Syntax Rules.
    ;


// Section 8.4 <rollback command>
<rollback command>
    : ROLLBACK
    ;


// Section 8.5 <commit command>
<commit command>
    : COMMIT
    ;


// Section 9.1 <procedure specification>
<nested procedure specification>
    : <left brace> <procedure specification> <right brace>
    ;

<procedure specification>
    : <catalog-modifying procedure specification>
    | <data-modifying procedure specification>
    | <query specification>
    | <function specification>
    ;

** Editor’s Note (number 80) **
Rules for the derivation of the procedure signature of a <procedure specification>, a
<catalog-modifying procedure specification>, a <data-modifying procedure specification>,
a <query specification>, and a <function specification> from their <procedure body> need
to be specified. See Possible Problem GQL-021 .


<nested catalog-modifying procedure specification>
    : <left brace> <catalog-modifying procedure specification> <right brace>
    ;

<catalog-modifying procedure specification>
    : 
    !! Predicative production rule.
    <procedure body>
    ;

<nested data-modifying procedure specification>
    : <left brace> <data-modifying procedure specification> <right brace>
    ;

<data-modifying procedure specification>
    :
    !! Predicative production rule.
    <procedure body>
    ;


// Section 9.2 <query specification>
<nested query specification>
    : <left brace> <query specification> <right brace>
    ;

<query specification>
    :
    !! Predicative production rule.
    <procedure body>
    ;


// Section 9.3 <function specification>
<nested function specification>
    : <left brace> <function specification> <right brace>
    ;

<function specification>
    :
    !! Predicative production rule.
    <procedure body>
    ;


// Section 9.4 <procedure body>
<procedure body>
    : [ <static variable definition block> ] [ <binding variable definition block> ] <statement block>
    ;

<static variable definition block>
    : <static variable definition>...
    ;

<binding variable definition block>
    : <binding variable definition>...
    ;

  WG3:W17-027  
<statement block>
    : <statement> [ <then statement>... ]
    ;

<then statement>
    : THEN [ <yield clause> ] <statement>
    ;


// Section 10.1 Static variable definitions
<static variable definition>
    : <procedure variable definition>
    | <query variable definition>
    | <function variable definition>
    ;

<as or equals>
    : AS | <equals operator>
    ;


// Section 10.2 Procedure variable definition
<procedure variable definition>
    : [ CATALOG ] PROCEDURE <procedure variable> <of type signature> <procedure initializer>
    ;

<procedure variable>
    : <static variable name>
    ;

<procedure initializer>
    : <as or equals> <procedure reference>
    | [ AS ] <nested procedure specification>
    | <colon> <catalog procedure reference>
    ;


// Section 10.3 Query variable definition
<query variable definition>
    : QUERY <query variable> <of type signature> <query initializer>
    ;

<query variable>
    : <static variable name>
    ;

<query initializer>
    : <as or equals> <query reference>
    | [ AS ] <nested query specification>
    | <colon> <catalog query reference>
    ;


// Section 10.4 Function variable definition
<function variable definition>
    : FUNCTION <function variable> <of type signature> <function initializer>
    ;

<function variable>
    : <static variable name>
    ;

<function initializer>
    : <as or equals> <function reference>
    | [ AS ] <nested function specification>
    | <colon> <catalog function reference>
    ;


// Section 10.5 Binding variable and parameter declarations and definitions
<compact variable declaration list>
    : <compact variable declaration> [ { <comma> <compact variable declaration> }... ]
    ;

<compact variable declaration>
    : <binding variable declaration> | <value variable>
    ;

<binding variable declaration>
    : <graph variable declaration>
    | <binding table variable declaration>
    | <value variable declaration>
    ;

<compact variable definition list>
    : <compact variable definition> [ { <comma> <compact variable definition> }... ]
    ;

<compact variable definition>
    : <compact value variable definition>
    | <binding variable definition>
    ;

<compact value variable definition list>
    : <compact value variable definition> [ { <comma> <compact value variable definition> } ]
    ;

<compact value variable definition>
    : <value variable> <equals operator> <value expression>
    ;

<binding variable definition list>
    : <binding variable definition> [ { <comma> <binding variable definition> }... ]
    ;

<binding variable definition>
    : <graph variable definition>
    | <binding table variable definition>
    | <value variable definition>
    ;

<optional binding variable definition list>
    : <optional binding variable definition> [ { <comma> <optional binding variable definition>}... ]
    ;

<optional binding variable definition>
    : <optional graph variable definition>
    | <optional binding table variable definition>
    | <optional value variable definition>
    ;

<parameter definition>
    : <graph parameter definition>
    | <binding table parameter definition>
    | <value parameter definition>
    ;



// Section 10.6 Graph variable and parameter declaration and definition
<graph variable declaration>
    : [ PROPERTY ] GRAPH <graph variable> <of graph type>
    ;

<optional graph variable definition>
    : <graph variable definition>
    ;

<graph variable definition>
    : [ PROPERTY ] GRAPH <graph variable> <of graph type> <graph initializer>
    ;

<graph parameter definition>
    : [ PROPERTY ] GRAPH <parameter name> [ IF NOT EXISTS ] <of graph type> <graph initializer>
    ;

<graph variable>
    : <binding variable name>
    ;

<graph initializer>
    : <as or equals> <graph expression>
    | [ AS ] <nested graph query specification>
    | <colon> <catalog graph reference>
    ;



// Section 10.7 Binding table variable and parameter declaration and definition
<binding table variable declaration>
    : [ BINDING ] TABLE <binding table variable> <of binding table type>
    ;

<optional binding table variable definition>
    : <binding table variable definition>
    ;

<binding table variable definition>
    : [ BINDING ] TABLE <binding table variable> <of binding table type> <binding table initializer>
    ;

<binding table parameter definition>
    : [ BINDING ] TABLE <parameter> [ IF NOT EXISTS ] <of binding table type> <binding table initializer>
    ;

<binding table variable>
    : <binding variable name>
    ;

<binding table initializer>
    : <as or equals> <binding table reference>
    | [ AS ] <nested query specification>
    | <colon> <catalog binding table reference>
    ;


// Section 10.8 Value variable and parameter declaration and definition
<value variable declaration>
    : VALUE <value variable> [ <of value type> ]
    ;

<optional value variable definition>
    : <value variable definition>
    ;

<value variable definition>
    : VALUE <value variable> [ <of value type> ] <value initializer>
    ;

<value parameter definition>
    : VALUE <parameter> [ IF NOT EXISTS ] [ <of value type> ] <value initializer>
    ;

<value variable>
    : <binding variable name>
    ;

<value initializer>
    : <as or equals> <value expression>
    | [ AS ] <nested query specification>
    | <colon> <catalog object reference>
    ;


// Section 11.2 <primary result object expression>
<primary result object expression>
    : <graph expression>
    | <binding table reference>
    ;



// Section 11.3 <graph expression>
<graph expression>
    : <copy graph expression>
    | <graph specification>
    | <graph reference>
    ;

<copy graph expression>
    : COPY OF <graph expression>
    ;



// Section 11.4 <graph type expression>
<graph type expression>
    : <copy graph type expression>
    | <like graph expression>
    | <graph type specification>
    | <graph type reference>
    ;

<as graph type>
    : <as or equals> <graph type expression>
    | <like graph expression shorthand>
    | [ AS ] <nested graph type specification>
    ;

<copy graph type expression>
    : COPY OF <graph type reference>
    ;

<like graph expression>
    : [ PROPERTY ] GRAPH TYPE <like graph expression shorthand>
    ;

<of graph type>
    : [ <of type prefix> ] <graph type expression>
    | <like graph expression shorthand>
    | [ <of type prefix> ] <nested graph type specification>
    ;

<like graph expression shorthand>
    : LIKE <graph expression>
    ;



// Section 11.5 <binding table type expression>
<of binding table type>
    : [ <of type prefix> ] <binding table type expression>
    | <like binding table shorthand>
    ;

<binding table type expression>
    : <binding table type>
    | <like binding table type>
    ;

<binding table type>
    : [ BINDING ] TABLE <record value type>;

<like binding table type>
    : [ BINDING ] TABLE <like binding table shorthand>
    ;

<like binding table shorthand>
    : LIKE <binding table reference>
    ;


// Section 12.1 <statement>
<statement>
    : [ <at schema clause> ] {
      <catalog-modifying statement>
    | <data-modifying statement>
    | <query statement>
    }
    ;

<catalog-modifying statement>
    : <linear catalog-modifying statement>
    ;

<data-modifying statement>
    : <conditional data-modifying statement>
    | <linear data-modifying statement>
    ;

<query statement>
    : <composite query statement>
    | <conditional query statement>
    ;



// Section 12.2 <call procedure statement>
<call procedure statement>
    : [ <statement mode> ] CALL <procedure call>
    ;

<statement mode>
    : OPTIONAL
    | MANDATORY
    ;


// Section 12.3 Statement classes
<simple catalog-modifying statement>
    : <primitive catalog-modifying statement>
    | <call catalog-modifying procedure statement>
    ;

<primitive catalog-modifying statement>
    : <create graph statement>
    | <create graph type statement>
    | <create procedure statement>
    | <create query statement>
    | <create function statement>
    | <drop graph statement>
    | <drop graph type statement>
    | <drop procedure statement>
    | <drop query statement>
    | <drop function statement>
    ;

<simple data-accessing statement>
    : <simple query statement>
    | <simple data-modifying statement>
    ;

<simple data-modifying statement>
    : <primitive data-modifying statement>
    | <do statement>
    | <call data-modifying procedure statement>
    ;

<primitive data-modifying statement>
    : <insert statement>
    | <merge statement>
    | <set statement>
    | <remove statement>
    | <delete statement>
    ;

<simple query statement>
    : <simple data-transforming statement>
    | <simple data-reading statement>
    ;

<simple data-reading statement>
    : <match statement>
    | <call query statement>
    ;

<simple data-transforming statement>
    : <primitive data-transforming statement>
    | <call function statement>
    ;

<primitive data-transforming statement>
    : <optional statement>
    | <mandatory statement>
    | <let statement>
    | <for statement>
    | <aggregate statement>
    | <filter statement>
    | <order by and page statement>
    ;



// Section 13.1 <linear catalog-modifying statement>
<linear catalog-modifying statement>
    : <simple catalog-modifying statement>...
    ;



// Section 13.2 <create schema statement>
<create schema statement>
    : CREATE SCHEMA <catalog schema parent and name> [ IF NOT EXISTS ]
    ;


// Section 13.3 <drop schema statement>
<drop schema statement>
    : DROP SCHEMA <catalog schema parent and name> [ IF EXISTS ]
    ;


// Section 13.4 <create graph statement>
<create graph statement>
    : CREATE {
      [ PROPERTY ] GRAPH <catalog graph parent and name> [ IF NOT EXISTS ]
      | OR REPLACE [ PROPERTY ] GRAPH <catalog graph parent and name>
    } [ <of graph type> ] [ <graph source> ]
    ;

<graph source>
    : AS <copy graph expression>
    ;


// Section 13.5 <graph specification>
<graph specification>
    : [ PROPERTY ] GRAPH { <nested graph query specification>
                           | <nested ambient data-modifying procedure specification
                          }
    ;

<nested graph query specification>
    : <nested query specification>
    ;

<nested ambient data-modifying procedure specification>
    : <nested data-modifying procedure specification>
    ;


// Section 13.6 <drop graph statement>
<drop graph statement>
    : DROP GRAPH <catalog graph parent and name> [ IF EXISTS ]
    ;


// Section 13.7 <create graph type statement>
<create graph type statement>
    : CREATE {
      [ PROPERTY ] GRAPH TYPE <catalog graph type parent and name> [ IF NOT EXISTS ]
      | OR REPLACE [ PROPERTY ] GRAPH TYPE <catalog graph type parent and name>
    } <graph type initializer>
    ;

<graph type initializer>
    : <as graph type>
    | <colon> <catalog graph type reference>
    ;



// Section 13.8 <graph type specification>
<graph type specification>
    : [ PROPERTY ] GRAPH TYPE <nested graph type specification>
    ;

<nested graph type specification>
    : <left brace> <graph type specification body> <right brace>
    ;

<graph type specification body>
    : <element type definition list>
    ;

<element type definition list>
    : <element type definition> [ { <comma> <element type definition> }... ]
    ;

<element type definition>
    : <node type definition>
    | <edge type definition>
    ;


// Section 13.9 <node type definition>
<node type definition>
    : <left paren> [ <node type name> ] [ <node type filler> ] <right paren>
    | <node synonym> [ TYPE ] <node type name> <node type filler>
    ;

<node type name>
    : !! Predicative production rule.
    <element type name>
    ;
<node type filler>
    : <node type label set definition>
    | <node type property type set definition>
    | <node type label set definition> <node type property type set definition>

<node type label set definition>
    : !! Predicative production rule.
    <label set definition>
    ;

<node type property type set definition>
    : !! Predicative production rule.
    <property type set definition>
    ;



// Section 13.10 <edge type definition>
<edge type definition>
    : <full edge type pattern>
    | <abbreviated edge type pattern>
    | <edge kind> <edge synonym> [ TYPE ] <edge type name> <edge type filler> <endpoint definition>
    ;

<edge type name>
    : !! Predicative production rule.
    <element type name>
    ;

<edge type filler>
    : <edge type label set definition>
    | <edge type property type set definition>
    | <edge type label set definition> <edge type property type set definition>
    ;

<edge type label set definition>
    : !! Predicative production rule.
    <label set definition>
    ;

<edge type property type set definition>
    : !! Predicative production rule.
    <property type set definition>
    ;

<full edge type pattern>
    : <full edge type pattern pointing right>
    | <full edge type pattern pointing left>
    | <full edge type pattern any direction>
    ;

<full edge type pattern pointing right>
    : <source node type reference> <arc type pointing right> <destination node type reference>
    ;

<full edge type pattern pointing left>
    : <destination node type reference> <arc type pointing left> <source node type reference>
    ;

<full edge type pattern any direction>
    : <source node type reference> <arc type any direction> <destination node type reference>
    ;

<arc type pointing right>
    : <minus left bracket> <arc type filler> <bracket right arrow>
    ;

<arc type pointing left>
    : <left arrow bracket> <arc type filler> <right bracket minus>
    ;

<arc type any direction>
    : <tilde left bracket> <arc type filler> <right bracket tilde>
    ;

<arc type filler>
    : [ <edge type name> ] [ <edge type filler> ]
    ;

<abbreviated edge type pattern>
    : <abbreviated edge type pattern pointing right>
    | <abbreviated edge type pattern pointing left>
    | <abbreviated edge type pattern any direction>
    ;

<abbreviated edge type pattern pointing right>
    : <source node type reference> <right arrow> <destination node type reference>
    ;

<abbreviated edge type pattern pointing left>
    : <destination node type reference> <left arrow> <source node type reference>
    ;

<abbreviated edge type pattern any direction>
    : <source node type reference> <tilde> <destination node type reference>
    ;

<source node type reference>
    : <left paren> <source node type name> <right paren>
    | <left paren> [ <node type filler> ] <right paren>
    ;

<destination node type reference>
    : <left paren> <destination node type name> <right paren>
    | <left paren> [ <node type filler> ] <right paren>
    ;

<edge kind>
    : DIRECTED
    | UNDIRECTED
    ;

<endpoint definition>
    : CONNECTING <endpoint pair definition>
    ;

<endpoint pair definition>
    : <endpoint pair definition pointing right>
    | <endpoint pair definition pointing left>
    | <endpoint pair definition any direction>
    | <abbreviated edge type pattern>
    ;

<endpoint pair definition pointing right>
    : <left paren> <source node type name> <connector pointing right> <destination node type name> <right paren>
    ;

<endpoint pair definition pointing left>
    : <left paren> <destination node type name> <left arrow> <source node type name> <right paren>
    ;

<endpoint pair definition any direction>
    : <left paren> <source node type name> <connector any direction> <destination node type name> <right paren>
    ;

<connector pointing right>
    : TO
    | <right arrow>
    ;

<connector any direction>
    : TO
    | <tilde>
    ;

<source node type name>
    : !! Predicative production rule.
    <element type name>
    ;

<destination node type name>
    : !! Predicative production rule.
    <element type name>
    ;


// Section 13.11 <label set definition>
<label set definition>
    : LABEL <label>
    | LABELS <label expression>
    | <is label expression>
    ;


// Section 13.12 <property type set definition>
<property type set definition>
    : <left brace> [ <property type definition list> ] <right brace>
    ;

<property type definition list>
    : <property type definition> [ { <comma> <property type definition> }... ]
    ;

<property type definition>
    : <property name> <type name>
    ;


// Section 13.13 <drop graph type statement>
<drop graph type statement>
    : DROP [ PROPERTY ] GRAPH TYPE <catalog graph type parent and name> [ IF EXISTS ]
    ;


// Section 13.14 <create procedure statement>
<create procedure statement>
    : CREATE {
      PROCEDURE <catalog procedure parent and name> <of type signature> [ IF NOT EXISTS ]
      | OR REPLACE PROCEDURE <catalog procedure parent and name> <of type signature>
    } <procedure initializer>
    ;


// Section 13.15 <drop procedure statement>
<drop procedure statement>
    : DROP PROCEDURE <catalog procedure parent and name> [ IF EXISTS ]
    ;


// Section 13.16 <create query statement>
<create query statement>
    : CREATE {
      QUERY <catalog query parent and name> <of type signature> [ IF NOT EXISTS ]
      | OR REPLACE QUERY <catalog query parent and name> <of type signature>
    } <query initializer>
    ;


// Section 13.17 <drop query statement>
<drop query statement>
    : DROP QUERY <catalog query parent and name> [ IF EXISTS ]
    ;


// Section 13.18 <create function statement>
<create function statement>
    : CREATE {
      FUNCTION <catalog function parent and name> <of type signature> [ IF NOT EXISTS ]
      | OR REPLACE FUNCTION <catalog function parent and name> <of type signature>
    } <function initializer>
    ;


// Section 13.19 <drop function statement>
<drop function statement>
    : DROP FUNCTION <catalog function parent and name> [ IF EXISTS ]
    ;


// Section 13.20 <call catalog-modifying procedure statement>
<call catalog-modifying procedure statement>
    : <call procedure statement>
    ;


// Section 14.1 <linear data-modifying statement>
<linear data-modifying statement>
    : <focused linear data-modifying statement>
    | <ambient linear data-modifying statement>
    ;

<focused linear data-modifying statement>
    : <use graph clause> <focused linear data-modifying statement body>...
    ;

<focused linear data-modifying statement body>
    : [ <simple linear query statement> ]
    [ { <use graph clause> <simple linear query statement> }... ]
    <simple data-modifying statement>
    [ <simple data-accessing statement>... ]
    [ { <use graph clause> <simple data-accessing statement> }... ]
    [ <primitive result statement> ]
    | <nested data-modifying procedure specification>

<ambient linear data-modifying statement>
    : [ <simple linear query statement> ]
    <simple data-modifying statement>
    [ <simple data-accessing statement>... ]
    [ <primitive result statement> ]
    | <nested data-modifying procedure specification>
    ;


// Section 14.2 <conditional data-modifying statement>
<conditional data-modifying statement>
    : <when then linear data-modifying statement branch>...
    [ <else linear data-modifying statement branch> ]
    ;

<when then linear data-modifying statement branch>
    : <when clause> THEN <linear data-modifying statement>
    | <when clause> <nested data-modifying procedure specification>
    ;

<else linear data-modifying statement branch>
    : ELSE <linear data-modifying statement>
    ;

<when clause>
    : WHEN <search condition>
    ;


// Section 14.3 <do statement>
<do statement>
    : DO <nested data-modifying procedure specification>
    ;


// Section 14.4 <insert statement>
<insert statement>
    : INSERT <simple graph pattern>
    | OPTIONAL INSERT <simple graph pattern> [ <when clause> ]
    ;


// Section 14.5 <merge statement>
<merge statement>
    : MERGE <simple graph pattern>
    ;



// Section 14.6 <set statement>
<set statement>
    : SET <set item list> [ <when clause> ]
    ;

<set item list>
    : <set item> [ { <comma> <set item> }... ]
    ;

<set item>
    : <set property item> | <set all properties item> | <set label item>
    ;

<set property item>
    : <binding variable> <period> <property name> <equals operator> <value expression>
    ;

<set all properties item>
    : <binding variable> <equals operator> <value expression>
    ;

<set label item>
    : <label set expression>
    ;

<label set expression>
    : <ampersand> <label>... { <ampersand> <label>... }
    ;


// Section 14.7 <remove statement>
<remove statement>
    : REMOVE <remove item list> [ <when clause> ]
    ;

<remove item list>
    : <remove item> [ { <comma> <remove item> }... ]
    ;

<remove item>
    : <remove property item> | <remove label item>
    ;

<remove property item>
    : <binding variable> <period> <property name>
    ;

<remove label item>
    : <binding variable> <colon> <label set expression>
    ;


// Section 14.8 <delete statement>
<delete statement>
    : [ DETACH ] DELETE <delete item list> [ <when clause> ]
    ;

<delete item list>
    : <delete item> [ { <comma> <delete item> }... ]
    ;

<delete item>
    : <value expression>
    ;


// Section 14.9 <call data-modifying procedure statement>
<call data-modifying procedure statement>
    : <call procedure statement>
    ;


// Section 15.1 <composite query statement>
<composite query statement>
    : <composite query expression>
    ;


// Section 15.2 <conditional query statement>
<conditional query statement>
    : <when then linear query branch>... [ <else linear query branch> ]
    ;

<when then linear query branch>
    : <when clause> THEN <linear query expression>
    | <when clause> <nested query specification>
    ;

<else linear query branch>
    : ELSE <linear query expression>
    ;


// Section 15.3 <composite query expression>
<composite query expression>
    : <composite query expression> <query conjunction> <linear query expression>
    | <linear query expression>
    ;

<query conjunction>
    : <set operator>
    | OTHERWISE
    ;

<set operator>
    : UNION [ <set quantifier> ]
    | EXCEPT [ <set quantifier> ]
    | INTERSECT [ <set quantifier> ]
    ;


// Section 15.4 <linear query expression>
<linear query expression>
    : <linear query statement>
    ;



// Section 15.5 <linear query statement>
<linear query statement>
    : <focused linear query statement>
    | <ambient linear query statement>
    ;

<focused linear query statement>
    : <from graph clause> <focused linear query statement body>
    | <select statement>
    ;

<focused linear query statement body>
    : [ <simple linear query statement> [ { <from graph clause> <simple linear query statement> }... ] ] <primitive result statement>
    | <nested query specification>
    ;

<ambient linear query statement>
    : [ <simple linear query statement> ] <primitive result statement>
    | <nested query specification>
    ;

<simple linear query statement>
    : <simple query statement>...
    ;


/* Section 15.6 Data-reading statements */
// Section 15.6.1 <match statement>
<match statement>
    : [ <statement mode> ] MATCH <graph pattern>
    ;


// Section 15.6.2 <call query statement>
<call query statement>
    : <call procedure statement>
    ;


/* Section 15.7 Data-transforming statements */
// Section 15.7.1 <mandatory statement>
<mandatory statement>
    : MANDATORY <procedure call>
    ;



// Section 15.7.2 <optional statement>
<optional statement>
    : OPTIONAL <procedure call>
    ;

// Section 15.7.3 <filter statement>
<filter statement>
    : FILTER { <where clause> | <search condition> }
    ;


// Section 15.7.4 <let statement>
<let statement>
    : LET <compact variable definition list>
    | <statement mode> LET <compact variable definition list> <where clause>
    ;


// Section 15.7.5 <aggregate statement>
<aggregate statement>
    : AGGREGATE <compact value variable definition list> <where clause>
    ;


// Section 15.7.6 <for statement>
<for statement>
    : [ <statement mode> ] FOR <for item list> [ <for ordinality or index> ] [ <where clause> ]
    ;

<for item list>
    : <for item> [ { AND <for item> }... ]
    ;

<for item>
    : <for item alias> <collection value expression>
    ;

<for item alias>
    : <identifier> IN
    ;

<for ordinality or index>
    : WITH { ORDINALITY | INDEX } [ <identifier> ]
    ;


// Section 15.7.7 <order by and page statement>
<order by and page statement>
    : <order by clause> [ <offset clause> ] [ <limit clause> ]
    | <offset clause> [ <limit clause> ]
    | <limit clause>
    ;


// Section 15.7.8 <call function statement>
<call function statement>
    : <call procedure statement>
    ;


/* Section 15.8 Result projection statements */
// Section 15.8.1 <primitive result statement>
<primitive result statement>
    : <return statement> [ <order by and page statement> ]
    | <project statement>
    | END
    ;


// Section 15.8.2 <return statement>
<return statement>
    : RETURN <return statement body>
    ;

<return statement body>
    : [ <set quantifier> ] { <asterisk> | <return item list> } [ <group by clause> ]
    ;

<return item list>
    : <return item> [ { <comma> <return item> }... ]
    ;

<return item>
    : <value expression> [ <return item alias> ]
    ;

<return item alias>
    : AS <identifier>
    ;


// Section 15.8.3 <select statement>
<select statement>
    : SELECT [ <set quantifier> ] <select item list>
    <select statement body>
    [ <where clause> ]
    [ <group by clause> ]
    [ <having clause> ]
    [ <order by clause> ]
    [ <offset clause> ] [ <limit clause> ]
    ;

<select item list>
    : <select item> [ { <comma> <select item> }... ]
    ;

<select item>
    : <value expression> [ <select item alias> ]
    ;

<select item alias>
    : AS <identifier>
    ;

<having clause>
    : HAVING <search condition>
    ;

<select statement body>
    : FROM <select graph match list>
    | <select query specification>
    ;

<select graph match list>
    : <select graph match> [ { <comma> <select graph match> }... ]
    ;

<select graph match>
    : <graph expression> <match statement>
    ;

<select query specification>
    : FROM <nested query specification>
    | <from graph clause> <nested query specification>
    ;


// Section 16.1 <from graph clause>
<from graph clause>
    : FROM <graph expression>
    ;


// Section 16.2 <use graph clause>
<use graph clause>
    : USE <graph expression>
    ;


// Section 16.3 <at schema clause>
<at schema clause>
    : AT <schema reference>
    ;


// Section 16.4 Named elements
<static variable>
    : <static variable name>
    ;

<binding variable>
    : <binding variable name>
    ;

<label>
    : <label name>
    ;

<parameter>
    : <parameter name>
    ;


// Section 16.5 <type signature>
<of type signature>
    : [ <of type prefix> ] <type signature>
    ;

<type signature>
    : <parenthesized formal parameter list> [ <of type prefix> ] <procedure result type>
    ;

<parenthesized formal parameter list>
    : <left paren> [ <formal parameter list> ] <right paren>
    ;

<formal parameter list>
    : <mandatory formal parameter list> [ <comma> <optional formal parameter list> ]
    | <optional formal parameter list>
    ;

<mandatory formal parameter list>
    : <formal parameter declaration list>
    ;

<optional formal parameter list>
    : OPTIONAL <formal parameter definition list>
    ;

<formal parameter declaration list>
    : <formal parameter declaration> [ { <comma> <formal parameter declaration> }... ]
    ;

<formal parameter definition list>
    : <formal parameter definition> [ { <comma> <formal parameter definition> }... ]
    ;

<formal parameter declaration>
    : <parameter cardinality> <compact variable declaration>
    ;

<formal parameter definition>
    : <parameter cardinality> <compact variable definition>
    ;

<optional parameter cardinality>
    : [ <parameter cardinality> ]
    ;

<parameter cardinality>
    : SINGLE | MULTI | MULTIPLE
    ;

<procedure result type>
    : <value type>
    ;


// Section 16.6 <graph pattern>
<graph pattern>
    : <path pattern list>
    [ <keep clause> ]
    [ <graph pattern where clause> ]
    [ <yield clause> ]
    ;

<path pattern list>
    : <path pattern> [ { <comma> <path pattern> }... ]
    ;

<path pattern>
    : [ <path variable> <equals operator> ] [ <path pattern prefix> ] <path pattern expression>
    ;

<keep clause>
    : KEEP <path pattern prefix>
    ;

<graph pattern where clause>
    : WHERE <search condition>
    ;


// Section 16.7 <path pattern expression>
<path pattern expression>
    : <path term>
    | <path multiset alternation>
    | <path pattern union>
    ;

<path multiset alternation>
    : <path term> <multiset alternation operator> <path term> [ { <multiset alternation operator> <path term> }... ]
    ;

<path pattern union>
    : <path term> <vertical bar> <path term> [ { <vertical bar> <path term> }... ]
    ;

<path term>
    : <path factor>
    | <path concatenation>
    ;

<path concatenation>
    : <path term> <path factor>
    ;

<path factor>
    : <path primary>
    | <quantified path primary>
    | <questioned path primary>
    ;

<quantified path primary>
    : <path primary> <graph pattern quantifier>
    ;

<questioned path primary>
    : <path primary> <question mark>
    ;

NOTE 115 — Unlike most regular expression languages, <question mark> is not equivalent to the quantifier {0,1}: the
quantifier {0,1} exposes variables as group, whereas <question mark> does not change the singleton variables that it exposes
to group. However, <question mark> does expose any singleton variables as conditional singletons.

<path primary>
    : <element pattern>
    | <parenthesized path pattern expression>
    | <simplified path pattern expression>
    ;

<element pattern>
    : <node pattern>
    | <edge pattern>
    ;

<node pattern>
    : <left paren> <element pattern filler> <right paren>
    ;

<element pattern filler>
    : [ <element variable declaration> ]
    [ <is label expression> ]
    [ <element pattern predicate> ]
    [ <element pattern cost clause> ]
    ;

<element variable declaration>
    : <element variable>
    ;

<is label expression>
    : <is or colon> <label expression>
    ;

<is or colon>
    : IS
    | <colon>
    ;

<element pattern predicate>
    : <element pattern where clause>
    | <element property specification>
    ;

<element pattern where clause>
    : WHERE <search condition>
    ;

<element property specification>
    : <left brace> <property key value pair list> <right brace>
    ;

<property key value pair list>
    : <property key value pair> [ { <comma> <property key value pair> }... ]
    ;

<property key value pair>
    : <property name> <colon> <value expression>
    ;

<element pattern cost clause>
    : <cost clause>
    ;

<cost clause>
    : COST <value expression> [ DEFAULT <value expression> ]
    ;

** Editor’s Note (number 260) **
WG3:SXM-052 added the BNF for <cost clause> but did not provide any Syntax Rules or General
Rules for it. See Possible Problem GQL-024 .


<edge pattern>
    : <full edge pattern>
    | <abbreviated edge pattern>
    ;

<full edge pattern>
    : <full edge pointing left>
    | <full edge undirected>
    | <full edge pointing right>
    | <full edge left or undirected>
    | <full edge undirected or right>
    | <full edge left or right>
    | <full edge any direction>
    ;

<full edge pointing left>
    : <left arrow bracket> <element pattern filler> <right bracket minus>
    ;

<full edge undirected>
    : <tilde left bracket> <element pattern filler> <right bracket tilde>
    ;

<full edge pointing right>
    : <minus left bracket> <element pattern filler> <bracket right arrow>
    ;

<full edge left or undirected>
    : <left arrow tilde bracket> <element pattern filler> <right bracket tilde>
    ;

<full edge undirected or right>
    : <tilde left bracket> <element pattern filler> <bracket tilde right arrow>
    ;

<full edge left or right>
    : <left arrow bracket> <element pattern filler> <bracket right arrow>
    ;

<full edge any direction>
    : <minus left bracket> <element pattern filler> <right bracket minus>
    ;

** Editor’s Note (number 261) **
In the BNF for <full edge any direction>, the delimiter tokens <~[ ]~> have been suggested
as a synonym for -[ ]- as part of Feature G001, “Undirected edge patterns”. The synonym
for the <abbreviated edge pattern> - (<minus sign>) would then be <~>, the synonym for
<simplified defaulting any direction> would use the delimiter tokens <~/ /~> and the
synonym for <simplified override any direction> would use the tokens <~ and > surrounding
a label as originally proposed in WG3:MMX-060. These synonyms might be considered to make
the table of edge patterns more harmonious and internally consistent. See Language
Opportunity GQL-212 .

<abbreviated edge pattern>
    : <left arrow>
    | <tilde>
    | <right arrow>
    | <left arrow tilde>
    | <tilde right arrow>
    | <left minus right>
    | <minus sign>
    ;

<graph pattern quantifier>
    : <asterisk>
    | <plus sign>
    | <fixed quantifier>
    | <general quantifier>
    ;

<fixed quantifier>
    : <left brace> <unsigned integer> <right brace>
    ;

<general quantifier>
    : <left brace> [ <lower bound> ] <comma> [ <upper bound> ] <right brace>
    ;

<lower bound>
    : <unsigned integer>
    ;

<upper bound>
    : <unsigned integer>
    ;

<parenthesized path pattern expression>
    : <left paren>
    [ <subpath variable declaration> ]
    [ <path mode prefix> ]
    <path pattern expression>
    [ <parenthesized path pattern where clause> ]
    [ <parenthesized path pattern cost clause> ]
    <right paren>
    | <left bracket>
    [ <subpath variable declaration> ]
    [ <path mode prefix> ]
    <path pattern expression>
    [ <parenthesized path pattern where clause> ]
    [ <parenthesized path pattern cost clause> ]
    <right bracket>
    ;

** Editor’s Note (number 262) **
The ability to use square brackets as an alternative to round parentheses for grouping
in path patterns introduces an ambiguity in the grammar where a bare edge pattern followed
248
Informal_working_drafts 39075:202y(E)
16.7 <path pattern expression>
by a group (... - [ ...) looks a lot like the start of an edge pattern (... -[ ...), the
difference being only whitespace. See Possible Problem GQL-046


<subpath variable declaration>
    : <subpath variable> <equals operator>
    ;

<parenthesized path pattern where clause>
    : WHERE <search condition>
    ;

<parenthesized path pattern cost clause>
    : <cost clause>
    ;


// Section 16.8 <path pattern prefix>
<path pattern prefix>
    : <path mode prefix>
    | <path search prefix>
    ;

<path mode prefix>
    : <path mode> [ <path or paths> ]
    ;

<path mode>
    : WALK
    | TRAIL
    | SIMPLE
    | ACYCLIC
    ;

<path search prefix>
    : <all path search>
    | <any path search>
    | <shortest path search>
    ;

** Editor’s Note (number 272) **
The ability to specify “cheapest” queries (analogous to SHORTEST, but minimizing the sum
of costs along a path) is desirable. See Language Opportunity GQL-052 .


<all path search>
    : ALL [ <path mode> ] [ <path or paths> ]
    ;

<path or paths>
    : PATH | PATHS
    ;

<any path search>
    : ANY [ <number of paths> ] [ <path mode> ] [ <path or paths> ]
    ;

<number of paths>
    : <unsigned integer specification>
    ;

** Editor’s Note (number 273) **
This differs from the SQL/PGQ definition of <number of paths>.


<shortest path search>
    : <all shortest path search>
    | <any shortest path search>
    | <counted shortest path search>
    | <counted shortest group search>
    ;

<all shortest path search>
    : ALL SHORTEST [ <path mode> ] [ <path or paths> ]
    ;

<any shortest path search>
    : ANY SHORTEST [ <path mode> ] [ <path or paths> ]
    ;

<counted shortest path search>
    : SHORTEST <number of paths> [ <path mode> ] [ <path or paths> ]
    ;

<counted shortest group search>
    : SHORTEST <number of groups> [ <path mode> ] [ <path or paths> ] { GROUP | GROUPS }
    ;

<number of groups>
    : <unsigned integer specification>
    ;


// Section 16.9 <simple graph pattern>
<simple graph pattern>
    : <simple path pattern list>
    ;

<simple path pattern list>
    : <simple path pattern> [ { <comma> <simple path pattern> }... ]
    ;

<simple path pattern>
    : !! Predicative production rule.
    <path pattern expression>
    ;


// Section 16.10 <label expression>
<label expression>
    : <label term>
    | <label disjunction>
    ;

<label disjunction>
    : <label expression> <vertical bar> <label term>
    ;

<label term>
    : <label factor>
    | <label conjunction>
    ;

<label conjunction>
    : <label term> <ampersand> <label factor>
    ;

<label factor>
    : <label primary>
    | <label negation>
    ;

<label negation>
    : <exclamation mark> <label primary>
    ;

<label primary>
    : <label>
    | <wildcard label>
    | <parenthesized label expression>
    ;

<wildcard label>
    : <percent>
    ;

** Editor’s Note (number 280) **
Various options for <wildcard label> were discussed. See Possible Problem GQL-033 .

<parenthesized label expression>
    : <left paren> <label expression> <right paren>
    | <left bracket> <label expression> <right bracket>
    ;



// Section 16.11 <simplified path pattern expression>
<simplified path pattern expression>
    : <simplified defaulting left>
    | <simplified defaulting undirected>
    | <simplified defaulting right>
    | <simplified defaulting left or undirected>
    | <simplified defaulting undirected or right>
    | <simplified defaulting left or right>
    | <simplified defaulting any direction>
    ;

<simplified defaulting left>
    : <left minus slash> <simplified contents> <slash minus>
    ;

<simplified defaulting undirected>
    : <tilde slash> <simplified contents> <slash tilde>
    ;

<simplified defaulting right>
    : <minus slash> <simplified contents> <slash minus right>
    ;

<simplified defaulting left or undirected>
    : <left tilde slash> <simplified contents> <slash tilde>
    ;

<simplified defaulting undirected or right>
    : <tilde slash> <simplified contents> <slash tilde right>
    ;

<simplified defaulting left or right>
    : <left minus slash> <simplified contents> <slash minus right>
    ;

<simplified defaulting any direction>
    : <minus slash> <simplified contents> <slash minus>
    ;

<simplified contents>
    : <simplified term>
    | <simplified path union>
    | <simplified multiset alternation>
    ;

<simplified path union>
    : <simplified term> <vertical bar> <simplified term> [ { <vertical bar> <simplified term> }... ]
    ;

<simplified multiset alternation>
    : <simplified term> <multiset alternation operator> <simplified term> [ { <multiset alternation operator> <simplified term> }... ]
    ;

<simplified term>
    : <simplified factor low>
    | <simplified concatenation>
    ;

<simplified concatenation>
    : <simplified term> <simplified factor low>
    ;

<simplified factor low>
    : <simplified factor high>
    | <simplified conjunction>
    ;

<simplified conjunction>
    : <simplified factor low> <ampersand> <simplified factor high>
    ;

<simplified factor high>
    : <simplified tertiary>
    | <simplified quantified>
    | <simplified questioned>
    ;

<simplified quantified>
    : <simplified tertiary> <graph pattern quantifier>
    ;

<simplified questioned>
    : <simplified tertiary> <question mark>
    ;

<simplified tertiary>
    : <simplified direction override>
    | <simplified secondary>
    ;

<simplified direction override>
    : <simplified override left>
    | <simplified override undirected>
    | <simplified override right>
    | <simplified override left or undirected>
    | <simplified override undirected or right>
    | <simplified override left or right>
    | <simplified override any direction>
    ;

<simplified override left>
    : <left angle bracket> <simplified secondary>
    ;

<simplified override undirected>
    : <tilde> <simplified secondary>
    ;

<simplified override right>
    : <simplified secondary> <right angle bracket>
    ;

<simplified override left or undirected>
    : <left arrow tilde> <simplified secondary>
    ;

<simplified override undirected or right>
    : <tilde> <simplified secondary> <right angle bracket>
    ;

<simplified override left or right>
    : <left angle bracket> <simplified secondary> <right angle bracket>
    ;

<simplified override any direction>
    : <minus sign> <simplified secondary>
    ;

<simplified secondary>
    : <simplified primary>
    | <simplified negation>
    ;

<simplified negation>
    : <exclamation mark> <simplified primary>
    ;

<simplified primary>
    : <label>
    | <left paren> <simplified contents> <right paren>
    | <left bracket> <simplified contents> <right bracket>
    ;


// Section 16.12 <where clause>
<where clause>
    : WHERE <search condition>
    ;


// Section 16.13 <procedure call>
<procedure call>
    : <inline procedure call>
    | <named procedure call>
    ;


// Section 16.14 <inline procedure call>
<inline procedure call>
    : <nested procedure specification>
    ;


// Section 16.15 <named procedure call>
<named procedure call>
    : <procedure reference> <left paren> [ <procedure argument list> ] <right paren> [ <yield clause> ]
    ;

<procedure argument list>
    : <procedure argument> [ { <comma> <procedure argument> }... ]
    ;

<procedure argument>
    : <value expression>
    ;


// Section 16.16 <yield clause>
<yield clause>
    : YIELD <yield item list>
    ;

<yield item list>
    : <yield item> [ { <comma> <yield item> }... ]
    ;

<yield item>
    : { <yield item name> [ <yield item alias> ] }
    ;

<yield item name>
    : <identifier>
    ;

<yield item alias>
    : AS <variable name>
    ;


// Section 16.17 <group by clause>
<group by clause>
    : GROUP BY <grouping element list>
    ;

<grouping element list>
    : <grouping element> [ { <comma> <grouping element> } ]
    | <empty grouping set>
    ;

<grouping element>
    : <binding variable>
    ;

<empty grouping set>
    : <left paren> <right paren>
    ;


// Section 16.18 <order by clause>
<order by clause>
    : ORDER BY <sort specification list>
    ;


// Section 16.19 <aggregate function>
<aggregate function>
    : COUNT <left paren> <asterisk> <right paren>
    | <general set function>
    | <binary set function>
    ;

** Editor’s Note (number 307) **
Consider inclusion of aggregate function calls to procedures with formal parameters of
multiple parameter cardinality. See Language Opportunity GQL-186 .


<general set function>
    : <general set function type> <left paren> <set quantifier> <value expression> <right paren>
    ;

<binary set function>
    : <binary set function type> <left paren> <dependent value expression> <comma> <independent value expression> <right paren>
    ;

<general set function type>
    : AVG
    | COUNT
    | MAX
    | MIN
    | SUM
    | PRODUCT
    | COLLECT
    | stDev
    | stDevP
    ;

<set quantifier>
    : DISTINCT
    | ALL
    ;

<binary set function type>
    : percentileCont
    | percentileDist
    ;

<dependent value expression>
    : [ <set quantifier> ] <numeric value expression>
    ;

<independent value expression>
    : <numeric value expression>
    ;

// Section 16.20 <sort specification list>
<sort specification list>
    : <sort specification> [ { <comma> <sort specification> }... ]
    ;

<sort specification>
    : <sort key> [ <ordering specification> ] [ <null ordering> ]
    ;

<sort key>
    : <value expression>
    ;

<ordering specification>
    : ASC
    | DESC
    ;

<null ordering>
    : NULLS FIRST
    | NULLS LAST
    ;

// Section 16.21 <limit clause>
<limit clause>
    : LIMIT <unsigned integer specification>
    ;


// Section 16.22 <offset clause>
<offset clause>
    : <offset synonym> <unsigned integer specification>
    ;

<offset synonym>
    : OFFSET | SKIP
    ;


// Section 17.1 Schema references
<schema reference>
    : <predefined schema parameter>
    | <catalog schema parent and name>
    | <external object reference>
    ;

<catalog schema parent and name>
    : [ <absolute url path> ] <solidus> <schema name>
    | <url path parameter>
    ;


// Section 17.2 Graph references
<graph reference>
    : <graph resolution expression>
    | <local graph reference>
    ;

<graph resolution expression>
    : [ PROPERTY ] GRAPH <catalog graph reference>
    ;

<catalog graph reference>
    : <catalog graph parent and name>
    | <predefined graph parameter>
    | <external object reference>
    ;

<catalog graph parent and name>
    : <graph parent specification> <graph name>
    | <url path parameter>
    ;

<graph parent specification>
    : [ <parent catalog object reference> ] [ <qualified object name> <period> ]
    ;

<local graph reference>
    : <qualified graph name>
    ;

<qualified graph name>
    : [ <qualified object name> <period> ] <graph name>
    ;



// Section 17.3 Graph type references
<graph type reference>
    : <graph type resolution expression>
    | <local graph type reference>
    ;

<graph type resolution expression>
    : [ PROPERTY ] GRAPH TYPE <catalog graph type reference>
    ;

<catalog graph type reference>
    : <catalog graph type parent and name>
    | <external object reference>
    ;

<catalog graph type parent and name>
    : <graph type parent specification> <graph type name>
    | <url path parameter>
    ;

<graph type parent specification>
    : [ <parent catalog object reference> ] [ <qualified object name> <period> ]
    ;

<local graph type reference>
    : <qualified graph type name>
    ;

<qualified graph type name>
    : [ <qualified object name> <period> ] <graph type name>
    ;


// Section 17.4 Binding table references
<binding table reference>
    : <binding table resolution expression>
    | <local binding table reference>
    ;

<binding table resolution expression>
    : [ BINDING ] TABLE <catalog binding table reference>
    ;

<catalog binding table reference>
    : <catalog binding table parent and name>
    | <predefined table parameter>
    | <external object reference>
    ;

<catalog binding table parent and name>
    : <binding table parent specification> <binding table name>
    | <url path parameter>
    ;

<binding table parent specification>
    : [ <parent catalog object reference> ] [ <qualified object name> <period> ]
    ;

<local binding table reference>
    : <qualified binding table name>
    ;

<qualified binding table name>
    : [ <qualified object name> <period> ] <binding table name>
    ;


// Section 17.5 Procedure references
<procedure reference>
    : <procedure resolution expression>
    | <local procedure reference>
    ;

<procedure resolution expression>
    : PROCEDURE <catalog procedure reference>
    ;

<catalog procedure reference>
    : <catalog procedure parent and name>
    | <external object reference>
    ;

<catalog procedure parent and name>
    : <procedure parent specification> <procedure name>
    | <url path parameter>
    ;

<procedure parent specification>
    : [ <parent catalog object reference> ] [ <qualified object name> <period> ]
    ;

<local procedure reference>
    : <qualified procedure name>
    ;

<qualified procedure name>
    : [ <qualified object name> <period> ] <procedure name>
    ;



// Section 17.6 Query references
<query reference>
    : <query resolution expression>
    | <local query reference>
    ;

<query resolution expression>
    : QUERY <catalog query reference>
    ;

<catalog query reference>
    : <catalog query parent and name>
    | <external object reference>
    ;

<catalog query parent and name>
    : <query parent specification> <query name>
    | <url path parameter>
    ;

<query parent specification>
    : [ <parent catalog object reference> ] [ <qualified object name> <period> ]
    ;

<local query reference>
    : <qualified query name>
    ;

<qualified query name>
    : [ <qualified object name> <period> ] <query name>
    ;


// Section 17.7 Function references
<function reference>
    : <function resolution expression>
    | <local function reference>
    ;

<function resolution expression>
    : FUNCTION <catalog function reference>
    ;

<catalog function reference>
    : <catalog function parent and name>
    | <external object reference>
    ;

<catalog function parent and name>
    : <function parent specification> <function name>
    | <url path parameter>
    ;

<function parent specification>
    : [ <parent catalog object reference> ] [ <qualified object name> <period> ]
    ;

<local function reference>
    : <qualified function name>
    ;

<qualified function name>
    : [ <qualified object name> <period> ] <function name>
    ;



// Section 17.8 <catalog object reference>
<catalog object reference>
    : <catalog url path>
    ;

<parent catalog object reference>
    : <catalog object reference> [ <solidus> ]
    ;

<catalog url path>
    : <absolute url path>
    | <relative url path>
    | <parameterized url path>
    ;

<absolute url path>
    : <solidus> [ <simple url path> ]
    ;

<relative url path>
    : <parent object relative url path>
    | <simple relative url path>
    | <period>
    ;

<parent object relative url path>
    : <predefined parent object parameter> [ <solidus> <simple url path> ]
    ;

<simple relative url path>
    : <double period> [ { <solidus> <double period> }... ] [ <solidus> <simple url path> ]
    | <simple url path>
    ;

<parameterized url path>
    : <url path parameter> [ <solidus> <simple url path> ]
    ;

<simple url path>
    : <url segment> [ { <solidus> <url segment> }... ]
    ;

<url segment>
    : <identifier>
    ;


// Section 17.9 <qualified object name>
<qualified object name>
    : <qualified name prefix> <object name>
    ;

<qualified name prefix>
    : [ { <object name> <period> }... ]
    ;



// Section 17.10 <url path parameter>
<url path parameter>
    : <parameter>
    ;


// Section 17.11 <external object reference>
<external object reference>
    : <external object url>
    ;

<external object url>
    : !! See the Syntax Rules.
    ;


// Section 17.12 <element reference>
<element reference>
    : <element variable>
    ;



// Section 19.1 <search condition>
<search condition>
    : <boolean value expression>
    ;


// Section 19.2 <predicate>
<predicate>
    : <comparison predicate>
    | <exists predicate>
    | <null predicate>
    | <normalized predicate>
    | <directed predicate>
    | <labeled predicate>
    | <source/destination predicate>
    | <all_different predicate>
    | <same predicate>
    ;


// Section 19.3 <comparison predicate>
<comparison predicate>
    : <non-parenthesized value expression primary> <comparison predicate part 2>
    ;

<comparison predicate part 2>
    : <comp op> <non-parenthesized value expression primary>
    ;

<comp op>
    : <equals operator>
    | <not equals operator>
    | <less than operator>
    | <greater than operator>
    | <less than or equals operator>
    | <greater than or equals operator>
    ;


// Section 19.4 <exists predicate>
<exists predicate>
    : EXISTS {
      <left paren> <graph pattern> <right paren>
      | <nested query specification>
    }
    ;



// Section 19.5 <null predicate>
<null predicate>
    : <value expression primary> <null predicate part 2>
    ;

<null predicate part 2>
    : IS [ NOT ] NULL
    ;


// Section 19.6 <normalized predicate>
<normalized predicate>
    : <string value expression> <normalized predicate part 2>
    ;

<normalized predicate part 2>
    : IS [ NOT ] [ <normal form> ] NORMALIZED
    ;


// Section 19.7 <directed predicate>
<directed predicate>
    : <element reference> <directed predicate part 2>
    ;

<directed predicate part 2>
    : IS [ NOT ] DIRECTED
    ;



// Section 19.8 <labeled predicate>
<labeled predicate>
    : <element reference> <labeled predicate part 2>
    ;

<labeled predicate part 2>
    : IS [ NOT ] LABELED <label expression>
    ;


// Section 19.9 <source/destination predicate>
<source/destination predicate>
    : <node reference> <source predicate part 2>
    | <node reference> <destination predicate part 2>
    ;

<node reference>
    : <element reference>
    ;

<source predicate part 2>
    : IS [ NOT ] SOURCE [ OF ] <edge reference>
    ;

<destination predicate part 2>
    : IS [ NOT ] DESTINATION [ OF ] <edge reference>
    ;

<edge reference>
    : <element reference>
    ;



// Section 19.10 <all_different predicate>
<all_different predicate>
    : ALL_DIFFERENT <left paren> <element reference> <comma> <element reference> [ { <comma> <element reference> }... ] <right paren>
    ;


// Section 19.11 <same predicate>
<same predicate>
    : SAME <left paren> <element reference> <comma> <element reference> [ { <comma> <element reference> }... ] <right paren>
    ;


// Section 20.1 <value specification>
<value specification>
    : <literal>
    | <parameter value specification>
    ;

<unsigned value specification>
    : <unsigned literal>
    | <parameter value specification>
    ;

<unsigned integer specification>
    : <unsigned integer>
    | <parameter>
    ;

<parameter value specification>
    : <parameter>
    | <predefined parameter>
    ;

<predefined parameter>
    : <predefined parent object parameter>
    | <predefined table parameter>
    | CURRENT_USER
    ;

<predefined parent object parameter>
    : <predefined schema parameter>
    | <predefined graph parameter>
    ;

<predefined schema parameter>
    : HOME_SCHEMA
    | CURRENT_SCHEMA
    ;

<predefined graph parameter>
    : EMPTY_PROPERTY_GRAPH
    | EMPTY_GRAPH
    | HOME_PROPERTY_GRAPH
    | HOME_GRAPH
    | CURRENT_PROPERTY_GRAPH
    | CURRENT_GRAPH
    ;

<predefined table parameter>
    : EMPTY_BINDING_TABLE
    | EMPTY_TABLE
    | UNIT_BINDING_TABLE
    | UNIT_TABLE
    ;


// Section 20.2 <value expression>
<value expression>
    : <untyped value expression> [ <of value type> ]
    ;

<untyped value expression>
    : <common value expression>
    | <boolean value expression>
    ;

<common value expression>
    : <numeric value expression>
    | <string value expression>
    | <datetime value expression>
    | <duration value expression>
    | <collection value expression>
    | <map value expression>
    | <record value expression>
    | <reference value expression>
    ;

<reference value expression>
    : <primary result object expression>
    | <graph element value expression>
    ;

<collection value expression>
    : <list value expression>
    | <multiset value expression>
    | <set value expression>
    | <ordered set value expression>
    ;

<set value expression>
    : <value expression primary>
    ;

** Editor’s Note (number 340) **
Further detail needs to be added regarding <set value expression>. See Possible Problem
GQL-081 .
<ordered set value expression> :
<value expression primary>
** Editor’s Note (number 341) **
Further detail needs to be added regarding <ordered set value expression>. See Possible
Problem GQL-082 .


<map value expression>
    : <value expression primary>
    ;

** Editor’s Note (number 342) **
Further detail needs to be added regarding <map value expression>. See Possible Problem
GQL-083 .


<record value expression>
    : <value expression primary>
    ;

// Section 20.3 <boolean value expression>
<boolean value expression>
    : <boolean term>
    | <boolean value expression> OR <boolean term>
    | <boolean value expression> XOR <boolean term>
    ;

<boolean term>
    : <boolean factor>
    | <boolean term> AND <boolean factor>
    ;

<boolean factor>
    : [ NOT ] <boolean test>
    ;

<boolean test>
    : <boolean primary> [ {
      IS [ NOT ]
      | <equals operator>
      | <not equals operator>
    } <truth value> ]
    ;

<truth value>
    : TRUE
    | FALSE
    | UNKNOWN
    | NULL
    ;

<boolean primary>
    : <predicate>
    | <boolean predicand>
    ;

<boolean predicand>
    : <parenthesized Boolean value expression>
    | <non-parenthesized value expression primary>
    ;

<parenthesized Boolean value expression>
    : <left paren> <boolean value expression> <right paren>
    ;


// Section 20.4 <numeric value expression>
<numeric value expression>
    : <term>
    | <numeric value expression> <plus sign> <term>
    | <numeric value expression> <minus sign> <term>
    ;

<term>
    : <factor>
    | <term> <asterisk> <factor>
    | <term> <solidus> <factor>
    ;

<factor>
    : [ <sign> ] <numeric primary>
    ;

<numeric primary>
    : <value expression primary>
    | <numeric value function>
    ;


// Section 20.5 <value expression primary>
<value expression primary>
    : <parenthesized value expression>
    | <non-parenthesized value expression primary>
    ;

<parenthesized value expression>
    : <left paren> <value expression> <right paren>
    ;

<non-parenthesized value expression primary>
    : <property reference>
    | <binding variable>
    | <parameter value specification>
    | <unsigned value specification>
    | <aggregate function>
    | <collection value constructor>
    | <value query expression>
    | <case expression>
    | <cast specification>
    | <element_id function>
    ;


// Section 20.6 <numeric value function>
<numeric value function>
    : <length expression>
    | <absolute value expression>
    | <modulus expression>
    | <trigonometric function>
    | <general logarithm function>
    | <common logarithm>
    | <natural logarithm>
    | <exponential function>
    | <power function>
    | <square root>
    | <floor function>
    | <ceiling function>
    | <inDegree function>
    | <outDegree function>
    ;

<length expression>
    : <char length expression>
    | <byte length expression>
    | <path length expression>
    ;

<char length expression>
    : CHARACTER_LENGTH <left paren> <character string value expression> <right paren>
    ;

<byte length expression>
    : {
    BYTE_LENGTH
    | OCTET_LENGTH
    } <left paren> <string value expression> <right paren>
    ;

<path length expression>
    : LENGTH <left paren> <binding variable> <right paren>
    ;

<absolute value expression>
    : ABS <left paren> <numeric value expression> <right paren>
    ;

<modulus expression>
    : MOD <left paren> <numeric value expression dividend> <comma> <numeric value expression divisor> <right paren>
    ;

<numeric value expression dividend>
    : <numeric value expression>
    ;

<numeric value expression divisor>
    : <numeric value expression>
    ;

<trigonometric function>
    : <trigonometric function name> <left paren> <numeric value expression> <right paren>
    ;

<trigonometric function name>
    : SIN | COS | TAN | COT | SINH | COSH | TANH | ASIN | ACOS | ATAN | DEGREES | RADIANS
    ;

<general logarithm function>
    : LOG <left paren> <general logarithm base> <comma> <general logarithm argument> <right paren>
    ;

<general logarithm base>
    : <numeric value expression>
    ;

<general logarithm argument>
    : <numeric value expression>
    ;

<common logarithm>
    : LOG10 <left paren> <numeric value expression> <right paren>
    ;

<natural logarithm>
    : LN <left paren> <numeric value expression> <right paren>
    ;

<exponential function>
    : EXP <left paren> <numeric value expression> <right paren>
    ;

<power function>
    : POWER <left paren> <numeric value expression base> <comma> <numeric value expression exponent> <right paren>
    ;

<numeric value expression base>
    : <numeric value expression>
    ;

<numeric value expression exponent>
    : <numeric value expression>
    ;

<square root>
    : SQRT <left paren> <numeric value expression> <right paren>
    ;

<floor function>
    : FLOOR <left paren> <numeric value expression> <right paren>
    ;

<ceiling function>
    : { CEIL | CEILING } <left paren> <numeric value expression> <right paren>
    ;

<inDegree function>
    : inDegree <left paren> <binding variable> <right paren>
    ;

<outDegree function>
    : outDegree <left paren> <binding variable> <right paren>
    ;



// Section 20.7 <string value expression>
<string value expression>
    : <character string value expression>
    | <byte string value expression>
    ;

<character string value expression>
    : <character string concatenation>
    | <character string factor>
    ;

<character string concatenation>
    : <character string value expression> <concatenation operator> <character string factor>
    ;

<character string factor>
    : <character string primary>
    ;

<character string primary>
    : <value expression primary>
    | <string value function>
    ;

<byte string value expression>
    : <byte string concatenation>
    | <byte string factor>
    ;

<byte string factor>
    : <byte string primary>
    ;

<byte string primary>
    : <value expression primary>
    | <string value function>
    ;

<byte string concatenation>
    : <byte string value expression> <concatenation operator> <byte string factor>
    ;


// Section 20.8 <string value function>
<string value function>
    : <character string function>
    | <byte string function>
    ;

<character string function>
    : <substring function>
    | <fold>
    | <trim function>
    | <normalize function>
    ;

<substring function>
    : SUBSTRING <left paren> <character string value expression> <comma> <start position> [ <comma> <string length> ] <right paren>
    | LEFT <left paren> <character string value expression> <comma> <string length> <right paren>
    | RIGHT <left paren> <character string value expression> <comma> <string length> <right paren>
    ;

<fold>
    : { UPPER | toUpper | LOWER | toLower } <left paren> <character string value expression> <right paren>
    ;

<trim function>
    : TRIM <left paren> <trim source> [ <comma> <trim specification> [ <trim character string> ] ] <right paren>
    | lTrim <left paren> <trim source> <right paren>
    | rTrim <left paren> <trim source> <right paren>
    ;

<trim source>
    : <character string value expression>
    ;

<trim specification>
    : LEADING
    | TRAILING
    | BOTH
    ;

<trim character string>
    : <character string value expression>
    ;

<normalize function>
    : NORMALIZE <left paren> <character string value expression> [ <comma> <normal form> ] <right paren>
    ;

<normal form>
    : NFC
    | NFD
    | NFKC
    | NFKD
    ;

<byte string function>
    : <byte substring function>
    | <byte string trim function>
    ;

<byte substring function>
    : SUBSTRING <left paren> <byte string value expression> <comma> <start position> [ <comma> <string length> ] <right paren>
    | LEFT <left paren> <byte string value expression> <comma> <string length> <right paren>
    | RIGHT <left paren> <byte string value expression> <comma> <string length> <right paren>
    ;

<byte string trim function>
    : TRIM <left paren> <byte string trim source> [ <comma> <trim specification> [ <trim byte string> ] ] <right paren>
    | lTrim <left paren> <byte string trim source> <right paren>
    | rTrim <left paren> <byte string trim source> <right paren>
    ;

<byte string trim source>
    : <byte string value expression>
    ;

<trim byte string>
    : <byte string value expression>
    ;

<start position>
    : <numeric value expression>
    ;

<string length>
    : <numeric value expression>
    ;


// Section 20.9 <datetime value expression>
<datetime value expression>
    : <datetime term>
    | <duration value expression> <plus sign> <datetime term>
    | <datetime value expression> <plus sign> <duration term>
    | <datetime value expression> <minus sign> <duration term>
    ;
    
<datetime term>
    : <datetime factor>
    ;

<datetime factor>
    : <datetime primary>
    ;

<datetime primary>
    : <value expression primary>
    | <datetime value function>
    ;



// Section 20.10 <datetime value function>
<datetime value function>
    : <date function>
    | <time function>
    | <datetime function>
    | <local time function>
    | <local datetime function>
    ;

<date function>
    : CURRENT_DATE
    | DATE <left paren> [ <date function parameters> ] <right paren>
    ;

<time function>
    : CURRENT_TIME
    | TIME <left paren> [ <time function parameters> ] <right paren>
    ;

<local time function>
    : LOCALTIME
    | LOCALTIME <left paren> [ <time function parameters> ] <right paren>
    ;

<datetime function>
    : CURRENT_TIMESTAMP
    | DATETIME <left paren> [ <datetime function parameters> ] <right paren>
    ;

<local datetime function>
    : LOCALTIMESTAMP
    | LOCALDATETIME <left paren> [ <datetime function parameters> ] <right paren>
    ;

<date function parameters>
    : <date string>
    | <map value constructor>
    ;

<time function parameters>
    : <time string>
    | <map value constructor>
    ;

<datetime function parameters>
    : <datetime string>
    | <map value constructor>
    ;



// Section 20.11 <duration value expression>
<duration value expression>
    : <duration term>
    | <duration value expression 1> <plus sign> <duration term 1>
    | <duration value expression 1> <minus sign> <duration term 1>
    | <left paren> <datetime value expression> <minus sign> <datetime term> <right paren>
    ;

<duration term>
    : <duration factor>
    | <duration term 2> <asterisk> <factor>
    | <duration term 2> <solidus> <factor>
    | <term> <asterisk> <duration factor>
    ;

<duration factor>
    : [ <sign> ] <duration primary>
    ;

<duration primary>
    : <value expression primary>
    | <duration value function>
    ;

<duration value expression 1>
    : <duration value expression>
    ;

<duration term 1>
    : <duration term>
    ;

<duration term 2>
    : <duration term>
    ;


// Section 20.12 <duration value function>
<duration value function>
    : <duration function>
    | <duration absolute value function>
    ;

<duration function>
    : DURATION <left paren> <duration function parameters> <right paren>
    ;

<duration function parameters>
    : <duration string>
    | <map value constructor>
    ;

<duration absolute value function>
    : ABS <left paren> <duration value expression> <right paren>
    ;



// Section 20.13 <graph element value expression>
<graph element value expression>
    : <graph element primary>
    ;

<graph element primary>
    : <graph element function>
    | <value expression primary>
    ;

// Section 20.14 <graph element function>
<graph element function>
    : <start node function>
    | <end node function>
    ;

<start node function>
    : startNode <left paren> <binding variable> <right paren>
    ;

<end node function>
    : endNode <left paren> <binding variable> <right paren>
    ;

// Section 20.15 <collection value constructor>
<collection value constructor>
    : <list value constructor>
    | <multiset value constructor>
    | <set value constructor>
    | <ordered set value constructor>
    | <map value constructor>
    | <record value constructor>
    ;


// Section 20.16 <list value expression>
<list value expression>
    : <list concatenation>
    | <list primary>
    ;

<list concatenation>
    : <list value expression 1> <concatenation operator> <list primary>
    ;

<list value expression 1>
    : <list value expression>
    ;

<list primary>
    : <list value function>
    | <value expression primary>
    ;


// Section 20.17 <list value function>
<list value function>
    : <tail list function>
    | <trim list function>
    ;

<tail list function>
    : tail <left paren> <list value expression> <right paren>
    ;

<trim list function>
    : TRIM <left paren> <list value expression> <comma> <numeric value expression> <right paren>
    ;



// Section 20.18 <list value constructor>
<list value constructor>
    : <list value constructor by enumeration>
    ;

<list value constructor by enumeration>
    : <list value type name> <left bracket> <list element list> <right bracket>
    ;

<list element list>
    : <list element> [ { <comma> <list element> }... ]
    ;

<list element>
    : <value expression>
    ;



// Section 20.19 <multiset value expression>
<multiset value expression>
    : <multiset term>
    | <multiset value expression> MULTISET UNION [ ALL | DISTINCT ] <multiset term>
    | <multiset value expression> MULTISET EXCEPT [ ALL | DISTINCT ] <multiset term>
    ;

<multiset term>
    : <multiset primary>
    | <multiset term> MULTISET INTERSECT [ ALL | DISTINCT ] <multiset primary>
    ;

<multiset primary>
    : <multiset value function>
    | <value expression primary>
    ;



// Section 20.20 <multiset value function>
<multiset value function>
    : <multiset set function>
    ;

<multiset set function>
    : SET <left paren> <multiset value expression> <right paren>
    ;


// Section 20.21 <multiset value constructor>
<multiset value constructor>
    : <multiset value constructor by enumeration>
    ;

<multiset value constructor by enumeration>
    : MULTISET <left brace> <multiset element list> <right brace>
    ;

<multiset element list>
    : <multiset element> [ { <comma> <multiset element> }... ]
    ;

<multiset element>
    : <value expression>
    ;



// Section 20.22 <set value constructor>
<set value constructor>
    : <set value constructor by enumeration>
    ;

<set value constructor by enumeration>
    : SET <left brace> <set element list> <right brace>
    ;

<set element list>
    : <set element> [ { <comma> <set element> }... ]
    ;

<set element>
    : <value expression>
    ;


// Section 20.23 <ordered set value constructor>
<ordered set value constructor>
    : <ordered set value constructor by enumeration>
    ;

<ordered set value constructor by enumeration>
    : ORDERED SET {
      <left brace> <ordered set element list> <right brace>
      | <left bracket> <ordered set element list> <right bracket>
    }
    ;

<ordered set element list>
    : <ordered set element> [ { <comma> <ordered set element> }... ]
    ;

<ordered set element>
    : <value expression>
    ;



// Section 20.24 <map value constructor>
<map value constructor>
    : <map value constructor by enumeration>
    ;

<map value constructor by enumeration>
    : MAP <left brace> <map element list> <right brace>
    ;

<map element list>
    : <map element> [ { <comma> <map element> }... ]
    ;

<map element>
    : <map key> <map value>
    ;

<map key>
    : <value expression> <colon>
    ;

<map value>
    : <value expression>
    ;



// Section 20.25 <record value constructor>
<record value constructor>
    : <record value constructor by enumeration>
    | UNIT
    ;

<record value constructor by enumeration>
    : [ RECORD ] <left brace> <field list> <right brace>
    ;

<field list>
    : <field> [ { <comma> <field> }... ]
    ;

<field>
    : <field name> <field value>
    ;

<field value>
    : <value expression>
    ;



// Section 20.26 <property reference>
<property reference>
    : <graph element primary> <period> <property name>
    ;



// Section 20.27 <value query expression>
<value query expression>
    : VALUE <nested query specification>
    ;


// Section 20.28 <case expression>
<case expression>
    : <case abbreviation>
    | <case specification>
    ;

<case abbreviation>
    : NULLIF <left paren> <value expression> <comma> <value expression> <right paren>
    | COALESCE <left paren> <value expression> { <comma> <value expression> }... <right paren>
    ;

<case specification>
    : <simple case>
    | <searched case>
    ;
    
<simple case>
    : CASE <case operand> <simple when clause>... [ <else clause> ] END
    ;

<searched case>
    : CASE <searched when clause>... [ <else clause> ] END
    ;

<simple when clause>
    : WHEN <when operand list> THEN <result>
    ;

<searched when clause>
    : WHEN <search condition> THEN <result>
    ;

<else clause>
    : ELSE <result>
    ;

<case operand>
    : <non-parenthesized value expression primary>
    | <element reference>
    ;

<when operand list>
    : <when operand> [ { <comma> <when operand> }... ]
    ;

<when operand>
    : <non-parenthesized value expression primary>
    | <comparison predicate part 2>
    | <null predicate part 2>
    | <directed predicate part 2>
    | <labeled predicate part 2>
    | <source predicate part 2>
    | <destination predicate part 2>
    ;

<result>
    : <result expression>
    | NULL
    ;

<result expression>
    : <value expression>
    ;



// Section 20.29 <cast specification>
<cast specification>
    : CAST <left paren> <cast operand> AS <cast target> <right paren>
    ;

<cast operand>
    : <value expression>
    | <null literal>
    ;

<cast target>
    : <predefined type>
    ;



// Section 20.30 <element_id function>
<element_id function>
    : ELEMENT_ID <left paren> <element reference> <right paren>
    ;



// Section 21.1 <literal>
<literal>
    : <signed numeric literal>
    | <general literal>
    ;

<general literal>
    : <predefined type literal>
    | <list literal>
    | <set literal>
    | <multiset literal>
    | <ordered set literal>
    | <map literal>
    | <record literal>
    ;

<predefined type literal>
    : <boolean literal>
    | <character string literal>
    | <byte string literal>
    | <temporal literal>
    | <duration literal>
    | <null literal>
    ;

<unsigned literal>
    : <unsigned numeric literal>
    | <general literal>
    ;

<boolean literal>
    : TRUE | FALSE | UNKNOWN
    ;

<character string literal>
    : <single quoted character sequence>
    | <double quoted character sequence>
    ;

<unbroken character string literal>
    : <unbroken single quoted character sequence>
    | <unbroken double quoted character sequence>
    ;

<single quoted character sequence>
    : <unbroken single quoted character sequence> [ { <separator> <unbroken single quoted character sequence> }... ]
    ;

<double quoted character sequence>
    : <unbroken double quoted character sequence> [ { <separator> <unbroken double quoted character sequence> }... ]
    ;

<unbroken single quoted character sequence>
    : <quote> [ <single quoted character representation>... ] <quote>
    ;

<unbroken double quoted character sequence>
    : <double quote> [ <double quoted character representation>... ] <double quote>
    ;

<unbroken accent quoted character sequence>
    : <grave accent> [ <accent quoted character representation>... ] <grave accent>
    ;

<single quoted character representation>
    : <character representation>
    ;

!! See the Syntax Rules.
<double quoted character representation>
    : <character representation>
!! See the Syntax Rules.

<accent quoted character representation>
    : <character representation>
    ;

!! See the Syntax Rules.
<character representation>
    : <string literal character>
    | <escaped character>
    ;

<string literal character>
    :
    !! See the Syntax Rules.

<escaped character>
    : <escaped reverse solidus>
    | <escaped quote>
    | <escaped double quote>
    | <escaped tab>
    | <escaped backspace>
    | <escaped newline>
    | <escaped carriage return>
    | <escaped form feed>
    | <unicode escape value>

<escaped reverse solidus>
    : <reverse solidus> <reverse solidus>
    ;

<escaped quote>
    : <reverse solidus> <quote>
    ;

<escaped double quote>
    : <reverse solidus> <double quote>
    ;

<escaped tab>
    : <reverse solidus> t
    ;

<escaped backspace>
    : <reverse solidus> b

<escaped newline>
    : <reverse solidus> n

<escaped carriage return>
    : <reverse solidus> r

<escaped form feed>
    : <reverse solidus> f
    ;

<unicode escape value>
    : <unicode 4 digit escape value>
    | <unicode 6 digit escape value>
    ;

<unicode 4 digit escape value>
    : <reverse solidus> u <hex digit> <hex digit> <hex digit> <hex digit>
    ;

<unicode 6 digit escape value>
    : <reverse solidus> U <hex digit> <hex digit> <hex digit> <hex digit> <hex digit> <hex digit>
    ;

<byte string literal>
    : X <quote> [ <space>... ] [ { <hex digit> [ <space>... ] <hex digit> [ <space>... ] }... ] <quote> [ { <separator> <quote> [ <space>... ] [ { <hex digit> [ <space>... ] <hex digit> [ <space>... ] }... ] <quote> }... ]
    ;

<numeric literal>
    : <signed numeric literal>
    | <unsigned numeric literal>
    ;

<signed numeric literal>
    : [ <sign> ] <unsigned numeric literal>
    ;

<unsigned numeric literal>
    : <exact numeric literal>
    | <approximate numeric literal>
    ;

<exact numeric literal>
    : <unsigned integer>
    | <unsigned decimal integer> [ <period> [ <unsigned decimal integer> ] ]
    | <period> <unsigned decimal integer>
    ;

<sign>
    : <plus sign>
    | <minus sign>
    ;

<unsigned integer>
    : <unsigned decimal integer>
    | <unsigned hexadecimal integer>
    | <unsigned octal integer>
    | <unsigned binary integer>
    ;

<unsigned decimal integer>
    : <digit> [ { [ <underscore> ] <digit> }... ]
    ;

<unsigned hexadecimal integer>
    : 0x { [ <underscore> ] <hex digit> }...
    ;

<unsigned octal integer>
    : 0o { [ <underscore> ] <octal digit> }...
    ;

<unsigned binary integer>
    : 0b { [ <underscore> ] <binary digit> }...
    ;

<signed decimal integer>
    : [ <sign> ] <unsigned decimal integer>
    ;

<approximate numeric literal>
    :
    <mantissa> E <exponent>
    ;

<mantissa>
    : <exact numeric literal>
    ;

<exponent>
    : <signed decimal integer>
    ;

<temporal literal>
    : <date literal>
    | <time literal>
    | <datetime literal>
    ;

<date literal>
    : DATE <date string>
    ;

<time literal>
    : TIME <time string>
    ;

<datetime literal>
    : { DATETIME | TIMESTAMP } <datetime string>
    ;

<date string>
    : <unbroken character string literal>
    ;

<time string>
    : <unbroken character string literal>
    ;

<datetime string>
    : <unbroken character string literal>
    ;

<duration literal>
    : DURATION <duration string>
    | <SQL-interval literal>
    ;

<duration string>
    : <unbroken character string literal>
    ;

<SQL-interval literal>
    :
  !! See the Syntax Rules.

<null literal>
    : NULL
    ;

<list literal>
    : <list value constructor by enumeration>
    ;

<set literal>
    : <set value constructor by enumeration>
    ;

<multiset literal>
    : <multiset value constructor by enumeration>
    ;

<ordered set literal>
    : <ordered set value constructor by enumeration>
    ;

<map literal>
    : <map value constructor by enumeration>
    ;

<record literal>
    : <record value constructor by enumeration>
    ;


// Section 21.2 <value type>
<value type>
    : ANY
    | <predefined type>
    | <graph element type>
    | <collection type>
    | <map value type>
    | <record value type>
    | <graph type expression>
    | <binding table type expression>
    | NOTHING
    ;

<of value type>
    : [ <of type prefix> ] <value type>
    ;

<of type prefix>
    : <double colon> | OF
    ;

<predefined type>
    : <boolean type>
    | <character string type>
    | <byte string type>
    | <numeric type>
    | <temporal type>
    ;

<boolean type>
    : BOOL | BOOLEAN
    ;

<character string type>
    : { STRING | VARCHAR } [ <left paren> <max length> <right paren> ]
    ;

<byte string type>
    : BYTES [ <left paren> [ <min length> <comma> ] <max length> <right paren> ]
    | BINARY [ <fixed length> ]
    | VARBINARY [ <max length> ]
    ;

<min length>
    : <unsigned decimal integer>
    ;

<max length>
    : <unsigned decimal integer>
    ;

<fixed length>
    : <unsigned decimal integer>
    ;

<numeric type>
    : <exact numeric type>
    | <approximate numeric type>
    ;

<exact numeric type>
    : <binary exact numeric type>
    | <decimal exact numeric type>
    ;

<binary exact numeric type>
    :
    <binary exact signed numeric type>
    | <binary exact unsigned numeric type>
    ;

<binary exact signed numeric type>
    : INT8
    | INT16
    | INT32
    | INT64
    | INT128
    | INT256
    | SMALLINT
    | INT [ <left paren> <precision> <right paren> ]
    | BIGINT
    | [ SIGNED ] <verbose binary exact numeric type>
    ;

<binary exact unsigned numeric type>
    : UINT8
    | UINT16
    | UINT32
    | UINT64
    | UINT128
    | UINT256
    | UINT [ <left paren> <precision> <right paren> ]
    | UNSIGNED <verbose binary exact numeric type>
    ;

<verbose binary exact numeric type>
    : INTEGER8
    | INTEGER16
    | INTEGER32
    | INTEGER64
    | INTEGER128
    | INTEGER256
    | INTEGER [ <left paren> <precision> <right paren> ]
    ;

<decimal exact numeric type>
    : { DECIMAL | DEC } <left paren> <precision> [ <comma> <scale> ] <right paren>
    ;

<precision>
    : <unsigned decimal integer>
    ;

<scale>
    : <unsigned decimal integer>
    ;

<approximate numeric type>
    : FLOAT16
    | FLOAT32
    | FLOAT64
    | FLOAT128
    | FLOAT128
    | FLOAT [ <left paren> <precision> [ <comma> <scale> ] <right paren> ]
    | REAL
    | DOUBLE [ PRECISION ]
    ;

<temporal type>
    : DATETIME
    | LOCALDATETIME
    | DATE
    | TIME
    | LOCALTIME
    | DURATION
    ;

<graph element type>
    : NODE
    | VERTEX
    | EDGE
    | RELATIONSHIP
    ;

<collection type>
    : <list value type>
    | <multiset value type>
    | <set value type>
    | <ordered set value type>
    ;

<list value type>
    : <value type> <list value type name>
    ;

<list value type name>
    : LIST
    | ARRAY
    ;

<multiset value type>
    : <value type> MULTISET
    ;

<set value type>
    : <value type> SET
    ;

<ordered set value type>
    : <value type> ORDERED SET
    ;

<map value type>
    : MAP <left angle bracket> <map key type> <comma> <value type> <right angle bracket>
    ;

<map key type>
    : <predefined type>
    ;

<record value type>
    : [ RECORD ] <left brace> [ <field type list> ] <right brace>
    ;

<field type list>
    : <field type> [ { <comma> <field type> }... ]
    ;

<field type>
    : <field name> [ <of type prefix> ] <value type>
    ;



// Section 21.3 Names and identifiers
<object name>
    : <identifier>
    ;

<schema name>
    : <identifier>
    ;

<graph name>
    : <identifier>
    ;

<element type name>
    : <type name>
    ;

<graph type name>
    : <identifier>
    ;

<type name>
    : <identifier>
    ;

<binding table name>
    : <identifier>
    ;

<value name>
    : <identifier>
    ;

<procedure name>
    : <identifier>
    ;

<query name>
    : <identifier>
    ;

<function name>
    : <identifier>
    ;

<label name>
    : <identifier>
    ;

<property name>
    : <identifier>
    ;

<field name>
    : <identifier>
    ;

<path pattern name>
    : <identifier>
    ;

<parameter name>
    : <dollar sign> <separated identifier>
    ;

<element variable>
    : <variable name>
    ;

<path variable>
    : <variable name>
    ;

<subpath variable>
    : <variable name>
    ;

<static variable name>
    : <variable name>
    ;

<binding variable name>
    : <variable name>
    ;

<variable name>
    : <regular identifier>
    ;

<identifier>
    : <regular identifier>
    | <delimited identifier>
    ;

<separated identifier>
    : <extended identifier>
    | <delimited identifier>
    ;

<edge synonym>
    : EDGE
    | RELATIONSHIP


<node synonym>
    : NODE
    | VERTEX
