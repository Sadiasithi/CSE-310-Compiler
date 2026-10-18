#include "symbolTable.h"

symbolTable::symbolTable(int bucket){
    this->bucket = bucket;
    this->globalId = 0;
    this->currentScope = new scopeTable(bucket, nullptr, ++this->globalId);
    cout<<"\tScopeTable# " + this->currentScope->getId() + " created";
}

symbolTable::~symbolTable(){
    while(this->currentScope != nullptr){
        scopeTable* parent = this->currentScope->getParentScope();
        cout << "\tScopeTable# " << this->currentScope->getId() << " deleted" << endl;
        delete this->currentScope;
        this->currentScope = parent;
    }
    //cout << "symbolTable closed" << endl;
}

void symbolTable::enterScope(){
    if(this->currentScope == nullptr){
        this->currentScope = new scopeTable(this->bucket, nullptr, ++this->globalId);
        cout << "\tScopeTable# " << this->currentScope->getId() << " created";
        return;
    }
    scopeTable* newScope = new scopeTable(this->bucket, this->currentScope, this->globalId);
    this->currentScope = newScope;
    cout << "\tScopeTable# " << this->currentScope->getId() << " created";
}


void symbolTable::exitScope(){
    if(this->currentScope == nullptr){
        cout << "No scope exists" << endl;
        return;
    }

    if(this->currentScope->getParentScope() == nullptr){
        cout << "\tScopeTable# " << this->currentScope->getId() << " cannot be deleted";
        return;
    }

    scopeTable* parent = this->currentScope->getParentScope();
    cout << "\tScopeTable# " << this->currentScope->getId() << " deleted";
    delete this->currentScope;
    this->currentScope = parent;
}


void symbolTable::insert(string name, string type){
    if(this->currentScope == nullptr){
        this->currentScope= new scopeTable(this->bucket, nullptr, ++this->globalId);
    }
    this->currentScope->insertSymbol(name, type);
}


bool symbolTable::remove(string name){
    if(this->currentScope == nullptr){
        cout << "\tNot found in the current ScopeTable# " << this->currentScope->getId();
        return false;
    }
    return this->currentScope->deleteSymbol(name);
}


symbolInfo* symbolTable::lookUp(string name){
    scopeTable* temp = this->currentScope;
    symbolInfo* searchResult;
    while(temp != nullptr){
        searchResult = temp->lookupSymbol(name);
        if(searchResult == nullptr){
            temp = temp->getParentScope();
        }
        else return searchResult;
    }
    cout <<"\t'" << name << "' not found in any of the ScopeTables";
    return nullptr;
}


void symbolTable::printCurrentScope(){
    if(this->currentScope == nullptr){
        //cout << "Nothing to print";
        return;
    }
    this->currentScope->printCurrent();
}


void symbolTable::printAllScope(){
    scopeTable* current = this->currentScope;
    while (current != nullptr){
        current->print();
        current = current->getParentScope();
    }
}
