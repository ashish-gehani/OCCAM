grammar Argv;

constraint :  '{' atomlist '}'
      ;

atomlist: atom ( ',' atom )*
             ;

atom:  ARGV '[' INTEGER ']' BINOP STRING
         ;

ARGV  :   'argv';

BINOP     :   '=' ;

INTEGER     :   DIGIT+ ;

fragment
DIGIT       :   [0-9] ;

STRING      :   '"' (ESCAPE|.)*? '"' ;
fragment
ESCAPE      :   '\\"' | '\\\\'  ;

LINE_COMMENT : '%' .*? '\r'? '\n'  -> skip ;

WHITE_SPACE: [ \t\r\n]+ -> skip ;
