

// Section 21.4 <token> and <separator>
<token>
    : <non-delimiter token>
    | <delimiter token>


<non-delimiter token>
    : <regular identifier>
    | <parameter name>
    | <key word>
    | <unsigned numeric literal>
    | <byte string literal>
    | <multiset alternation operator>


<non-delimited identifier>
    : <regular identifier>
    | <extended identifier>


<regular identifier>
    : <identifier start> [ <identifier extend>... ]


** Editor’s Note (number 391) **
The definition of <regular identifier>s should be extended to support more Unicode variants.
See Language Opportunity GQL-029 .
  WG3:W17-027  


<extended identifier>
    : <identifier extend>...


  WG3:W17-027 deleted one production  
  Editorial: Stephen Cannan 2021-11-11 Deleted one redundant production  


<identifier start>
    :
    !! See the Syntax Rules.


<identifier extend>
    :
    !! See the Syntax Rules.




<multiset alternation operator>
    : |+|


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

 /* delimiter token */
 /* GQL special character */
space " "
ampersand "&"
asterisk "*"
circumflex "^"
colon ":"
comma ","
dollar_sign "$"
double_quote """
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
reverse_solidus "\"
right_brace "}"
right_bracket "]"
right_paren ")"
semicolon ";"
solidus "/"
tilde "~"
underscore "_"
vertical_bar "|"
<other language character>
    :
    !! See the Syntax Rules.

bracket_right_arrow "]->"
bracket_tilde_right_arrow "]~>"
concatenation_operator "||"
double_colon "::"
double_minus_sign "--"
double_period ".."
greater_than_operator right_angle_bracket
greater_than_or_equals_operator ">="
left_arrow "<-"
left_arrow_tilde "<~"
left_arrow_bracket "<-["
left_arrow_tilde_bracket "<~["
left_minus_right "<->"
left_minus_slash "<-/"
left_tilde_slash "<~/"
less_than_operator left_angle_bracket
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

<delimited identifier>
    : <double quoted character sequence>
    | <unbroken accent quoted character sequence>


double_solidus "//"


<separator>
    : { <comment> | <whitespace> }...


<whitespace>
    :
  !! See the Syntax Rules.
  ;

<comment>
    : <simple comment>
    | <bracketed comment>


<simple comment>
    : <simple comment introducer> [ <simple comment character>... ] <newline>


<simple comment introducer>
    : <double solidus>
    | <double minus sign>


<simple comment character>
    :
    !! See the Syntax Rules.

<bracketed comment> :
    <bracketed comment introducer>
    <bracketed comment contents>
    <bracketed comment terminator>


bracketed_comment_introducer "/*"
bracketed_comment_terminator "*/"
<bracketed comment contents>
    :
    !! See the Syntax Rules.


<escaped grave accent>
    : <reverse solidus> <grave accent>
    | <doubled grave accent>


doubled_grave_accent "``"


<newline>
    :
    !! See the Syntax Rules.




// Section 21.5 <GQL terminal character>
<GQL terminal character>
    : <GQL language character>
    | <other language character>


<GQL language character>
    : <simple Latin letter>
    | <digit>
    | <GQL special character>


<simple Latin letter>
    : <simple Latin lower-case letter>
    | <simple Latin upper-case letter>


<simple Latin lower-case letter>
    : a | b | c | d | e | f | g | h | i | j | k | l | m | n | o
    | p | q | r | s | t | u | v | w | x | y | z


<simple Latin upper-case letter>
    : A | B | C | D | E | F | G | H | I | J | K | L | M | N | O
    | P | Q | R | S | T | U | V | W | X | Y | Z


<hex digit>
    : <standard digit> | A | B | C | D | E | F | a | b | c | d | e | f


<digit>
    : <standard digit>
    | <other digit>


<standard digit>
    : <octal digit> | 8 | 9


<octal digit>
    : <binary digit> | 2 | 3 | 4 | 5 | 6 | 7


<binary digit>
    : 0 | 1


<other digit>
    :
    !! See the Syntax Rules.






