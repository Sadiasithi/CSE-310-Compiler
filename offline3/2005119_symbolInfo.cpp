#pragma once
#include<iostream>
#include<fstream>
#include<string>
#include<vector>
using namespace std; 

class symbolInfo {
    string name;
    string type;
    symbolInfo* next;
     
    struct parameterInfo {
        string parameterName; 
        string parameterReturnType; 
    }paramInfo;

    int arraySize = -1; 
    string returnType ;

    bool declared = false;
    bool defined = false; 
    vector<parameterInfo> functionParam; 

    string parseString;
    int startLine; 
    int EndLine; 
    vector<symbolInfo*> childList; 
    bool isleaf;
    int childCount = 0;  
    int spaceDepth;  
    bool same = false;

public :
    symbolInfo(string name, string type) {
        this->name = name;
        this->type = type;
        this->next = nullptr;
    }

    ~symbolInfo() { functionParam.clear(); }

    string getName() { return name; }
    void setName(string name) { this->name = name; }
    string getType() { return type; }
    void setType(string type) { this->type = type; }
    symbolInfo* getNext() { return this->next; }
    void setNext(symbolInfo* next) { this->next = next; }

    void addnew(string name, string type) {
        paramInfo.parameterName = name; 
        paramInfo.parameterReturnType = type; 
        functionParam.push_back(paramInfo); 
    }

    int getParamCount() { return functionParam.size(); }
    parameterInfo getParam(int i) { return functionParam[i]; }

    parameterInfo getParam(string name) {
        for(int i = 0; i < getParamCount(); i++) {
            if(functionParam[i].parameterName == name) return functionParam[i];  
        }
        return functionParam[0];
    }

    void setSize(int size) { arraySize = size; }
    int getSize() { return arraySize; }
    void setReturnType(string type) { returnType = type; }
    string getReturnType() { return returnType;}

    bool isFunction() {
        if(type == "FUNCTION") 
            return true;
        return false; 
    }

    bool isArray() {
        if(arraySize == -1) 
            return false;
        return true;
    }


    bool isDefined(){ return defined; }
    bool isDeclared(){ return declared; } 
    void setIsDefined(bool checkVal){ defined = checkVal; }
    void setIsDeclared(bool checkVal){ declared = checkVal; } 

    // for parse tree  
    void setParseString(string line ) { parseString = line; }
    string getParseLine() { return parseString; }
    void setStartLine(int line) { startLine = line; }
    int getStartLine() { return startLine; }
    void setEndLine(int line) { EndLine = line; } 
    int getEndLine() { return EndLine; }

    void setleaf(bool checkval) { isleaf = checkval; }
    bool isLeaf() { return isleaf; }
     
    void addChild(symbolInfo* child) {
        child->setSpace(childrenNum() + getSpace());
        childList.push_back(child);
        childCount++;
        spaceDepth++; 
    }

    void addMultipleChild(vector<symbolInfo*> multipleChild) {
        for(symbolInfo* info : multipleChild) {
            addChild(info);     
        }
    }

    int childrenNum() { return childCount; }
    int getSpace() { return spaceDepth; }
    void setSpace(int space) { spaceDepth = space;}

    bool isSame() {
         if(startLine == EndLine) 
            same = true;
         else 
            same = false;
         return same;   
    } 

    void printParseTree(ofstream &out, int space) { 
        int curr = 0;
        while (curr < space) {
            out << " ";
            curr++;
        } 

        if(isLeaf()) {
            out << getType() << " : "<< getName() << "\t<Line: " << getStartLine() << ">" << endl;   
        }

        else {
            out << getParseLine() << " \t<Line: " << getStartLine() << "-" << getEndLine() << ">" << endl;
            for(symbolInfo* info : childList) {
                info->printParseTree(out, space + 1);     
            }
        }     
    }
};
