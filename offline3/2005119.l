%option noyywrap
%x MULTI_LINE_COMMENT
%x STRING_SM
%x SINGLE_COMMENT

%{

#include<bits/stdc++.h>
#include<stdio.h>
#include<cstdlib>
#include<string>
#include<vector>
#include "2005119_symbolTable.cpp"
#include "y.tab.h"
using namespace std;


void yyerror(char *);

int lineCount = 1;
int  errorCount = 0; 
int startLine = 0; 

string str; 
string token;
string cmt; 

int stringLine = 0; 
int multiLine = 0;
 
extern ofstream logfile;
extern ofstream errorfile; 

char escapedChar() {
    string str = yytext;
    string x = "\'";
    
    if (str[0] != '\'') {
        str.insert(0, x);
        str.insert(str.length(), x);
    }

    if (str[1] != '\\')
        return str[1];
    else if (str[1] == '\\') {
        switch (str[2]) {
            case 'n': return '\n';
            case 't': return '\t';
            case '\"': return '\"';
            case '\\': return '\\';
            case 'a': return '\a';
            case 'f': return '\f';
            case 'r': return '\r';
            case 'b': return '\b';
            case 'v': return '\v';
            case '0': return '\0';
            default: return '0';
        }
    }
    return '0';
}


void printError(string error) {
    logfile << "Error at line# " << lineCount << ": " << error << " " << yytext << endl; 
    errorfile << "Error at line# " << lineCount << ": " << error << " " << yytext << endl; 
    errorCount++; 
}

void setParseTreeInfo(int lineCount, bool check) {
        yylval.symbol->setStartLine(lineCount); 
        yylval.symbol->setEndLine(lineCount); 
        yylval.symbol->isSame(); 
        yylval.symbol->setleaf(check); 
}

void print(string token, string lexeme, bool attribute = true) {
    symbolInfo* info = new symbolInfo(yytext, token);
    logfile << "Line# " << lineCount << ": Token <" << token << "> Lexeme " << lexeme << " found" << endl;
    yylval.symbol = info;
    setParseTreeInfo(lineCount, true);
}

void printString() {
        if(multiLine == 0) {
            //logfile << "Line# " << stringLine << ": Token <SINGLE LINE STRING> Lexeme " << str << " found" << endl; 
        }
        else if(multiLine == 1) {
           //logfile << "Line# " << stringLine << ": Token <MULTI LINE STRING> Lexeme " << str << " found" << endl; 
        }
        multiLine = 0; 
        stringLine = 0; 
        str = "";
}

%}

WHITESPACE [ \t\f\r\v]+
LETTER [a-zA-Z]
DIGIT [0-9]
NEWLINE \n
SINGLE_CHAR ([ -~]{-}['\\])
SPECIAL_CHAR [\"\'nfratbv0\\]
INTEGER {DIGIT}+
FLOAT ({DIGIT}+\.?{DIGIT}*|\.{DIGIT}+)([Ee][+-]?{DIGIT}+)?
TOO_MANY_DECIMAL_POINTS ({DIGIT}+\.{DIGIT}+\.{DIGIT}+(\.{DIGIT}+)*)+
ILLFORMED_NUMBER ({DIGIT}+\.?{DIGIT}*|\.{DIGIT}+)([Ee][+-]?({DIGIT}*\.?{DIGIT}*)|\.?{DIGIT}*)+
CHAR '([ !-~]{-}['\\])'|'\\{SPECIAL_CHAR}'
MULTICHAR_CONST_CHAR '{SINGLE_CHAR}{2,}'
UNFINISHED_CONST_CHAR '{SINGLE_CHAR}{1}|('(\\{SPECIAL_CHAR})*)
IDENTIFIER [_A-Za-z][0-9_A-Za-z]*
%%


"if"	{
        print("IF", yytext, false); 
        return IF;
        }

"else"	{
        print("ELSE", yytext, false); 
        return ELSE;
        }

"switch"	{
        print("SWITCH", yytext, false); 
        return SWITCH;
        }

"for"   {
        print("FOR", yytext, false);
        return FOR;
        }

"while" {
        print("WHILE", yytext, false);
        return WHILE;
        }

"do"    {
        print("DO", yytext, false);
        return DO;
        }

"int"   {
        print("INT", yytext, false);
        return INT;
        } 

"char"  {
        print("CHAR", yytext, false);
        return CHAR;
        }

"float" {
        print("FLOAT", yytext, false);
        return FLOAT;
        }

"double" {
        print("DOUBLE", yytext, false);
        return DOUBLE;
        } 

"void"  {
        print("VOID", yytext, false); 
        return VOID;
        }
        
"return" {
        print("RETURN", yytext, false);
        return RETURN;
        } 

"println" {
        print("PRINTLN", yytext);
        return PRINTLN;
        } 

{INTEGER}  { 
        print("CONST_INT", yytext);
        return CONST_INT;
        }

{FLOAT} {
        print("CONST_FLOAT", yytext);
        return CONST_FLOAT;    
        }

{CHAR} {
        print("CONST_CHAR", yytext);
        return CONST_CHAR;   
        }

{TOO_MANY_DECIMAL_POINTS} {
                            symbolInfo* info = new symbolInfo(yytext, "ERROR_FLOAT");
                            printError("TOO_MANY_DECIMAL_POINTS");
                            yylval.symbol = info; 
                            return ERROR_FLOAT;
                          }

{ILLFORMED_NUMBER}        {
                            symbolInfo* info = new symbolInfo(yytext, "ERROR_FLOAT");
                            printError("ILLFORMED_NUMBER");
                            yylval.symbol = info; 
                            return ERROR_FLOAT;
                          }

''     {
        symbolInfo* info = new symbolInfo(yytext, "EMPTY_CONST_CHAR");
        printError("EMPTY_CONST_CHAR");
        yylval.symbol = info; 
       }


{MULTICHAR_CONST_CHAR}   { printError("MULTICHAR_CONST_CHAR"); }
{UNFINISHED_CONST_CHAR}   { printError("UNFINISHED_CONST_CHAR"); lineCount++; }

"+"|"-"  {
        print("ADDOP", yytext); 
        return ADDOP;
        }

"*"|"/"|"%"  { 
        print("MULOP", yytext); 
        return MULOP;  
        }

"++"    {
        print("INCOP", yytext);
        return INCOP;
        }

"--"    {
        print("DECOP", yytext);
        return DECOP; 
        }

"<"|"<="|">"|">="|"=="|"!=" {
        print("RELOP", yytext);
        return RELOP; 
        }

"="     {
        print("ASSIGNOP", yytext);
        return ASSIGNOP;
        }

"&&"|"||" {
        print("LOGICOP", yytext);
        return LOGICOP; 
        }

"&"|"|"|"^"|"<<"|">>"   {
        print("BITOP", yytext);
        }

"!"     {
        print("NOT", yytext);
        return NOT;
        }

"("     {
        print("LPAREN", yytext);
        return LPAREN;      
        }

")"     {
        print("RPAREN", yytext);
        return RPAREN;
        }

"{"     {
        print("LCURL", yytext);
        return LCURL;
        }

"}"     {
        print("RCURL", yytext);
        return RCURL;
        }

"["     {
        print("LSQUARE", yytext);
        return LTHIRD;
        }

"]"     {
        print("RSQUARE", yytext);
        return RTHIRD;
        }

","     {
        print("COMMA", yytext);
        return COMMA;
        }

";"     {
        print("SEMICOLON", yytext);
        return SEMICOLON;
        }

{IDENTIFIER} {
             print("ID", yytext);
             return ID;  
             }

"\""           {
                BEGIN STRING_SM; 
                str = ""; 
                token = "";
                str.append(yytext);
                stringLine = lineCount; 
                }
<STRING_SM>\"     {
                    str.append(yytext); 
                    printString(); 
                    str = ""; token = "";
                    BEGIN INITIAL;  
                  }

<STRING_SM>\\[\r]?\n {
                         str.append("\\\n"); 
                         multiLine = 1; 
                         lineCount++;  
                    }

<STRING_SM>{NEWLINE}    {                          
                        //logfile << "Error at line# " << lineCount << ": UNFINISHED_STRING " << str << endl; 
                        errorCount++; 
                        lineCount++; 
                        str = ""; 
                        token = "";
                        BEGIN INITIAL;                            
                        }

<STRING_SM>\\{SPECIAL_CHAR}    {   
                                    str.append(yytext); 
                                    token += escapedChar();  
                                }

<STRING_SM>. {
               str.append(yytext); 
               token.append(yytext); 
             }

<STRING_SM><<EOF>>  {
                        logfile<<"Error at line# "<<lineCount<<": UNFINISHED_STRING "<<yytext<<endl; 
                        errorCount++;
                        str = ""; 
                        BEGIN INITIAL;
                        return 0;                    
                    }

{WHITESPACE} { }

{NEWLINE}   { lineCount++; }

"/*"        {
                BEGIN(MULTI_LINE_COMMENT); 
                stringLine = lineCount; 
                cmt = "/*" ;    
            }

<MULTI_LINE_COMMENT>"*/" {
                            BEGIN(INITIAL); 
                            logfile << "Line# " << lineCount << ": Token <MULTI LINE COMMENT> Lexeme ";
                            lineCount=stringLine; 
                            //cout << lineCount << stringLine << endl; 
                            cmt.append(yytext); 
                            lineCount--;
                            //logfile << cmt << " found" << endl;
                            stringLine = 0; 
                            cmt = ""; 
                         }

<MULTI_LINE_COMMENT>([\\r]|\n)+ {
                                //lineCount++; 
                                stringLine++; 
                                cmt.append(yytext); 
                                //logfile << "Line# " << lineCount << ": Token <MULTI LINE COMMENT> Lexeme " << yytext << " found" << endl; 
                                }

\/\/    { 
            //logfile << "Line# " << lineCount << ": Token <SINGLE LINE COMMENT> Lexeme ";
            cmt.append(yytext); 
            BEGIN SINGLE_COMMENT;
        }

<SINGLE_COMMENT>.   {cmt.append(yytext);}

<SINGLE_COMMENT>((\\)){NEWLINE} {
                                cmt.append(yytext); 
                                lineCount++; 
                            }

<SINGLE_COMMENT>{NEWLINE}   { 
                             lineCount++; 
                             logfile << cmt << " found" << endl; 
                             cmt = "";
                             BEGIN INITIAL;
                             }

<MULTI_LINE_COMMENT><<EOF>>     {
                                    lineCount = stringLine - 1;
                                    logfile << "Error at line# " << lineCount << ": UNFINISHED_COMMENT " << cmt;  
                                    stringLine = 0; 
                                    //lineCount++;
                                    errorCount++; 
                                    BEGIN INITIAL;
                                    return 0; 
                                }

<MULTI_LINE_COMMENT>.   { cmt.append(yytext); }

{DIGIT}+[A-Z_a-z]+[0-9A-Z_a-z]*  {
                            logfile << "Error at line# " << lineCount << ": INVALID_ID_SUFFIX_NUM_PREFIX " << yytext << endl; 
                            errorCount++; 
                        } 

.   { 
        logfile << "Error at line# " << lineCount << ": UNRECOGNIZED_CHAR " << yytext << endl; 
        errorCount++;  
    }

%%
