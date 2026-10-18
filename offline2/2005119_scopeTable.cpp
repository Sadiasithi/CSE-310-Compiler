#include "2005119_scopeTable.h"


long long scopeTable::hashFunction(string name){
    unsigned long long hash = 0;
    for (unsigned long long i = 0; i < name.size(); i++)
        hash = (int)name[i] + (hash << 6) + (hash << 16) - hash;
    return hash % BUCKET_NO;
}


scopeTable::scopeTable(int bucket = BUCKET_NO, scopeTable* parent = nullptr){
    this->bucket = bucket;
    hashTable = new symbolInfo* [bucket];
    for (int i = 0; i < bucket; i++)
      hashTable[i] = nullptr;
    parentScope = parent;
    innerScopeCount = 0;
    setId(parent);
    
}


scopeTable::~scopeTable(){
    for (int i = 0; i < bucket; i++)
      delete hashTable[i];
    delete[] hashTable;
    delete parentScope;
    //cout << "Destroying the ScopeTable";
}


bool scopeTable::insertSymbol(string name, string type) {
    int hashVal = hashFunction(name);
    if (hashTable[hashVal] == nullptr) {
      //cout << "\tInserted  at position <" << hashVal + 1 << ", " << pos + 1 << "> of ScopeTable# " << this->id;
      hashTable[hashVal] = new symbolInfo(name, type);
      return true;
    }

    symbolInfo *curr = hashTable[hashVal];
    symbolInfo *prev = nullptr;
    int pos = 0;

    while (curr != nullptr) {
      if (curr->getName() == name) {
        //cout << "\t'" << name << "' already exists in the current ScopeTable# " << this->id;
        return false;
      }
      prev = curr;
      curr = curr->getNext();
      pos++;
    }

    prev->setNext(new symbolInfo(name, type));
    //cout << "\tInserted  at position <" << hashVal + 1 << ", " << pos + 1 << "> of ScopeTable# " << this->id;
    return true;
}



bool scopeTable::deleteSymbol(string name) {
    int hashVal = hashFunction(name);
    symbolInfo* curr = hashTable[hashVal];
    symbolInfo* prev = nullptr;
    int pos = 0;

    while (curr != nullptr) {
      if (curr->getName() == name)
        break;
      prev = curr;
      curr = curr->getNext();
      pos++;
    }

    if (curr == nullptr) {
      //cout << "\tNot found in the current ScopeTable# " << this->id;
      return false;
    }
    else {
      //cout << "Found in ScopeTable# " << id << " at position " << hashVal + 1 << ", " << pos + 1<< endl << endl;
    }
    if (prev == nullptr)
      hashTable[hashVal] = curr->getNext();
    else
      prev->setNext(curr->getNext());
    //cout << "\tDeleted '" << name << "' from position <" << hashVal + 1 <<", " << pos + 1 << "> of ScopeTable# " << this->id;
    return true;
  }


symbolInfo* scopeTable::lookupSymbol(string name){ 
    int hashVal = hashFunction(name);
    symbolInfo* curr = hashTable[hashVal];
    int pos = 0;

    while (curr != nullptr) {
      if (curr->getName() == name) {
        //cout << "Found in ScopeTable# " << id << " at position " << hashVal + 1 << ", " << pos + 1 << endl;
        return curr;
      }
      curr = curr->getNext();
      pos++;
    }
    return nullptr;
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



string scopeTable::getId(){
    return this->id;
}

void scopeTable::setId(scopeTable* parent) {
    if (parent == nullptr)
      id = "1";
    else
      id = parent->getId() + "." +  to_string(parent->getInnerScopeCount());
  }

int scopeTable::getInnerScopeCount(){
    return this->innerScopeCount;
}

void scopeTable::incrementInnerScopeCount(){
  innerScopeCount++;
}

scopeTable* scopeTable::getParentScope(){
    return this->parentScope;
}

void scopeTable::setParentScope(scopeTable* parentScope){
  this->parentScope = parentScope;
}

