#pragma once
#include<iostream>
#include<fstream>
#include<string>
#include<vector>
#include "2005119_scopeTable.cpp"
using namespace std; 

class symbolTable {
    scopeTable* currentScope;
    int bucket;
    
    public:
    symbolTable(int bucket) {
        this->bucket = bucket;
        currentScope = new scopeTable(bucket);
    }

    ~symbolTable() {
        delete currentScope;
        //out << "symbolTable closed" << endl;
    }

    void enterScope(int id, int bucket) {
        currentScope = new scopeTable(id, bucket, currentScope);
    }

    void exitScope(ofstream &out) {
        scopeTable* prev = currentScope;
        currentScope = prev->getParentScope();
        prev->setParentScope(nullptr);
        //out << "\tScopeTable# " << this->currentScope->getId() << " deleted";
        delete prev;
    }

    bool insert(symbolInfo &Symbol, ofstream &out) {
        return currentScope->insertSymbol(Symbol, out);
    }

    bool remove(string name , ofstream &out) {
        return currentScope->deleteSymbol(name, out);
    }

    symbolInfo* lookUp(string name, ofstream &out ) {
        scopeTable *curr = currentScope;
        while (curr != nullptr) {
            symbolInfo* result = curr->lookUpSymbol(name, out);
            if(result == nullptr)
                curr = curr->getParentScope();
            else {
                //out << "found" << endl;
                return result;
            }
        }
        //out << "\t'" << name <<"' not found in any of the ScopeTables" << endl;
        return nullptr;
    }


    int getscopeID(string name, ofstream &out) {
        scopeTable *curr = currentScope;
        while (curr != nullptr) {
            symbolInfo* result = curr->lookUpSymbol(name, out);
            if(result == nullptr) 
                curr = curr->getParentScope();
            else {
                return curr->getID();
            }
        }
        return 0; 
    }

    void printCurrentScope(ofstream &out) {
        return currentScope->print(out);
    }

    int currScopeID() {
        return currentScope->getID();
    }

    void printAllScope(ofstream &out) {
        currentScope->print(out);
        scopeTable* pScope = currentScope->getParentScope();
        while (pScope != nullptr && pScope->getID() != 0) {
            pScope->print(out);
            pScope = pScope->getParentScope();
        }
        return;
    }
};
