#pragma once
#include<iostream>
#include<fstream>
#include<string>
#include<vector>
#include "2005119_symbolInfo.cpp"
using namespace std;

class scopeTable {
    int ID;
    int bucket;
    scopeTable* parentScope;
    symbolInfo** hashtable;

    public:
    long long hashFunction(string name) {
        unsigned long long hash = 0;
        for(unsigned long int i = 0; i < name.size(); i++) 
            hash = (int)name[i] + (hash << 6) + (hash << 16) - hash;
        return hash % bucket;
    }

    scopeTable(int n) {
        this->bucket = n;
        hashtable = new symbolInfo* [bucket];
        for(int i = 0 ; i < bucket ; i++)
             hashtable[i] = nullptr;
    }

    scopeTable(int ID, int bucket, scopeTable *parentScope) {
        this->ID = ID;
        this->bucket = bucket;
        this->parentScope = parentScope;
        hashtable = new symbolInfo* [bucket];
        for(int i = 0; i < bucket; i++)
            hashtable[i] = nullptr;
    }

    ~scopeTable() {
        delete[] hashtable;
    }

    bool insertSymbol(symbolInfo &symbol, ofstream &out) {
         int hashval = hashFunction(symbol.getName());
         symbolInfo* curr = hashtable[hashval];
         symbolInfo* prev = nullptr;
         int pos = 1;
    
        while (curr != nullptr) {
            if (curr->getName() == symbol.getName()) {
                //out << "\t'" << symbol.getname() << "' already exists in the current ScopeTable# " << this->ID;
                return false;
            }
        prev = curr;
        curr = curr->getNext();
        pos++;
        }

        if (prev == nullptr) {
            hashtable[hashval] = &symbol;
            //out << "\tInserted  at position <" << hashVal + 1 << ", " << pos << "> of ScopeTable# " << this->ID;
        }
        else {
            prev->setNext(&symbol);
            //out << "\tInserted  at position <" << hashVal + 1 << ", " << pos << "> of ScopeTable# " << this->ID;
        }

        return true;
    }


    bool deleteSymbol(string name, ofstream &out) {
        int hashval = hashFunction(name);
        symbolInfo* curr = hashtable[hashval];
        symbolInfo* prev = nullptr;
        int pos = 1;
   
        while (curr != nullptr) {
            if(curr->getName() == name){
                //out << "Found in ScopeTable# " << id << " at position " << hashVal + 1 << ", " << pos + 1 << endl;
                return curr;
            }
            prev = curr;
            curr = curr->getNext();
            pos++;
        }

        if(curr == nullptr) {
            //out << "\tNot found in the current ScopeTable" << endl;
            return false;
        }

        else if(prev == nullptr) {
            hashtable[hashval] = curr->getNext();
        }

        else {
            prev->setNext(curr->getNext());
        }

        out << "\tDeleted '" << name << "' from ScopeTable# " << ID << " at position " << hashval+1 << ", " << pos << endl;
        return true;
    }

    symbolInfo* lookUpSymbol(string name, ofstream &out) {
        int hashvalue  = hashFunction(name);
        symbolInfo* curr = hashtable[hashvalue];
        int pos = 1;

        while(curr != nullptr) {
            if(curr->getName() == name) {
                //out << "\t'" << name << "' found in ScopeTable# " << ID << " at position " << hashvalue + 1 << ", " << pos << endl ; 
                return curr;
            }
            curr = curr->getNext();
            pos++;
        }
        return nullptr;
    }


    void print(ofstream &out) {
        out << "\tScopeTable# " << ID << endl;
        for(int i = 0; i < bucket; i++) {
            symbolInfo* curr = hashtable[i];
            int entry = 1;

            while ( curr != nullptr) {
               if(entry) {
                    out << "\t" << i + 1 << "--> <";
                    entry = 0;
                }
                    
               if(curr->isFunction()) {
                    out << curr->getName() << "," << curr->getType() << "," << curr->getReturnType() << "> "; 
               } 

               else if(curr->isArray()) {
                   out << curr->getName() << "," << curr->getReturnType() << "> "; 
               } 
               
               else
                   out << curr->getName() << "," << curr->getType() << "> ";
               curr = curr->getNext();
               if(curr == nullptr) 
                   out << endl;
               else out << "<";
            }

        }

    }

    
    int getID() {
        return ID;
    }

    scopeTable* getParentScope() {
        return this->parentScope;
    }

    void setParentScope(scopeTable* parentScope){
        this->parentScope = parentScope;
    }
    
};
