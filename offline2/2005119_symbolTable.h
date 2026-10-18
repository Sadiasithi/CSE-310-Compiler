#include <bits/stdc++.h>
#define BUCKET_NO 11
using namespace std;
#include "2005119_scopeTable.cpp"

class symbolTable {
private:
    int bucket;
    scopeTable* currentScope;

public:
    symbolTable(int bucket);
    ~symbolTable();
    void enterScope();
    void exitScope();
    bool insert(string name, string type);
    bool remove(string name);
    symbolInfo* lookUp(string name);
    void printCurrentScope();
    void printAllScope();
};

