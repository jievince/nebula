

// Section 21.4 <token> and <separator>
<token>
    : <non-delimiter token>
    | <delimiter token>
    ;

<non-delimiter token>
    : <regular identifier>
    | <parameter name>
    | <key word>
    | <unsigned numeric literal>
    | <byte string literal>
    | <multiset alternation operator>
    ;

<non-delimited identifier>
    : <regular identifier>
    | <extended identifier>
    ;

<regular identifier>
    : <identifier start> [ <identifier extend>... ]
    ;

** Editor’s Note (number 391) **
The definition of <regular identifier>s should be extended to support more Unicode variants.
See Language Opportunity GQL-029 .
  WG3:W17-027  


<extended identifier>
    : <identifier extend>...
    ;

  WG3:W17-027 deleted one production  
  Editorial: Stephen Cannan 2021-11-11 Deleted one redundant production  


<identifier start>
    :
    !! See the Syntax Rules.
    ;

<identifier extend>
    :
    !! See the Syntax Rules.
    ;

<key word>
    : <reserved word>
    | <non-reserved word>
    ;

<reserved word>
    : <case-insensitive reserved word>
    | endNode | inDegree | lTrim | outDegree | percentileCont | percentileDist | rTrim
    | startNode | stDev | stDevP | tail | toLower | toUpper
    ;

<case-insensitive reserved word>
    : ABS | ACOS | ADD | AGGREGATE | ALIAS | ALL | ALL_DIFFERENT | AND | ANY | ARRAY | AS | ASC
| ASCENDING | ASIN | AT | ATAN | AVG
| BINARY | BIGINT | BOOL | BOOLEAN | BOTH | BY | BYTE_LENGTH | BYTES
| CALL | CASE | CAST | CATALOG | CEIL | CEILING | CHARACTER | CHARACTER_LENGTH | CLEAR
| CLONE | CLOSE | COALESCE | COLLECT | COMMIT | CONSTRAINT | CONSTANT | CONSTRUCT | COPY
| COS | COSH | COST | COT | COUNT | CURRENT_DATE | CURRENT_GRAPH | CURRENT_PROPERTY_GRAPH
| CURRENT_ROLE | CURRENT_SCHEMA | CURRENT_TIME | CURRENT_TIMESTAMP | CURRENT_USER | CREATE
| DATA | DATE | DATETIME | DEC | DECIMAL | DEFAULT | DEGREES | DELETE | DETACH | DESC
| DESCENDING | DIRECTORIES | DIRECTORY | DISTINCT | DO | DOUBLE | DROP | DURATION
| ELEMENT_ID | ELSE | END | ENDS | EMPTY_BINDING_TABLE | EMPTY_GRAPH
| EMPTY_PROPERTY_GRAPH | EMPTY_TABLE | EXCEPT | EXISTS | EXISTING | EXP | EXPLAIN
| FALSE | FILTER | FLOAT | FLOAT16 | FLOAT32 | FLOAT64 | FLOAT128 | FLOAT256
| FLOOR | FOR | FROM | FUNCTION | FUNCTIONS
| GQLSTATUS | GRANT | GROUP
| HAVING | HOME_GRAPH | HOME_PROPERTY_GRAPH | HOME_SCHEMA
| IN | INSERT | INT | INTEGER | INT8 | INTEGER8 | INT16 | INTEGER16 | INT32 | INTEGER32
| INT64 | INTEGER64 | INT128 | INTEGER128 | INT256 | INTEGER256
| INTERSECT | IF | IS
| KEEP
| LEADING | LEFT | LENGTH | LET | LIKE | LIKE_REGEX | LIMIT | LIST | LN
| LOCALDATETIME | LOCALTIME | LOCALTIMESTAMP | LOG | LOG10 | LOWER
| MANDATORY | MAP | MATCH | MERGE | MAX | MIN | MOD | MULTI | MULTIPLE | MULTISET
| NEW | NOT | NORMALIZE | NOTHING | NULL | NULLS | NULLIF | NUMERIC
| OCCURRENCES_REGEX | OCTET_LENGTH | OF | OFFSET | ON | OPTIONAL | OR | ORDER | ORDERED
| OTHERWISE
| PARAMETER | PATH | PATHS | PARTITION | POSITION_REGEX | POWER | PRECISION | PROCEDURE
| PROCEDURES
| PRODUCT | PROFILE | PROJECT
| QUERIES | QUERY
| RADIANS | REAL | RECORD | RECORDS | REFERENCE | REMOVE | RENAME | REPLACE | REQUIRE
| RESET | RESULT | RETURN | REVOKE | RIGHT | ROLLBACK
| SAME | SCALAR | SCHEMA | SCHEMAS | SCHEMATA | SELECT | SESSION | SET | SKIP | SIGNED
| SIN
| SINGLE | SINH | SMALLINT | SQRT | START | STARTS | STRING | SUBSTRING | SUBSTRING_REGEX
| SUM
| TAN | TANH | THEN | TIME | TIMESTAMP | TRAILING | TRANSLATE_REGEX | TRIM | TRUE
| TRUNCATE
| UINT | UINT8 | UINT16 | UINT32 | UINT64 | UINT128 | UINT256 | UNION | UNIT
| UNIT_BINDING_TABLE | UNIT_TABLE | UNIQUE | UNNEST | UNKNOWN | UNSIGNED | UNWIND
| UPPER | USE
| VALUE | VALUES | VARBINARY | VARCHAR
| WHEN | WHERE | WITH | WITHOUT
| XOR
| YIELD
| ZERO
;


** Editor’s Note (number 392) **
WG3:W04-009R1 did not do a thorough analysis of whether KEEP needs to be a <reserved
word>. It is a Language Opportunity to investigate this and possibly make it a <nonreserved
word>. See Language Opportunity GQL-039 .


<non-reserved word>
    : <case-insensitive non-reserved word>
    ;

<case-insensitive non-reserved word>
    : ACYCLIC
| BINDING
| CLASS_ORIGIN | COMMAND_FUNCTION | COMMAND_FUNCTION_CODE | CONDITION_NUMBER | CONNECTING
| DESTINATION | DIRECTED
| EDGE | EDGES
| FINAL | FIRST
| GRAPH | GRAPHS | GROUPS
| INDEX
| LAST | LABEL | LABELED | LABELS
| MESSAGE_TEXT | MORE | MUTABLE
| NFC | NFD | NFKC | NFKD | NODE | NODES | NORMALIZED | NUMBER
| ONLY | ORDINALITY
| PATTERN | PATTERNS | PROPERTY | PROPERTIES
| READ | RELATIONSHIP | RELATIONSHIPS | RETURNED_GQLSTATUS
| SHORTEST | SIMPLE | SOURCE | SUBCLASS_ORIGIN
| TABLE | TABLES | TIES | TO | TRAIL | TRANSACTION | TYPE | TYPES
| UNDIRECTED
| VERTEX | VERTICES
| WALK | WRITE
| ZONE
;


** Editor’s Note (number 393) **
If we make the <path mode>s WALK, TRAIL, SIMPLE and ACYCLIC <reserved word>s, then they
can be used in a <simplified path pattern expression> to provide fine-grained path mode
control within syntax such as
-/ TRAIL Like* /-
WG3:W04-009R1 felt it better to leave them as <non-reserved word>s so that, in this
example, TRAIL is treated as a label rather than a <path mode>. See Possible Problem GQL-
040 .
435
Informal_working_drafts 39075:202y(E)



<multiset alternation operator>
    : |+|
    ;

<delimiter token>
    : <GQL special character>
    | <bracket right arrow>
    | <bracket tilde right arrow>
    | <character string literal>
    | <concatenation operator>
    | <date string>
    | <datetime string>
    | <delimited identifier>
    | <double colon>
    | <double minus sign>
    | <double period>
    | <duration string>
    | <greater than operator>
    | <greater than or equals operator>
    | <left arrow>
    | <left arrow bracket>
    | <left arrow tilde>
    | <left arrow tilde bracket>
    | <left minus right>
    | <left minus slash>
    | <left tilde slash>
    | <less than operator>
    | <less than or equals operator>
    | <minus left bracket>
    | <minus slash>
    | <not equals operator>
    | <right arrow>
    | <right bracket minus>
    | <right bracket tilde>
    | <slash minus>
    | <slash minus right>
    | <slash tilde>
    | <slash tilde right>
    | <tilde left bracket>
    | <tilde right arrow>
    | <tilde slash>
    | <time string>
    ;

<bracket right arrow>
    : ]->
    ;

<bracket tilde right arrow>
    : ]~>
    ;

<concatenation operator>
    : ||
    ;

<double colon>
    : ::
    ;

<double minus sign>
    : --
    ;

<double period>
    : ..
    ;

<greater than operator>
    : <right angle bracket>
    ;

<greater than or equals operator>
    : >=
    ;

<left arrow>
    : <-
    ;

<left arrow tilde>
    : <~
    ;

<left arrow bracket>
    : <-[
    ;

<left arrow tilde bracket>
    : <~[
    ;

<left minus right>
    : <->
    ;

<left minus slash>
    : <-/
    ;

<left tilde slash>
    : <~/
    ;

<less than operator>
    : <left angle bracket>
    ;

<less than or equals operator>
    : <=
    ;

<minus left bracket>
    : -[
    ;

<minus slash>
    : -/
    ;

<not equals operator>
    : <>
    ;

<right arrow>
    : ->
    ;

<right bracket minus>
    : ]-
    ;

<right bracket tilde>
    : ]~
    ;

<slash minus>
    : /-
    ;

<slash minus right>
    : /->
    ;

<slash tilde>
    : /~
    ;

<slash tilde right>
    : /~>
    ;

<tilde left bracket>
    : ~[
    ;

<tilde right arrow>
    : ~>
    ;

<tilde slash>
    : ~/
    ;

<delimited identifier>
    : <double quoted character sequence>
    | <unbroken accent quoted character sequence>
    ;

<double solidus>
    : //
    ;

<separator>
    : { <comment> | <whitespace> }...
    ;

<whitespace>
    :
  !! See the Syntax Rules.
  ;

<comment>
    : <simple comment>
    | <bracketed comment>
    ;

<simple comment>
    : <simple comment introducer> [ <simple comment character>... ] <newline>
    ;

<simple comment introducer>
    : <double solidus>
    | <double minus sign>
    ;

<simple comment character>
    :
    !! See the Syntax Rules.
    <bracketed comment> :
    <bracketed comment introducer>
    <bracketed comment contents>
    <bracketed comment terminator>
    ;

<bracketed comment introducer>
    :
/*
<bracketed comment terminator> :
*/
<bracketed comment contents>
    :
    !! See the Syntax Rules.
    ;

<escaped grave accent>
    : <reverse solidus> <grave accent>
    | <doubled grave accent>
    ;

<doubled grave accent>
    : ``
    ;

<newline>
    :
    !! See the Syntax Rules.
    ;

<edge synonym>
    : EDGE
    | RELATIONSHIP
    ;

<node synonym>
    : NODE
    | VERTEX
    ;


// Section 21.5 <GQL terminal character>
<GQL terminal character>
    : <GQL language character>
    | <other language character>
    ;

<GQL language character>
    : <simple Latin letter>
    | <digit>
    | <GQL special character>
    ;

<simple Latin letter>
    : <simple Latin lower-case letter>
    | <simple Latin upper-case letter>
    ;

<simple Latin lower-case letter>
    : a | b | c | d | e | f | g | h | i | j | k | l | m | n | o
    | p | q | r | s | t | u | v | w | x | y | z
    ;

<simple Latin upper-case letter>
    : A | B | C | D | E | F | G | H | I | J | K | L | M | N | O
    | P | Q | R | S | T | U | V | W | X | Y | Z
    ;

<hex digit>
    : <standard digit> | A | B | C | D | E | F | a | b | c | d | e | f
    ;

<digit>
    : <standard digit>
    | <other digit>
    ;

<standard digit>
    : <octal digit> | 8 | 9
    ;

<octal digit>
    : <binary digit> | 2 | 3 | 4 | 5 | 6 | 7
    ;

<binary digit>
    : 0 | 1
    ;

<other digit>
    :
    !! See the Syntax Rules.
    ;

<GQL special character>
    : <space>
    | <ampersand>
    | <asterisk>
    | <colon>
    | <equals operator>
    | <comma>
    | <dollar sign>
    | <double quote>
    | <exclamation mark>
    | <grave accent>
    | <right angle bracket>
    | <left brace>
    | <left bracket>
    | <left paren>
    | <left angle bracket>
    | <minus sign>
    | <period>
    | <plus sign>
    | <question mark>
    | <quote>
    | <reverse solidus>
    | <right brace>
    | <right bracket>
    | <right paren>
    | <semicolon>
    | <solidus>
    | <underscore>
    | <vertical bar>
    | <percent>
    | <circumflex>
    | <tilde>
    ;

/* ** Editor’s Note (number 395) **
The character <BNF name="apostrophe"/>, i.e., ' from SQL is not included. <BNF
name="apostrophe"/> is Unicode character \u0027 that is believed to be the same as that
of <quote>. However, there is a case to be made to replace <quote> with <BNF name="apostrophe"/>
since that is the name Unicode uses for that character. See Language Opportunity
GQL-009 . */


<space>
    :
    !! See the Syntax Rules.
    ;

<ampersand>
    : &
    ;

<asterisk>
    : *
    ;

<circumflex>
    : ^
    ;

<colon>
    : :
    ;

<comma>
    : ,
    ;

<dollar sign>
    : $
    ;

<double quote>
    : "
    ;

<equals operator>
    : =
    ;

<exclamation mark>
    : !
    ;

<right angle bracket>
    : >
    ;

<grave accent>
    : `
    ;

<left brace>
    : {
    ;

<left bracket>
    : [
    ;

<left paren>
    : (
    ;

<left angle bracket>
    : <
    ;

<minus sign>
    : -
    ;

<percent>
    : %
    ;

<period>
    : .
    ;

<plus sign>
    : +
    ;

<question mark>
    : ?
    ;

<quote>
    : '
    ;

<reverse solidus>
    : \
    ;

<right brace>
    : }
    ;

<right bracket>
    : ]
    ;

<right paren>
    : )
    ;

<semicolon>
    : ;
    ;

<solidus>
    : /
    ;

<tilde>
    : ~
    ;

<underscore>
    : _
    ;

<vertical bar>
    : |
    ;

<other language character>
    :
    !! See the Syntax Rules.



