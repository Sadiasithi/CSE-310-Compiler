%{ 
 
#include<bits/stdc++.h>
#include<stdio.h>
#include<stdlib.h>
#include<fstream>

#include "2005119_symbolTable.cpp"
using namespace std;
 
//void yyerror(string err);
 
symbolTable* symboltable = new symbolTable(11);
int scopeID = 1; 
int bucket = 11;  

struct parameter {
    string paramType; 
    string paramName; 
}param;

struct var {
    string varName; 
    int varSize;
    string isarraytype;
}demoVar;

vector<parameter> paramList; 
vector<var> varList;
vector<string> argList;

string name;
string type;
string dataName;
string dataType;

extern FILE* yyin; 
ofstream logfile;
ofstream errorfile; 
ofstream parsefile;

extern int lineCount; 
extern int errorCount;

int yyparse(void); 
int yylex(void);

void yyerror(string err) {
    errorCount++; 
    errorfile << "Line# " << lineCount << ": " << err << "" << endl;    
}

void printingLog(ofstream &log, string msg) {
    logfile << msg << endl; 
}

void functionValueAdd(string type, string name, bool check, bool check2) { 
	symbolInfo* info = new symbolInfo(name, "FUNCTION"); 
    info->setReturnType(type);  
    info->setIsDeclared(check); 
    info->setIsDefined(check2);
    for(int i = 0; i < paramList.size(); i++) {
        info->addnew(paramList[i].paramName,  paramList[i].paramType); 
    }
    symboltable->insert(*info, logfile); 
}

string uppercaseConvert(string str) {
    for(int i = 0; str[i]; i++)
        str[i] = toupper(str[i]); 
    return str;
}

void varInsert(string type, var noParam) { 
    symbolInfo* info = new symbolInfo(noParam.varName, uppercaseConvert(type)); 
    if(noParam.isarraytype != "ARRAY") {
        info->setReturnType(uppercaseConvert(type)); 
    } 
    else {
        info->setReturnType(uppercaseConvert(noParam.isarraytype));  
    }
    
    info->setSize(noParam.varSize); 
    symboltable->insert(*info, logfile); 
}


void parseLine(symbolInfo* info, symbolInfo* start, symbolInfo* End) {
    info->setStartLine(start->getStartLine()); 
    info->setEndLine(End->getEndLine()); 
} 

void parseChildren(symbolInfo* symbol, vector<symbolInfo*> childrenList) {
    if(symbol->getType() == "PROGRAM") {
        for(symbolInfo* info : childrenList) {
            //cout << info->getParseLine() << endl;
        }
    }
    symbol->addMultipleChild(childrenList); 
    symbol->setleaf(false); 
} 
%}
%union 
{
    symbolInfo* symbol; 
}

%token <symbol> IF ELSE SWITCH FOR WHILE DO INT CHAR FLOAT DOUBLE VOID RETURN PRINTLN CONST_INT CONST_FLOAT CONST_CHAR ERROR_FLOAT ADDOP MULOP RELOP LOGICOP INCOP DECOP ASSIGNOP NOT LPAREN RPAREN LCURL RCURL LTHIRD RTHIRD COMMA SEMICOLON ID 
%type <symbol> start program unit func_declaration func_definition parameter_list compound_statement var_declaration type_specifier non_term_for_func declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments 

%nonassoc LOWER_THAN_ELSE ELSE 
%%
start : program {   
                    $$ = new symbolInfo((string)$1->getName(), "START");
                    printingLog(logfile, "start : program "); 
          
                    $$->setParseString("start : program"); 
                    parseLine($$, $1, $1);   
                    vector<symbolInfo*> childParse; 
                    childParse.push_back($1); 
                    parseChildren($$, childParse); 
                    $$->setSpace(0);  
                    $$->printParseTree(parsefile, 0);                     
                }; 

program : program unit {
                            $$ = new symbolInfo((string)$1->getName() + (string)$2->getName(), "PROGRAM");
                            printingLog(logfile,"program : program unit "); 
                                                
                            $$->setParseString("program : program unit"); 
                            parseLine($$, $1, $2); 
                            vector<symbolInfo*> childParse; 
                            childParse.push_back($1);
                            childParse.push_back($2);
                            parseChildren($$, childParse); 
                        }

                       | unit {
                                    $$ = new symbolInfo((string)$1->getName(), "PROGRAM"); 
                                    printingLog(logfile, "program : unit "); 
                                                
                                    $$->setParseString("program : unit"); 
                                    parseLine($$, $1, $1); 
                                    vector<symbolInfo*> childParse; 
                                    childParse.push_back($1);
                                    parseChildren($$, childParse);   
                                };

unit : var_declaration {
                            $$ = new symbolInfo($1->getName(), "UNIT");
                            printingLog(logfile, "unit : var_declaration  "); 
                                                    
                            $$->setParseString("unit : var_declaration"); 
                            parseLine($$, $1, $1); 
                            vector<symbolInfo*> childParse; 
                            childParse.push_back($1);
                            parseChildren($$, childParse);
                        } 

                        | func_declaration {                       
                                                $$ = new symbolInfo($1->getName(), "UNIT");
                                                printingLog(logfile, "unit : func_declaration "); 
                                                    
                                                $$->setParseString("unit : func_declaration"); 
                                                parseLine($$, $1, $1); 
                                                vector<symbolInfo*> childParse; 
                                                childParse.push_back($1);
                                                parseChildren($$, childParse);
                                            }

                        | func_definition {
                                            $$ = new symbolInfo($1->getName(), "UNIT");
                                            printingLog(logfile, "unit : func_definition  ");
                                                    
                                            $$->setParseString("unit : func_definition"); 
                                            parseLine($$, $1, $1); 
                                            vector<symbolInfo*> childParse; 
                                            childParse.push_back($1);
                                            parseChildren($$, childParse); 
                                        } ;

                 

func_declaration : type_specifier non_term_for_func ADDT LPAREN parameter_list RPAREN ADDT_declare SEMICOLON {               
                                                                                                            $$ = new symbolInfo($1->getName() + "" + $2->getName() + $4->getName() + $5->getName() + $6->getName() + $8->getName(), "FUNC_DECLARATION"); 
                                                                                                            printingLog(logfile, "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON "); 
                                        
                                                                                                            $$->setParseString("func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON"); 
                                                                                                            parseLine($$, $1, $8); 
                                                                                                            vector<symbolInfo*> childParse; 
                                                                                                            childParse.push_back($1);
                                                                                                            childParse.push_back($2);
                                                                                                            childParse.push_back($4);
                                                                                                            childParse.push_back($5);
                                                                                                            childParse.push_back($6);
                                                                                                            childParse.push_back($8);
                                                                                                            parseChildren($$, childParse); 
                                                                                                            paramList.clear(); 
                                                                                                        }

                                                                                                        | type_specifier non_term_for_func ADDT LPAREN RPAREN ADDT_declare SEMICOLON {
                                                                                                                                                                                    $$ = new symbolInfo($1->getName() + "" + $2->getName() + $4->getName() + $5->getName() + $7->getName(), "FUNC_DECLARATION"); 
                                                                                                                                                                                    printingLog(logfile, "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON "); 

                                                                                                                                                                                    $$->setParseString("func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON"); 
                                                                                                                                                                                    parseLine($$, $1, $7); 
                                                                                                                                                                                    vector<symbolInfo*> childParse; 
                                                                                                                                                                                    childParse.push_back($1);
                                                                                                                                                                                    childParse.push_back($2);
                                                                                                                                                                                    childParse.push_back($4);
                                                                                                                                                                                    childParse.push_back($5);
                                                                                                                                                                                    childParse.push_back($7);
                                                                                                                                                                                    parseChildren($$, childParse);
                                                                                                                                                                                    paramList.clear(); 
                                                                                                                                                                                }; 

func_definition : type_specifier non_term_for_func ADDT LPAREN parameter_list RPAREN ADDT_definition compound_statement { 
                                                                                                                    $$ = new symbolInfo($1->getName() + "" + $2->getName() + $4->getName() + $5->getName() + $6->getName() + $8->getName(), "FUNC_DEFINITION"); 
                                                                                                                    printingLog(logfile, "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement ");    

                                                                                                                    $$->setParseString("func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement"); 
                                                                                                                    parseLine($$, $1, $8); 
                                                                                                                    vector<symbolInfo*> childParse; 
                                                                                                                    childParse.push_back($1);
                                                                                                                    childParse.push_back($2);
                                                                                                                    childParse.push_back($4);
                                                                                                                    childParse.push_back($5);
                                                                                                                    childParse.push_back($6);
                                                                                                                    childParse.push_back($8);
                                                                                                                    parseChildren($$, childParse);
                                                                                                                }  

                                                                                                                | type_specifier non_term_for_func ADDT LPAREN RPAREN ADDT_definition compound_statement {
                                                                                                                                                                                                        $$ = new symbolInfo($1->getName() + "" + $2->getName() + $4->getName() + $5->getName() + $7->getName(), "FUNC_DEFINITION");  
                                                                                                                                                                                                        printingLog(logfile, "func_definition : type_specifier ID LPAREN RPAREN compound_statement");    
                                                                                                                                                                                                        $$->setParseString("func_definition : type_specifier ID LPAREN RPAREN compound_statement");
                                                                                                                                                                                                        parseLine($$, $1, $7); 
                                                                                                                                                                                                        vector<symbolInfo*> childParse; 
                                                                                                                                                                                                        childParse.push_back($1);
                                                                                                                                                                                                        childParse.push_back($2);
                                                                                                                                                                                                        childParse.push_back($4);
                                                                                                                                                                                                        childParse.push_back($5);
                                                                                                                                                                                                        childParse.push_back($7);
                                                                                                                                                                                                        parseChildren($$, childParse);



                                                                                                                                                                                                   };
ADDT : {
    dataType = type; 
    dataName = name;
};

ADDT_declare : {  
    symbolInfo* symbol = symboltable->lookUp(dataName, logfile); 

    if(symbol  ==  NULL) {
        functionValueAdd(dataType, dataName, true, false);  
    }
    else { 
       if(symbol->isFunction()) {
           string err = "Multiple Declaration of function " + dataName;
           yyerror(err); 
       }
       else {
           string err = "'" + dataName + "' redeclared as different kind of symbol";
           yyerror(err);
       }
    }
}; 

ADDT_definition : { 
    symbolInfo* info = symboltable->lookUp(dataName, logfile); 
    
    if(info  ==  NULL) { 
        functionValueAdd(dataType, dataName, false, true); 
    }

    else if(info->isFunction()) { 
        if(info->isDeclared() && !info->isDefined()) {  
            if(info->getReturnType()  ==  dataType) {
                if(info->getParamCount()  ==  paramList.size()) {   
                    if(info->getParamCount()  ==  0)
                         functionValueAdd(dataType, dataName, true, true); 
                    else { 
                        int error = 0; 
                        for(int i = 0; i < paramList.size(); i++) {
                            if( (info->getParam(i)).parameterReturnType != paramList[i].paramType) {
                                error = 1;   
                            }
                        } 
                        if(error) {
                            string err = "Conflicting types for '" + dataName + "'";
                            yyerror(err); 
                        }
                        else 
                            functionValueAdd(dataType, dataName, true, true); 
                    }
                    
                }
                else {       
                    string err = "Conflicting types for '" + dataName + "'";
                    yyerror(err); 
                }
            }
            else { 
                string err = "Conflicting types for '" + dataName + "'"; 
                yyerror(err); 
            }

        }

        else if(info->isDefined()) {
            string err = "Redifinition of function '" + dataName + "'"; 
            yyerror(err); 
        }       
    }

    else {
        string err = "'" + dataName + "' redeclared as different kind of symbol";
        yyerror(err);
    } 
};

parameter_list : parameter_list COMMA type_specifier ID { 
                                                           $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName() + $4->getName(), "parameter_list"); 
                                                           printingLog(logfile, "parameter_list  : parameter_list COMMA type_specifier ID");

                                                           for(int i = 0; i < paramList.size(); i++) {
                                                                if(paramList[i].paramName  ==  $4->getName()) {
                                                                    string err = "Redefinition of parameter '" + $4->getName() + "'"; 
                                                                    yyerror(err); 
                                                                }
                                                            } 
                                                            param.paramType = $3->getType();  
                                                            param.paramName = $4->getName(); 
                                                            paramList.push_back(param); 
                         
                                                            $$->setParseString("parameter_list : parameter_list COMMA type_specifier ID");
                                                            parseLine($$, $1, $4); 
                                                            vector<symbolInfo*> childParse; 
                                                            childParse.push_back($1);
                                                            childParse.push_back($2);
                                                            childParse.push_back($3);
                                                            childParse.push_back($4);
                                                            parseChildren($$, childParse);
                        
                                                        }
                                                        | parameter_list COMMA type_specifier { 
                                                                                                    $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName(), "parameter_list"); 
                                                                                                    printingLog(logfile, "parameter_list  : parameter_list COMMA type_specifier ");    
                                                                                                    param.paramType = $3->getType();
                                                                                                    param.paramName ="";
                                                                                                    paramList.push_back(param); 

                                                                                                    $$->setParseString("parameter_list : parameter_list COMMA type_specifier ");                      
                                                                                                    parseLine($$, $1, $3); 
                                                                                                    vector<symbolInfo*> childParse; 
                                                                                                    childParse.push_back($1);
                                                                                                    childParse.push_back($2);
                                                                                                    childParse.push_back($3);
                                                                                                    parseChildren($$, childParse);
                                                                                                }
                                                        | type_specifier ID {
                                                                                $$ = new symbolInfo($1->getName()+""+$2->getName(), "PARAMATER_LIST"); 
                                                                                printingLog(logfile, "parameter_list  : type_specifier ID"); 
                                                                                param.paramType = $1->getType();  
                                                                                param.paramName = $2->getName();
                                                                                paramList.push_back(param); 
   
                                                                                $$->setParseString("parameter_list : type_specifier ID");                      
                                                                                parseLine($$, $1, $2); 
                                                                                vector<symbolInfo*> childParse; 
                                                                                childParse.push_back($1);
                                                                                childParse.push_back($2);
                                                                                parseChildren($$, childParse);
                                                                            }
                                                        | type_specifier {
                                                                                $$ = new symbolInfo($1->getName(), "PARAMATER_LIST"); 
                                                                                printingLog(logfile, "parameter_list : type_specifier ");    
                                                                                param.paramType = $1->getType(); 
                                                                                param.paramName = ""; 
                                                                                paramList.push_back(param);
          
                                                                                $$->setParseString("parameter_list : type_specifier");                
                                                                                parseLine($$, $1, $1); 
                                                                                vector<symbolInfo*> childParse; 
                                                                                childParse.push_back($1);
                                                                                parseChildren($$, childParse);
                                                                        }; 
    
compound_statement : LCURL add_param statements RCURL {   
                                                                            $$ = new symbolInfo(($1->getName() + (string)$3->getName() + $4->getName()), "COMPOUND_STATEMENT"); 
                                                                            printingLog(logfile, "compound_statement : LCURL statements RCURL  ");   
                                                                            symboltable->printAllScope(logfile); 
                                                                            symboltable->exitScope(logfile); 
    
                                                                            $$->setParseString("compound_statement : LCURL statements RCURL");                    
                                                                            parseLine($$, $1, $4);
                                                                            vector<symbolInfo*> childParse;
                                                                            childParse.push_back($1); 
                                                                            childParse.push_back($3);
                                                                            childParse.push_back($4);
                                                                            parseChildren($$, childParse);
                                                                        }

                        | LCURL add_param RCURL {
                                                                        $$ = new symbolInfo(($1->getName() + (string)$3->getName()), "COMPOUND_STATEMENT");
                                                                        printingLog(logfile, "compound_statement : LCURL  RCURL ");   
                                                                        symboltable->printAllScope(logfile);
                                                                        symboltable->exitScope(logfile);                                                                        
                                                                        $$->setParseString("compound_statement : LCURL  RCURL");                     
                                                                        parseLine($$, $1, $3); 
                                                                        vector<symbolInfo*> childParse; 
                                                                        childParse.push_back($1);
                                                                        childParse.push_back($3);
                                                                        parseChildren($$, childParse);
                                                                    }; 

add_param: {
    scopeID++;
    symboltable->enterScope(scopeID, bucket); 
     
    if(paramList.size() == 1 && paramList[0].paramType  ==  "void"){}
    else {
        for(int i = 0; i < paramList.size(); i++) {       
            demoVar.varName = paramList[i].paramName; 
            demoVar.varSize = -1; 
            varInsert(paramList[i].paramType, demoVar );
        }
    }
    paramList.clear();
}

var_declaration : type_specifier declaration_list SEMICOLON {
                                                                $$ = new symbolInfo($1->getName() +"" + $2->getName() + $3->getName(),"VAR_DECLARATION");
                                                                printingLog(logfile, "var_declaration : type_specifier declaration_list SEMICOLON  ");  
                         
                                                                if($1->getName() == "void") { 
                                                                    string err = "Variable or field '"+$2->getName()+"' declared void";
                                                                    yyerror(err);  
                                                                    string sname ="FLOAT"; 
                                                                    for(int i =0; i<varList.size(); i++)
                                                                        varInsert(sname,  varList[i]); 
                                                                }
                                                                 else { 
                                                                    string sname = $1->getName(); 
                                                                    for(int i = 0; i < varList.size(); i++)
                                                                        varInsert(sname, varList[i]); 
                                                                }
                                                                varList.clear(); 
    
                                                                $$->setParseString("var_declaration : type_specifier declaration_list SEMICOLON");                 
                                                                parseLine($$, $1, $3); 
                                                                vector<symbolInfo*> childParse; 
                                                                childParse.push_back($1);
                                                                childParse.push_back($2);
                                                                childParse.push_back($3);
                                                                parseChildren($$, childParse);
                                                            };  




type_specifier :  INT {
                            type ="INT"; 
                            $$ = new symbolInfo($1->getName(), $1->getType()); 
                            printingLog(logfile,"type_specifier	: INT ");  
                 
                            $$->setParseString("type_specifier : INT");                 
                            parseLine($$, $1, $1); 
                            vector<symbolInfo*> childParse; 
                            childParse.push_back($1);
                            parseChildren($$, childParse);
                        } 

                | FLOAT {
                            type ="FLOAT";
                            $$ = new symbolInfo($1->getName(), $1->getType());
                            printingLog(logfile, "type_specifier	: FLOAT "); 
                    
                            $$->setParseString("type_specifier : FLOAT");                 
                            parseLine($$, $1, $1); 
                            vector<symbolInfo*> childParse; 
                            childParse.push_back($1);
                            parseChildren($$, childParse);
                }

                | VOID {
                            type ="VOID";  
                            $$ = new symbolInfo($1->getName(), $1->getType());
                            printingLog(logfile, "type_specifier	: VOID"); 
                            $$->setParseString("type_specifier : VOID");                 
                            parseLine($$, $1, $1); 
                            vector<symbolInfo*> childParse; 
                            childParse.push_back($1);
                            parseChildren($$, childParse);
                        }; 

non_term_for_func : ID {
                            $$ = new symbolInfo($1->getName(), $1->getType());
                            name = $1->getName(); 
                            string err = "ID : " + name; 
                            $$->setParseString(err); 
                            parseLine($$, $1, $1);  
                            $$->setleaf(true);
                        } 

declaration_list : declaration_list COMMA ID {
                                                    $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName(), "DECLARATION_LIST");
                                                    printingLog(logfile, "declaration_list : declaration_list COMMA ID  "); 
                         
                                                    $$->setParseString("declaration_list : declaration_list COMMA ID");   
                                                    parseLine($$, $1, $3); 
                                                    vector<symbolInfo*> childParse; 
                                                    childParse.push_back($1);
                                                    childParse.push_back($2);
                                                    childParse.push_back($3);
                                                    parseChildren($$, childParse);
                         
                                                    demoVar.varName = $3->getName(); 
                                                    demoVar.varSize = -1;  
                                                    varList.push_back(demoVar);                      
                        
                                                    symbolInfo* symbol = symboltable->lookUp($3->getName(), logfile);
                                                    if(symbol != NULL) {
                                                        if(symboltable->getscopeID(symbol->getName(), logfile) == symboltable->currScopeID()) {
                                                            string err = "Conflicting types for'" + $3->getName() + "'"; 
                                                            yyerror(err);
                                                        }
                                                    }
                                                    else {  
                                                    }

                                                    for(int i = 0; i < varList.size() -1; i++) {
                                                        if($3->getName() == varList[i].varName) { 
                                                                string err = "Redefination of variable name '" + $3->getName() + "'"; 
                                                                yyerror(err);
                                                        }
                                                    }                        
                                                }

                                                | declaration_list COMMA ID LTHIRD CONST_INT RTHIRD {                         
                                                                                                        $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName() + $4->getName() + $5->getName() + $6->getName(), "DECLARATION_LIST");
                                                                                                        printingLog(logfile, "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE "); 
                
                                                                                                        demoVar.varName = $3->getName(); 
                                                                                                        demoVar.isarraytype = "ARRAY";
                                                                                                        string len = $5->getName(); 
                                                                                                        demoVar.varSize = stoi(len); 
                                                                                                        varList.push_back(demoVar); 

                                                                                                        demoVar.isarraytype = "";  
                                                                                                        symbolInfo* symbol = symboltable->lookUp($3->getName(), logfile);
                                                                                                        if(symbol != NULL) {
                                                                                                            if(symboltable->getscopeID(symbol->getName(), logfile)  ==  symboltable->currScopeID()) {
                                                                                                                string err = "Conflicting types for'" + $3->getName() + "'"; 
                                                                                                                yyerror(err);
                                                                                                            }
                                                                                                        }
                                                                                                        else {
                                                                                                        }
                       
                                                                                                        for(int i = 0; i < varList.size() - 1; i++) { 
                                                                                                            if($3->getName() == varList[i].varName) { 
                                                                                                                string err = "Redefination of variable name '" + $3->getName() + "'"; 
                                                                                                                yyerror(err);
                                                                                                            }
                                                                                                        }

                                                                                                        $$->setParseString("declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE");   
                                                                                                        parseLine($$, $1, $6); 
                                                                                                        vector<symbolInfo*> childParse; 
                                                                                                        childParse.push_back($1);
                                                                                                        childParse.push_back($2);
                                                                                                        childParse.push_back($3);
                                                                                                        childParse.push_back($4);
                                                                                                        childParse.push_back($5);
                                                                                                        childParse.push_back($6);
                                                                                                        parseChildren($$, childParse);
                                                                                                    }
                                                | ID {
                                                            $$ = new symbolInfo($1->getName(), "DECLARATION_LIST");
                                                            printingLog(logfile, "declaration_list : ID "); 
                    
                                                            demoVar.varName = $1->getName(); 
                                                            demoVar.varSize = -1; 
                                                            varList.push_back(demoVar); 

                                                            symbolInfo* symbol = symboltable->lookUp($1->getName(), logfile);
                                                            if(symbol != NULL) {
                                                                if(symboltable->getscopeID(symbol->getName(), logfile)  ==  symboltable->currScopeID()) {
                                                                    string err = "Conflicting types for'"+$1->getName()+"'"; 
                                                                    yyerror(err);
                                                                }
                                                            }
 
                                                            for(int i = 0; i < varList.size() - 1; i++) {
                                                                if($1->getName() == varList[i].varName) {
                                                                    string err = "Redefination of variable name '"+$1->getName()+"'";  
                                                                    yyerror(err);
                                                                }
                                                            }

                                                            $$->setParseString("declaration_list : ID");   
                                                            parseLine($$, $1, $1); 
                                                            vector<symbolInfo*> childParse; 
                                                            childParse.push_back($1);
                                                            parseChildren($$, childParse);
                                                        }

                                                | ID LTHIRD CONST_INT RTHIRD {                           
                                                                                    $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName() + $4->getName(), "DECLARATION_LIST");
                                                                                    printingLog(logfile, "declaration_list : ID LSQUARE CONST_INT RSQUARE "); 
                       
                                                                                    demoVar.varName = $1->getName(); 
                                                                                    demoVar.isarraytype = "ARRAY";
                                                                                    string len = $3->getName(); 
                                                                                    demoVar.varSize = stoi(len);  
                                                                                    varList.push_back(demoVar); 
                                                                                    demoVar.isarraytype = "";
                                                                                    symbolInfo* symbol = symboltable->lookUp($1->getName(), logfile);
                                                                                    if(symbol != NULL) {
                                                                                        if(symboltable->getscopeID(symbol->getName(), logfile) == symboltable->currScopeID()) {
                                                                                            string err = "Conflicting types for'" + $1->getName() + "'"; 
                                                                                            yyerror(err);
                                                                                        }
                                                                                    }

                                                                                    for(int i = 0; i < varList.size() - 1; i++) {
                                                                                        if($1->getName() == varList[i].varName) { 
                                                                                            string err = "Redefination of variable name '" + $1->getName() + "'";  
                                                                                            yyerror(err);
                                                                                       }
                                                                                    }

                                                                                    $$->setParseString("declaration_list : ID LSQUARE CONST_INT RSQUARE");   
                                                                                    parseLine($$, $1, $4); 
                                                                                    vector<symbolInfo*> childParse; 
                                                                                    childParse.push_back($1);
                                                                                    childParse.push_back($2);
                                                                                    childParse.push_back($3);
                                                                                    childParse.push_back($4);
                                                                                    parseChildren($$, childParse);
                                                                                }; 
statements : statement {
                            $$ = new symbolInfo($1->getName(),"STATEMENT");
                            printingLog(logfile, "statements : statement  "); 

                            $$->setParseString("statements : statement");
                            parseLine($$, $1, $1); 
                            vector<symbolInfo*> childParse; 
                            childParse.push_back($1);
                            parseChildren($$,  childParse);
                       }

                        | statements statement { 
                                                    $$ = new symbolInfo($1->getName()+$2->getName(),"STATEMENTS");
                                                    printingLog(logfile, "statements : statements statement  "); 

                                                    $$->setParseString("statements : statements statement");
                                                    parseLine($$, $1, $2); 
                                                    vector<symbolInfo*> childParse; 
                                                    childParse.push_back($1);
                                                    childParse.push_back($2);
                                                    parseChildren($$, childParse);
                                                }

statement : var_declaration {  
                                $$ = new symbolInfo($1->getName(), "STATEMENT");
                                printingLog(logfile, "statement : var_declaration "); 
                        
                                $$->setParseString("statement : var_declaration");
                                parseLine($$, $1, $1); 
                                vector<symbolInfo*> childParse; 
                                childParse.push_back($1);
                                parseChildren($$, childParse);
                            }

                            | expression_statement { 
                                                        $$ = new symbolInfo($1->getName(),"STATEMENT");
                                                        printingLog(logfile, "statement : expression_statement  "); 

                                                        $$->setParseString("statement : expression_statement");
                                                        parseLine($$, $1, $1); 
                                                        vector<symbolInfo*> childParse; 
                                                        childParse.push_back($1);
                                                        parseChildren($$, childParse);
                                                    } 

                            | compound_statement { 
                                                    $$ = new symbolInfo($1->getName(),"STATEMENT");
                                                    printingLog(logfile, "statement : compound_statement "); 

                                                    $$->setParseString("statement : compound_statement");
                                                    parseLine($$, $1, $1); 
                                                    vector<symbolInfo*> childParse; 
                                                    childParse.push_back($1);
                                                    parseChildren($$,  childParse);
                                                }

                            | FOR LPAREN expression_statement ADDT_EXP ADDT_VOID expression_statement ADDT_EXP ADDT_VOID expression ADDT_EXP ADDT_VOID RPAREN statement {
                                                                                                                                                                            $$ = new symbolInfo($1->getName()+$2->getName()+$3->getName()+$6->getName()+$9->getName()+$12->getName()+$13->getName(), "FOR_LOOP"); 
                                                                                                                                                                            printingLog(logfile, "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement");  
                                                                                                                                                                            
                                                                                                                                                                            $$->setParseString("statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement");
                                                                                                                                                                            parseLine($$, $1, $13); 
                                                                                                                                                                            vector<symbolInfo*> childParse; 
                                                                                                                                                                            childParse.push_back($1);
                                                                                                                                                                            childParse.push_back($2);
                                                                                                                                                                            childParse.push_back($3);
                                                                                                                                                                            childParse.push_back($6);
                                                                                                                                                                            childParse.push_back($9);
                                                                                                                                                                            childParse.push_back($12);
                                                                                                                                                                            childParse.push_back($13);
                                                                                                                                                                            parseChildren($$, childParse);  
                                                                                                                                                                        }

                            | IF LPAREN expression ADDT_EXP RPAREN ADDT_VOID statement %prec LOWER_THAN_ELSE { 
                                                                                                                $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName() + $5->getName() + $7->getName(), "IF"); 
                                                                                                                printingLog(logfile, "statement : IF LPAREN expression RPAREN statement %prec THEN");     
                            
                                                                                                                $$->setParseString("statement : IF LPAREN expression RPAREN statement");
                                                                                                                parseLine($$, $1, $7); 
                                                                                                                vector<symbolInfo*> childParse; 
                                                                                                                childParse.push_back($1);
                                                                                                                childParse.push_back($2);
                                                                                                                childParse.push_back($3);
                                                                                                                childParse.push_back($5);
                                                                                                                childParse.push_back($7);
                                                                                                                parseChildren($$, childParse);  
                                                                                                            }

                            | IF LPAREN expression ADDT_EXP RPAREN ADDT_VOID statement ELSE statement { 
                                                                                                            $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName() + $5->getName() + $7->getName() + $8->getName() + $9->getName(), "IF_ELSE"); 
                                                                                                            printingLog(logfile, "statement : IF LPAREN expression RPAREN statement ELSE statement ");   

                                                                                                            $$->setParseString("statement : IF LPAREN expression RPAREN statement ELSE statement");
                                                                                                            parseLine($$, $1, $9); 
                                                                                                            vector<symbolInfo*> childParse; 
                                                                                                            childParse.push_back($1);
                                                                                                            childParse.push_back($2);
                                                                                                            childParse.push_back($3);
                                                                                                            childParse.push_back($5);
                                                                                                            childParse.push_back($7);
                                                                                                            childParse.push_back($8);
                                                                                                            childParse.push_back($9);
                                                                                                            parseChildren($$, childParse); 
                                                                                                        }

                            | WHILE LPAREN expression ADDT_EXP RPAREN  ADDT_VOID statement {
                                                                                                $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName() + $5->getName() + $7->getName(), "WHILE_LOOP"); 
                                                                                                printingLog(logfile, "statement : WHILE LPAREN expression RPAREN statement");   

                                                                                                $$->setParseString("statement : WHILE LPAREN expression RPAREN statement");
                                                                                                parseLine($$, $1, $7); 
                                                                                                vector<symbolInfo*> childParse; 
                                                                                                childParse.push_back($1);
                                                                                                childParse.push_back($2);
                                                                                                childParse.push_back($3);
                                                                                                childParse.push_back($5);
                                                                                                childParse.push_back($7);
                                                                                                parseChildren($$, childParse); 
                                                                                            }
                            | PRINTLN LPAREN ID RPAREN SEMICOLON {
                                                                    $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName() + $4->getName() + $5->getName() + "\n", "PRINT"); 
                                                                    printingLog(logfile, "statement : PRINTLN LPAREN ID RPAREN SEMICOLON ");  

                                                                    $$->setParseString("statement : PRINTLN LPAREN ID RPAREN SEMICOLON");
                                                                    parseLine($$, $1, $5); 
                                                                    vector<symbolInfo*> childParse; 
                                                                    childParse.push_back($1);
                                                                    childParse.push_back($2);
                                                                    childParse.push_back($3);
                                                                    childParse.push_back($4);
                                                                    childParse.push_back($5);
                                                                    parseChildren($$, childParse);
                                                                }

                            | RETURN expression SEMICOLON {
                                                                $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName()+"\n", "RETURN"); 
                                                                printingLog(logfile, "statement : RETURN expression SEMICOLON"); 

                                                                $$->setParseString("statement : RETURN expression SEMICOLON");
                                                                parseLine($$, $1, $3); 
                                                                vector<symbolInfo*> childParse; 
                                                                childParse.push_back($1);
                                                                childParse.push_back($2);
                                                                childParse.push_back($3);
                                                                parseChildren($$, childParse); 
                                                                if($2->getType() == "VOID") {
                                                                    string err = "Void cannot be used in expression ";
                                                                    yyerror(err); 
                                                                }   
                                                            };
ADDT_EXP : { 
    dataType = type;  
           }

ADDT_VOID : { 
    if(dataType == "VOID") {
        string err = "Void cannot be used in expression ";
        yyerror(err); 
    }
}

expression_statement : SEMICOLON {
                                    $$ = new symbolInfo($1->getName(), $1->getType()); 
                                    printingLog(logfile, "	expression_statement : SEMICOLON		");    
                           
                                    $$->setReturnType($1->getReturnType());
                                    type = $1->getReturnType(); 

                                    $$->setParseString("expression_statement : SEMICOLON");
                                    parseLine($$, $1, $1); 
                                    vector<symbolInfo*> childParse; 
                                    childParse.push_back($1);
                                    parseChildren($$, childParse);  
                                }

                                | expression SEMICOLON {
                                                            $$ = new symbolInfo($1->getName() + $2->getName(), "EXPRESSION_STATEMENT"); 
                                                            printingLog(logfile, "expression_statement : expression SEMICOLON 		 ");    
                                                            $$->setType($1->getType()); 
                                                            type = $1->getType(); 

                                                            $$->setParseString("expression_statement : expression SEMICOLON");
                                                            parseLine($$, $1, $2); 
                                                            vector<symbolInfo*> childParse; 
                                                            childParse.push_back($1);
                                                            childParse.push_back($2);
                                                            parseChildren($$, childParse);
                                                        }; 

variable : ID  {
                    name = $1->getName(); 
                    $$ = new symbolInfo($1->getName(), "ID");
                    printingLog(logfile, "variable : ID 	 "); 

                    $$->setParseString("variable : ID");
                    parseLine($$, $1, $1); 
                    vector<symbolInfo*> childParse; 
                    childParse.push_back($1);
                    parseChildren($$, childParse);

                    symbolInfo* symbol = symboltable->lookUp($1->getName(), logfile); 
                    if(symbol == NULL) {
                        string err  = "Undeclared variable '" + $1->getName() + "'"; 
                        yyerror(err); 
                        $$->setReturnType("FLOAT"); 
                    }
                    else {
                        if(symbol->getReturnType() != "VOID") 
                            $$->setReturnType(symbol->getReturnType());
                        else 
                            $$->setReturnType("FLOAT");  
                    }
                }

                | ID LTHIRD expression RTHIRD {
                                                    $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName() + $4->getName(), "ARRAY");
                                                    printingLog(logfile, "variable : ID LSQUARE expression RSQUARE  	 ");
                
                                                    symbolInfo* symbol = symboltable->lookUp($1->getName(), logfile);
                                                    if(symbol == NULL) {
                                                        string err  = "Undeclared variable '" + $1->getName() + "'"; 
                                                        yyerror(err); 
                                                        $$->setReturnType("FLOAT");
                                                    }
                                                    else {
                                                        if(symbol->isArray()) {
                                                            if(symbol->getReturnType() != "VOID") 
                                                                $$->setReturnType(symbol->getReturnType());
                                                            else  
                                                                $$->setReturnType("FLOAT"); 
                                                        }
                                                        else {
                                                            string err  = "'" + $1->getName() + "' is not an array"; 
                                                            yyerror(err);   
                                                        } 
                                                    }
 
                                                    if($3->getReturnType() != "INT" || $3->getReturnType() != "INT") {
                                                        string err  = "Array subscript is not an integer";  
                                                        yyerror(err);  
                                                    }
            
                                                    $$->setParseString("variable : ID LSQUARE expression RSQUARE");
                                                    parseLine($$, $1, $4); 
                                                    vector<symbolInfo*> childParse; 
                                                    childParse.push_back($1);
                                                    childParse.push_back($2);
                                                    childParse.push_back($3);
                                                    childParse.push_back($4);
                                                    parseChildren($$, childParse);
                                                };

expression : logic_expression {            
                                    $$ = new symbolInfo($1->getName(), "EXPRESSION");
                                    printingLog(logfile, "expression 	: logic_expression	 "); 
                                    $$->setReturnType($1->getReturnType());
                                    type = $1->getReturnType(); 

                                    $$->setParseString("expression : logic_expression");  
                                    parseLine($$, $1, $1); 
                                    vector<symbolInfo*> childParse; 
                                    childParse.push_back($1);
                                    parseChildren($$, childParse);
                                }

                                | variable ASSIGNOP logic_expression {
                                                                        $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName(), $3->getType());
                                                                        printingLog(logfile, "expression 	: variable ASSIGNOP logic_expression 		 "); 

                                                                        if($1->getReturnType() == "INT" && $3->getReturnType() == "CONST_FLOAT") {
                                                                            string err = " Warning: possible loss of data in assignment of "+ $3->getReturnType() + " to " + $1->getReturnType();
                                                                            yyerror(err) ;
                                                                        }
                                                                        if($3->getReturnType() == "VOID") {
                                                                            string err = "Void cannot be used in expression ";
                                                                            yyerror(err);
                                                                            $3->setReturnType("FLOAT"); 
                                                                        }

                                                                        $$->setParseString("expression : variable ASSIGNOP logic_expression");  
                                                                        parseLine($$, $1, $3); 
                                                                        vector<symbolInfo*> childParse; 
                                                                        childParse.push_back($1);
                                                                        childParse.push_back($2);
                                                                        childParse.push_back($3);
                                                                        parseChildren($$, childParse);
                                                                        $$->setReturnType($1->getReturnType()); 
                                                                        type = $1->getReturnType();             
                                                                    }; 
logic_expression : rel_expression {
                                        $$ = new symbolInfo($1->getName(), "");
                                        printingLog(logfile, "logic_expression : rel_expression 	 "); 
                                        $$->setReturnType($1->getReturnType()); 

                                        $$->setParseString("logic_expression : rel_expression");  
                                        parseLine($$, $1, $1); 
                                        vector<symbolInfo*> childParse; 
                                        childParse.push_back($1);
                                        parseChildren($$, childParse);
            
                                    }

                                    | rel_expression LOGICOP rel_expression {
                                                                                $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName(), ""); 
                                                                                printingLog(logfile, "logic_expression : rel_expression LOGICOP rel_expression 	 	 ");  
                                                                                $$->setReturnType($1->getType()); 

                                                                                if($1->getReturnType() == "VOID") {
                                                                                    string err = "Void cannot be used in expression ";
                                                                                    yyerror(err);
                                                                                    $1->setReturnType("FLOAT"); 
                                                                                }
                                                                                if($3->getReturnType()  ==  "VOID") {
                                                                                    string err = "Void cannot be used in expression ";
                                                                                    yyerror(err);
                                                                                    $1->setReturnType("FLOAT"); 
                                                                                }
               
                                                                                $$->setParseString("logic_expression : rel_expression LOGICOP rel_expression"); 
                                                                                parseLine($$, $1, $3); 
                                                                                vector<symbolInfo*> childParse; 
                                                                                childParse.push_back($1);
                                                                                childParse.push_back($2);
                                                                                childParse.push_back($3);
                                                                                parseChildren($$, childParse);
                                                                            }; 

rel_expression : simple_expression {             
                                        $$ = new symbolInfo($1->getName(), "REL_EXPRESSION");
                                        printingLog(logfile, "rel_expression	: simple_expression "); 
                                        $$->setReturnType($1->getReturnType()); 

                                        $$->setParseString("rel_expression : simple_expression");
                                        parseLine($$, $1, $1); 
                                        vector<symbolInfo*> childParse; 
                                        childParse.push_back($1);
                                        parseChildren($$, childParse);
                                    }

                                    | simple_expression RELOP simple_expression {
                                                                                    $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName(), "REL_EXPRESSION"); 
                                                                                    printingLog(logfile, "rel_expression	: simple_expression RELOP simple_expression	  ");   
                                                                                    $$->setReturnType($1->getReturnType()); 
                                                                                    if($1->getReturnType() == "VOID") {
                                                                                        string err = "Void cannot be used in expression ";
                                                                                        yyerror(err);
                                                                                        $1->setReturnType("FLOAT"); 
                                                                                    }
                                                                                    if($3->getReturnType() == "VOID") {
                                                                                        string err = "Void cannot be used in expression ";
                                                                                        yyerror(err);
                                                                                        $1->setReturnType("FLOAT"); 
                                                                                    }
              
                                                                                    $$->setParseString("rel_expression : simple_expression RELOP simple_expression");
                                                                                    parseLine($$, $1, $3); 
                                                                                    vector<symbolInfo*> childParse; 
                                                                                    childParse.push_back($1);
                                                                                    childParse.push_back($2);
                                                                                    childParse.push_back($3);
                                                                                    parseChildren($$, childParse);
                                                                                }; 
 
simple_expression : term  {
                                $$ = new symbolInfo($1->getName(), "SIMPLE_EXPRESSION");
                                printingLog(logfile, "simple_expression : term ");  
                                $$->setReturnType($1->getReturnType()); 

                                $$->setParseString("simple_expression : term");
                                parseLine($$, $1, $1); 
                                vector<symbolInfo*> childParse; 
                                childParse.push_back($1);
                                parseChildren($$, childParse);
                            }

                            | simple_expression ADDOP term {
                                                                $$ = new symbolInfo($1->getName()+$2->getName()+$3->getName(),  "SIMPLE_EXPRESSION"); 
                                                                printingLog(logfile, "simple_expression : simple_expression ADDOP term  ");
                                                                if($1->getReturnType() == "VOID") {
                                                                    string err = "Void cannot be used in expression ";
                                                                    yyerror(err);
                                                                    $1->setReturnType("FLOAT"); 
                                                                }
                                                                if($3->getReturnType() == "VOID") {
                                                                    string err = "Void cannot be used in expression ";
                                                                    yyerror(err);
                                                                    $3->setReturnType("FLOAT"); 
                                                                }
                                                                if($1->getReturnType() == "FLOAT" || $3->getReturnType() == "FLOAT")
                                                                    $$->setReturnType("FLOAT"); 
                                                                else 
                                                                    $$->setReturnType($1->getReturnType()); 
                
                                                                $$->setParseString("simple_expression : simple_expression ADDOP term");
                                                                parseLine($$, $1, $3); 
                                                                vector<symbolInfo*> childParse; 
                                                                childParse.push_back($1);
                                                                childParse.push_back($2);
                                                                childParse.push_back($3);
                                                                parseChildren($$, childParse);        
                                                            }; 
term : unary_expression { 
                            $$ = new symbolInfo($1->getName(), "TERM");
                            printingLog(logfile, "term :	unary_expression ");   
                            $$->setReturnType($1->getReturnType());  
          
                            $$->setParseString("term : unary_expression");
                            parseLine($$, $1, $1); 
                            vector<symbolInfo*> childParse; 
                            childParse.push_back($1);
                            parseChildren($$, childParse);
                        }

                        | term MULOP unary_expression {
                                                            $$ = new symbolInfo($1->getName() +$2->getName() + $3->getName(), "TERM"); 
                                                            printingLog(logfile, "term :	term MULOP unary_expression ");
                                                            if($1->getReturnType() == "VOID") {
                                                                string err = "Void cannot be used in expression ";
                                                                yyerror(err);
                                                                $1->setReturnType("FLOAT"); 
                                                            }
                                                            if($3->getReturnType() == "VOID") {
                                                                string err = "Void cannot be used in expression ";
                                                                yyerror(err);
                                                                $3->setReturnType("FLOAT"); 
                                                            }
                                                            if($2->getName() == "%" && ($1->getReturnType() == "INT" && $3->getReturnType() != "INT")) { 
                                                                string err = "Operands of modulus must be integers "; 
                                                                yyerror(err); 
                                                                $$->setReturnType("INT"); 
                                                            } 
                                                            else if( $2->getName() == "%" && ($1->getReturnType() != "FLOAT" && $3->getReturnType() != "FLOAT")){
                                                                $$->setReturnType("FLOAT");
                                                            }
                                                            else {
                                                                $$->setReturnType($1->getReturnType());
                                                            }
                                                            if($3->getName() == "0" && ($2->getName() == "/" || $2->getName() == "%")) {
                                                                string err = "Warning: division by zero i=0f=1Const=0";
                                                                yyerror(err); 
                                                            }

                                                            $$->setParseString("term : term MULOP unary_expression");
                                                            parseLine($$, $1, $3); 
                                                            vector<symbolInfo*> childParse; 
                                                            childParse.push_back($1);
                                                            childParse.push_back($2);
                                                            childParse.push_back($3);
                                                            parseChildren($$, childParse);
                                                        }; 

unary_expression : ADDOP unary_expression {
                                                $$ = new symbolInfo($1->getName()+$2->getName(),  "UNARY_EXPRESSION"); 
                                                printingLog(logfile, "unary_expression : ADDOP unary_expression ");
                                                if($2->getReturnType() == "VOID") {
                                                    string err = "Void cannot be used in expression ";
                                                    yyerror(err); 
                                                    $$->setReturnType("FLOAT"); 
                                                }
                                                else 
                                                    $$->setReturnType($2->getReturnType());

                                                $$->setParseString("unary_expression : ADDOP unary_expression");
                                                parseLine($$, $1, $2); 
                                                vector<symbolInfo*> childParse; 
                                                childParse.push_back($1);
                                                childParse.push_back($2);
                                                parseChildren($$, childParse);          
                                            }

                                            | NOT unary_expression {
                                                                        $$ = new symbolInfo($1->getName() + $2->getName(), "UNARY_EXPRESSION"); 
                                                                        printingLog(logfile, "unary_expression : NOT unary_expression  ");
                                                                        if($2->getReturnType() == "VOID") {
                                                                            string err = "Void cannot be used in expression ";
                                                                            yyerror(err); 
                                                                        } 
                                                                        $$->setReturnType("INT"); 

                                                                        $$->setParseString("unary_expression : NOT unary_expression");
                                                                        parseLine($$, $1, $2); 
                                                                        vector<symbolInfo*> childParse; 
                                                                        childParse.push_back($1);
                                                                        childParse.push_back($2);
                                                                        parseChildren($$, childParse);
                                                                    }

                                            | factor {
                                                        $$ = new symbolInfo($1->getName(), "UNARY_EXPRESSION");
                                                        printingLog(logfile, "unary_expression : factor ");
                                                        $$->setReturnType($1->getReturnType());  

                                                        $$->setParseString("unary_expression : factor");
                                                        parseLine($$, $1, $1); 
                                                        vector<symbolInfo*> childParse; 
                                                        childParse.push_back($1);
                                                        parseChildren($$,  childParse);
                                                     }; 

factor: variable {
                    $$ = new symbolInfo($1->getName(), "FACTOR"); 
                    printingLog(logfile, "factor	: variable "); 
                    $$->setReturnType($1->getReturnType());  

                    $$->setParseString("factor : variable");
                    parseLine($$, $1, $1); 
                    vector<symbolInfo*> childParse; 
                    childParse.push_back($1);
                    parseChildren($$, childParse);
                }

                | ID LPAREN argument_list RPAREN {
                                                    $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName() + $4->getName(), "FUNCTION_CALL"); 
                                                    printingLog(logfile, "factor	: ID LPAREN argument_list RPAREN  ");
                                                    symbolInfo* info = symboltable->lookUp($1->getName(), logfile);  
                                                    if(info == NULL) {
                                                        string err = "Undeclared function '" + $1->getName() + "'"; 
                                                        yyerror(err);                
                                                    }  
                                                    else if(info->isDefined() != true) { 
                                                        string err = "Undefined function '" + $1->getName() + "'"; 
                                                        yyerror(err); 
                                                        $$->setReturnType("FLOAT");                       
                                                    } 
                                                    else if(info->isDefined() != true) { 
                                                        string err = "Undefined function '" + $1->getName() + "'";  
                                                        yyerror(err);                        
                                                    } 
                                                    else {
                                                        
                                                        if(info->getParamCount() != argList.size()) {
                                                            if(info->getParamCount() > argList.size()) {
                                                                string err ="Too few arguments to function '" + $1->getName() + "'";
                                                                yyerror(err);                         
                                                            }
                                                            else if(info->getParamCount() < argList.size()) {
                                                                string err ="Too many arguments to function '" + $1->getName() + "'";
                                                                yyerror(err); 
                                                            }
                                                        }
                                                        else {
                                                            vector<int> problem; 
                                                            int count = 0; 
                                                            for(int i = 0; i < argList.size(); i++) {
                                                                string checker = ""; 
                                                                // if(argList[i] == "CONST_INT") 
                                                                //     checker = "INT"; 
                                                                // else if (argList[i] == "CONST_FLOAT")
                                                                //     checker = "FLOAT";
                                                                // else 
                                                                    checker = argList[i];  

                                                                if(uppercaseConvert(info->getParam(i).parameterReturnType) != checker) { 
                                                                    problem.push_back(i + 1);
                                                                    count++; 
                                                                }
                                                            }
                                                            //if(info->isArray() != true){
                                                            for(int j = 0; j < count; j++) {                                                               
                                                                string err = "Type mismatch for argument " + to_string(problem[j]) + " of '" + $1->getName() + "'";
                                                                yyerror(err); 
                                                            }
                                                            //}
                                                            $$->setReturnType(info->getReturnType());
                                                        }
                                                    }
                                                    argList.clear(); 

                                                    $$->setParseString("factor : ID LPAREN argument_list RPAREN");
                                                    parseLine($$, $1, $4); 
                                                    vector<symbolInfo*> childParse; 
                                                    childParse.push_back($1);
                                                    childParse.push_back($2);
                                                    childParse.push_back($3);
                                                    childParse.push_back($4);
                                                    parseChildren($$, childParse);               
                                                }

                | LPAREN expression RPAREN {
                                                $$ = new symbolInfo($1->getName()+$2->getName()+$3->getName(), "FACTOR"); 
                                                printingLog(logfile, "factor	: LPAREN expression RPAREN   ");

                                                parseLine($$, $1, $3); 
                                                $$->setParseString("factor : LPAREN expression RPAREN");
                                                vector<symbolInfo*> childParse; 
                                                childParse.push_back($1);
                                                childParse.push_back($2);
                                                childParse.push_back($3);
                                                parseChildren($$, childParse);
                                                if($2->getReturnType() == "VOID") {
                                                    string err = "Void cannot be used in expression ";
                                                    yyerror(err);                    
                                                    $$->setReturnType("FLOAT");
                                                }

                                            }

                | CONST_INT { 
                                $$ = new symbolInfo($1->getName(), "CONST_INT");
                                printingLog(logfile, "factor	: CONST_INT   "); 
                                $$->setReturnType("INT"); 

                                $$->setParseString("factor : CONST_INT");
                                parseLine($$, $1, $1); 
                                vector<symbolInfo*> childParse; 
                                childParse.push_back($1);
                                parseChildren($$, childParse);
                            }

                | CONST_FLOAT {
                                    $$ = new symbolInfo($1->getName(), "CONST_FLOAT");
                                    printingLog(logfile, "factor	: CONST_FLOAT   "); 
                                    $$->setReturnType("FLOAT"); 

                                    $$->setParseString("factor : CONST_FLOAT");
                                    parseLine($$, $1, $1); 
                                    vector<symbolInfo*> childParse; 
                                    childParse.push_back($1);
                                    parseChildren($$, childParse);
                                }

                | variable INCOP {
                                    $$ = new symbolInfo($1->getName() + $2->getName(), "FACTOR"); 
                                    printingLog(logfile, "factor	: variable INCOP   ");
                                    $$->setReturnType($1->getReturnType());
                
                                    $$->setParseString("factor : variable INCOP");
                                    parseLine($$, $1, $2);   
                                    vector<symbolInfo*> childParse; 
                                    childParse.push_back($1);
                                    childParse.push_back($2);
                                    parseChildren($$, childParse);
                                }

                | variable DECOP {
                                    $$ = new symbolInfo($1->getName()+$2->getName(), "FACTOR"); 
                                    printingLog(logfile, "factor	: variable DECOP   ");
                                    $$->setReturnType($1->getReturnType()); 
                
                                    $$->setParseString("factor : variable DECOP");
                                    parseLine($$, $1, $2); 
                                    vector<symbolInfo*> childParse; 
                                    childParse.push_back($1);
                                    childParse.push_back($2);
                                    parseChildren($$, childParse);
                                }; 

argument_list : arguments {
                                $$ = new symbolInfo($1->getName(), "ARGUMENT_LIST");
                                printingLog(logfile, "argument_list : arguments  "); 
            
                                $$->setParseString("argument_list : arguments");
                                parseLine($$, $1, $1); 
                                vector<symbolInfo*> childParse; 
                                childParse.push_back($1);
                                parseChildren($$, childParse);
                            }

                | {
                        $$ = new symbolInfo("", "ARGUMENT)LIST" ); 
                        printingLog(logfile, "argument_list :");
                   };

arguments : arguments COMMA logic_expression {
                                                $$ = new symbolInfo($1->getName() + $2->getName() + $3->getName(), "ARGUMENTS"); 
                                                printingLog(logfile, "arguments : arguments COMMA logic_expression ");
            
                                                $$->setParseString("arguments : arguments COMMA logic_expression");
                                                parseLine($$, $1, $3); 
                                                vector<symbolInfo*> childParse; 
                                                childParse.push_back($1);
                                                childParse.push_back($2);
                                                childParse.push_back($3);
                                                parseChildren($$, childParse);
                 
                                                if($3->getReturnType() == "VOID") {
                                                    string err = "Void cannot be used in expression ";
                                                    yyerror(err); 
                                                    $1->setReturnType("FLOAT");  
                                                }
                                                else {
                                                    $1->setReturnType($3->getReturnType()); 
                                                }           
                                                argList.push_back($1->getReturnType());    
                                            }

                                            | logic_expression {
                                                                    $$ = new symbolInfo($1->getName(), $1->getType());
                                                                    printingLog(logfile, "arguments : logic_expression"); 
              
                                                                    $$->setParseString("arguments : logic_expression");
                                                                    parseLine($$, $1, $1); 
                                                                    vector<symbolInfo*> childParse; 
                                                                    childParse.push_back($1);
                                                                    parseChildren($$, childParse);
                                                                    if($1->getReturnType() == "VOID") {
                                                                        string err = "Void cannot be used in expression ";
                                                                        yyerror(err); 
                                                                        $1->setReturnType("FLOAT"); 
                                                                    }
                                                                    else {
                                                                        $1->setReturnType($1->getReturnType()); 
                                                                    }               
                                                                    argList.push_back($1->getReturnType());                
                                                                };

%%
int main(int argc,  char* argv[]) {
    int scopeID = 1;
    int bucket = 11; 
    if(argc < 2){
        cout<<"Input file not found"<<endl;
        return 1;
    }

    logfile.open("2005119_log.txt"); 
    errorfile.open("2005119_error.txt");
    parsefile.open("2005119_parsetree.txt");
    
    symboltable->enterScope(scopeID++,  bucket);
    yyin = NULL; 
    yyin = fopen(argv[1], "r"); 
    if( yyin  ==  NULL) 
        return 1;

    yyparse(); 
    fclose(yyin); 

    logfile << "Total Lines: " << lineCount << endl; 
    logfile << "Total Errors: " << errorCount << endl;
    
    delete symboltable;
    return 0;    
}


