#include "2005119_symbolTable.h"

symbolTable::symbolTable(int bucket = BUCKET_NO){
    this->bucket = bucket;
    currentScope = new scopeTable(bucket, currentScope);
}

symbolTable::~symbolTable(){
     delete currentScope;
    //cout << "symbolTable closed" << endl;
}

void symbolTable::enterScope(){
    currentScope->incrementInnerScopeCount();
    currentScope = new scopeTable(bucket, currentScope);
    //cout << "\tScopeTable# " << this->currentScope->getId() << " created";
}


void symbolTable::exitScope(){
    scopeTable* prev = currentScope;
    currentScope = prev->getParentScope();
    prev->setParentScope(nullptr);
    // cout << "\tScopeTable# " << this->currentScope->getId() << " deleted";
    delete prev;
}


bool symbolTable::insert(string name, string type){
    bool result = currentScope->insertSymbol(name, type);
    if (result) printAllScope();
    return result;
}


bool symbolTable::remove(string name){
     return currentScope->deleteSymbol(name);
}


symbolInfo* symbolTable::lookUp(string name){
    symbolInfo* result = nullptr;

    for (scopeTable* curr = currentScope; curr != nullptr; curr = curr->getParentScope()) {
      result = curr->lookupSymbol(name);
      if (result != nullptr)
        return result;
    }

    // cout <<"\t'" << name << "' not found in any of the ScopeTables";
    return nullptr;
}


void symbolTable::printCurrentScope(){
    currentScope->print();
}


void symbolTable::printAllScope(){ 
    scopeTable* lastScope = nullptr;

    for (scopeTable* curr = currentScope; curr != nullptr; curr = curr->getParentScope()) {
        curr->print();
        lastScope = curr;
    }

    if (lastScope != nullptr) {
        cout << endl; 
    }
}

