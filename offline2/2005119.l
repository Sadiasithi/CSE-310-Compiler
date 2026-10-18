%option noyywrap

%{
#include<iostream>
#include<fstream>
#include<string>
#include<stdlib.h>
#include "2005119_symbolTable.cpp"
using namespace std;

ofstream fout;
int lineCount = 1;
int errorCount = 0;
//int warningCount = 0;

string escapeChar(char a) {
	switch(a) {
		case 'a': return "\a";
		case 'n': return "\n";
		case 't': return "\t";
		case '\\': return "\\";
		case '\'': return "\'";
		case '\"': return "\"";
		case 'f': return "\f";
		case 'r': return "\r";
		case 'b': return "\b";
		case 'v': return "\v";
		case '0': return "\0";
		case '\n': return "";
		case '\r': return "";
		default: return "0";
	}
}

string escapeString(string inp) {
    string out ;
    for (int i = 0; i < inp.length(); i++) {
        if (inp[i] == '\\')
            out += escapeChar(inp[++i]);
        else if (inp[i] == '\r' || inp[i] == '\n')
            continue;
        else
            out += inp[i];
    }
    return out;
}

void print(string token, string lexeme, bool attribute = true) {
    fout << "<" << token << ", " << lexeme << ">" << endl;
    cout << "Line# " << lineCount << ": Token <" << token << "> Lexeme " << lexeme << " found" << endl;
}

void printChar(string token, string lexeme) {
    string ch;
    (lexeme.length() == 4) ? ch = escapeChar(lexeme[2]) : ch = lexeme[1];
    fout  << "<" << token << ", " << ch <<  ">" << endl;
    cout << "Line# " << lineCount << ": Token <" << token << "> Lexeme " << ch <<
        " found" << endl;
}


void printString(string token, string lexeme) {
    bool isSingleLine = (lexeme.find('\n') == string::npos);
    string escapedString = escapeString(lexeme);

	 if (isSingleLine) {
        cout << "Line# " << lineCount << ": Token <SINGLE LINE STRING> Lexeme " << lexeme << " found" << endl;
    } else {
        cout << "Line# " << lineCount << ": Token <MULTI LINE STRING> Lexeme " << lexeme << " found" << endl;
    }

    if (escapedString.front() == '"' && escapedString.back() == '"') {
        escapedString = escapedString.substr(1, escapedString.length() - 2);
    }

    if (isSingleLine) {
        fout << "<SINGLE LINE STRING, " << escapedString << ">" << endl;
    } else {
        fout << "<MULTI LINE STRING, " << escapedString << ">" << endl;
    }
}


void checkNewLine(string abc) {
	for (int i=0; abc[i] != '\0'; i++)
		if (abc[i] == '\n') lineCount++;
}

void printComment(string token, string lexeme) {
	bool isSingleLine = (lexeme.find('\n') == string::npos);
    string escapedString = escapeString(lexeme);

	 if (isSingleLine) {
        cout << "Line# " << lineCount << ": Token <SINGLE LINE COMMENT> Lexeme " << lexeme << " found" << endl;
    } else {
        cout << "Line# " << lineCount << ": Token <MULTI LINE COMMENT> Lexeme " << lexeme << " found" << endl;
    }

}


void printError(string errorType, string lexeme) {
	if (errorType == "DECIMAL")
		cout << "Error at line# " << lineCount << ": TOO_MANY_DECIMAL_POINTS " << lexeme << endl;

	else if (errorType == "ILL_FORMED")
		cout << "Error at line# " << lineCount << ": ILLFORMED_NUMBER " << lexeme << endl;

	else if (errorType == "INVALID")
		cout << "Error at line# " << lineCount << ": INVALID_ID_SUFFIX_NUM_PREFIX " << lexeme << endl;

	else if (errorType == "MULTI")
		cout << "Error at line# " << lineCount << ": MULTICHAR_CONST_CHAR " << lexeme << endl;

	else if (errorType == "UNFINISHED")
		cout << "Error at line# " << lineCount << ": UNFINISHED_CONST_CHAR " << lexeme << endl;

	else if (errorType == "EMPTY")
		cout << "Error at line# " << lineCount << ": EMPTY_CONST_CHAR " << lexeme << endl;

	else if (errorType == "UNFINISHED_CHAR")
		cout << "Error at line# " << lineCount << ": UNFINISHED_CONST_CHAR " << lexeme << endl;

	else if (errorType == "UNFINISHED_STRING") {
      cout << "Error at line# ";
      if (lexeme.find('\\') != string::npos) {
         cout << lineCount + 1 << ": UNFINISHED_STRING " << lexeme << endl;
      } else {
         cout << lineCount << ": UNFINISHED_STRING " << lexeme << endl;
      }
    }

	else if (errorType == "UNFINISHED_COMMENT")
		cout << "Error at line# " << lineCount + 1 << ": UNFINISHED_COMMENT " << lexeme << endl;

	else if (errorType == "UNRECOGNIZED_CHAR")
		cout << "Error at line# " << lineCount << ": UNRECOGNIZED_CHAR " << lexeme << endl;
	
	errorCount++;
}

symbolTable sym (11);
%}


letter [a-zA-Z]
digit [0-9]
escape [nt\\'afrbv0]

%%


[ \t\v]+ {}
(\r)?\n {lineCount++;}

if {print("IF", yytext, false);}
for {print("FOR", yytext, false);}
do {print("DO", yytext, false);}
int {print("INT", yytext, false);}
float {print("FLOAT", yytext, false);}
void {print("VOID", yytext, false);}
switch {print("SWITCH", yytext, false);}
default {print("DEFAULT", yytext, false);}
else {print("ELSE", yytext, false);}
while {print("WHILE", yytext, false);}
break {print("BREAK", yytext, false);}
char {print("CHAR", yytext, false);}
double {print("DOUBLE", yytext, false);}
return {print("RETURN", yytext, false);}
case {print("CASE", yytext, false);}
continue {print("CONTINUE", yytext, false);}

("+"|"-") {print("ADDOP", yytext);}
("*"|"/"|"%") {print("MULOP", yytext);}
("++"|"--") {print("INCOP", yytext);}
("<"|"<="|">"|">="|"=="|"!=") {print("RELOP", yytext);}
"=" {print("ASSIGNOP", yytext);}
("&&"|"||") {print("LOGICOP", yytext);}
("&"|"|"|"^"|"<<"|">>") {print("BITOP", yytext);}
"!" {print("NOT", yytext);}
"(" {print("LPAREN", yytext);}
")" {print("RPAREN", yytext);}
"{" {print("LCURL", yytext); sym.enterScope();}
"}" {print("RCURL", yytext); sym.exitScope();}
"[" {print("LSQUARE", yytext);}
"]" {print("RSQUARE", yytext);}
"," {print("COMMA", yytext);}
";" {print("SEMICOLON", yytext);}

{digit}* {
	print("CONST_INT", yytext);
}
{digit}*(\.{digit}+)?(E[+-]?{digit}+)? {
	print("CONST_FLOAT", yytext);
}
\'[^\\]\' {
	printChar("CONST_CHAR", yytext);
}
\'\\{escape}\' {
	printChar("CONST_CHAR", yytext);
}


 ({letter}|_)({letter}|{digit}|_)* {
    if(sym.lookUp(yytext)) {
		print("ID", yytext);
        cout << "\t" << yytext << " already exists in the current ScopeTable" << endl;
    } else {
        print("ID", yytext);
        sym.insert(yytext, "ID");
    }
}


\".*(\\(\r)?\n.*)*[^\\\r\n]\" {
	printString("STRING", yytext);
	checkNewLine(yytext);
}

\/\/([^\\\n\r]|\\(\r)?\n?)* {
    printComment("COMMENT", yytext);
    checkNewLine(yytext);
}

\/\*([^\*]|\*[^\/]|\\(\r)?\n?)*\*\/ {
    printComment("COMMENT", yytext);
    checkNewLine(yytext);
}


{digit}+\.{digit}+(\.{digit}+)+ {printError("DECIMAL", yytext);}

{digit}*(\.{digit}*)*E[+-]?{digit}*(\.{digit}*)+ {printError("ILL_FORMED", yytext);}
({letter}|{digit})*({letter}+\.|\.{letter}+)({letter}|{digit})* {printError("ILL_FORMED", yytext);}

{digit}({letter}|{digit}|_)* {printError("INVALID", yytext);}
{digit}*(\.{digit}+)?(E[+-]?{digit}+)?{letter}+ {printError("INVALID", yytext);}

\'\' {printError("EMPTY", yytext);}
\'.[^\'\r\n]+\' {printError("MULTI", yytext);}
\'(.|\\\')[^\'\n\r]* {printError("UNFINISHED_CHAR", yytext);}

\"[^\"(\r)?\n]*(\\((\r)?\n|\")[^\"(\r)?\n]*)* {
	printError("UNFINISHED_STRING", yytext);
	checkNewLine(yytext);
}

\/\*([^\*]|\*[^\/])* {
	printError("UNFINISHED_COMMENT", yytext);
	checkNewLine(yytext);
}

. {
	printError("UNRECOGNIZED_CHAR", yytext);
	checkNewLine(yytext);
}


<<EOF>> {
	sym.printAllScope();
	cout << "Total lines: " << lineCount << endl; 
	cout << "Total errors: " << errorCount << endl;
	return 0;
}
%%

int main(int argc,char *argv[]){
	if(argc != 2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin = fopen(argv[1], "r");
	if(fin == NULL){
		printf("Cannot open specified file\n");
		return 0;
	}

	freopen("2005119_log.txt", "w", stdout);
	fout.open("2005119_token.txt");
	yyin = fin;
	yylex();
	
	fclose(yyin);
	return 0;
}
