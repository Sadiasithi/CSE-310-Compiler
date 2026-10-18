#include "scopeTable.h"


 long long scopeTable::hashFunction(string name){
    unsigned long long hash = 0;
    for (unsigned long long  i = 0; i < name.size(); i++)
        hash = (int)name[i] + (hash << 6) + (hash << 16) - hash;
    return hash % bucket;
}

scopeTable::scopeTable(int bucket, scopeTable* parentScope, int globalId){
    this->bucket = bucket;
    this->parentScope = parentScope;
    this->hashTable = new symbolInfo*[bucket];

    for (int i = 0; i < bucket; i++){
        hashTable[i] = nullptr;
    }

    this->innerScopeCount = 0;
    if (this->parentScope != nullptr){
        (this->parentScope->innerScopeCount)++;
        this->id = this->parentScope->id + "." + to_string(this->parentScope->innerScopeCount);
    }
    else {
        id = to_string(globalId);
    }
}


scopeTable::~scopeTable(){
    for (int i = 0; i < this->bucket; i++){
        symbolInfo* temp;

        while(this->hashTable[i] != nullptr) {
            temp = this->hashTable[i]->getNext();
            delete this->hashTable[i];
            this->hashTable[i] = temp;
        }
    }
    delete[] this->hashTable;
    //cout << "Destroying the ScopeTable";
}



bool scopeTable::insertSymbol(string name, string type) {
    int hashVal = hashFunction(name);
    int pos = 0;
    symbolInfo* curr = this->hashTable[hashVal];

    if (curr == nullptr) {
        this->hashTable[hashVal] = new symbolInfo(name, type);
        cout << "\tInserted  at position <" << hashVal + 1 << ", " << pos + 1 << "> of ScopeTable# " << this->id;
        return true;
    }

    while (curr->getNext() != nullptr) {
        if (curr->getName() == name) {
            cout << "\t'" << name << "' already exists in the current ScopeTable# " << this->id;
            return false;
        }
        curr = curr->getNext();
        pos++;
    }

    if (curr->getName() == name) {
        cout << "\t'" << name << "' already exists in the current ScopeTable# " << this->id;
        return false;
    }
     else {
        curr->setNext(new symbolInfo(name, type));
        pos++;
        cout << "\tInserted  at position <" << hashVal + 1 << ", " << pos + 1 << "> of ScopeTable# " << this->id;
        return true;
    }
}



bool scopeTable::deleteSymbol(string name) {
    int hashVal = hashFunction(name);
    int pos = 0;
    symbolInfo* curr = this->hashTable[hashVal];

    if(curr == nullptr) {
        cout << "\tNot found in the current ScopeTable# " << this->id;
        return false;
    }

    symbolInfo* prev = nullptr;
    if(curr->getName() == name) {
        this->hashTable[hashVal] = curr->getNext();
        delete curr;
        cout << "\tDeleted '" << name << "' from position <" << hashVal + 1 <<", " << pos + 1 << "> of ScopeTable# " << this->id;
        return true;
    }
    while(curr != nullptr){
        if(curr->getName() == name) {
            prev->setNext(curr->getNext());
            delete curr;
            cout << "\tDeleted '" << name << "' from position <" << hashVal + 1 <<", " << pos + 1 << "> of ScopeTable# " << this->id;
            return true;
        }
        prev = curr;
        curr = curr->getNext();
        pos++;
    }
    //cout << name << " not found";
    cout << "\tNot found in the current ScopeTable# " << this->id;
    return false;
}


symbolInfo* scopeTable::lookupSymbol(string name){
    int hashVal = hashFunction(name);
    int pos = 0;
    symbolInfo* current = this->hashTable[hashVal];
    bool found = false;

    while(current != nullptr){
        if(current->getName() == name) {
            cout << '\t' << "'" << name << "' found " << "at position " << "<" << hashVal + 1 <<", " << pos + 1 << ">" << " of ScopeTable# " << this->id ;
            found = true;
            break;
        }

        current = current->getNext();
        pos++;
    }

    if (!found && this->getParentScope() != nullptr) {
        symbolInfo* symbol = this->getParentScope()->lookupSymbol(name);
        if (symbol != nullptr) {
            return symbol;
        }
    }

    if (found) return current;
    else return nullptr;
}



void scopeTable::print() {
    cout << "\tScopeTable# " << id;
    for (int i = 0; i < bucket; i++) {
        symbolInfo* current = this->hashTable[i];
        if (current != nullptr) {
            cout << endl << '\t' << i + 1 << " --> ";
            bool firstSymbol = true;
            while (current != nullptr) {
                if (!firstSymbol) {
                    cout << " --> ";
                }
                cout << *current;
                current = current->getNext();
                firstSymbol = false;
            }
        }
        else {
            cout << endl << '\t' << i + 1;
        }
    }
    if (this->getParentScope() != nullptr ) {
        cout << endl;
    }
}


void scopeTable::printCurrent() {
    cout << "\tScopeTable# " << id;
    for (int i = 0; i < bucket; i++) {
        symbolInfo* current = this->hashTable[i];
        if (current != nullptr) {
            cout << endl << '\t' << i + 1 << " --> ";
            bool firstSymbol = true;
            while (current != nullptr) {
                if (!firstSymbol) {
                    cout << " --> ";
                }
                cout << *current;
                current = current->getNext();
                firstSymbol = false;
            }
        }
        else {
            cout << endl << '\t' << i + 1;
        }
    }
}



string scopeTable::getId(){
    return this->id;
}

int scopeTable::getInnerScopeCount(){
    return this->innerScopeCount;
}

scopeTable* scopeTable::getParentScope(){
    return this->parentScope;
}
