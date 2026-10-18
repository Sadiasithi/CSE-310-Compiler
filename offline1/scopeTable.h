#include<bits/stdc++.h>
#include "symbolInfo.cpp"
using namespace std;

class scopeTable {
private:
    symbolInfo** hashTable;
    int bucket;
    string id;
    scopeTable* parentScope;
    int innerScopeCount;
    long long hashFunction(string name);
public:
    scopeTable(int bucket, scopeTable* parent, int globalId);
    ~scopeTable();
    bool insertSymbol(string name, string type);
    bool deleteSymbol(string name);
    symbolInfo* lookupSymbol(string name);
    void print();
    void printCurrent();
    string getId();
    int getInnerScopeCount();
    scopeTable* getParentScope();
};
