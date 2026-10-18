#define BUCKET_NO 11
#include "2005119_symbolInfo.cpp"
using namespace std;

class scopeTable {
private:
    string id;
    int bucket;
    scopeTable* parentScope;
    int innerScopeCount;
    symbolInfo** hashTable;
    long long hashFunction(string name);
    
public:
    scopeTable(int n, scopeTable *parent);
    ~scopeTable();
    bool insertSymbol(string name, string type);
    bool deleteSymbol(string name);
    symbolInfo* lookupSymbol(string name);
    void print();
    string getId();
    void setId(scopeTable* parent);
    int getInnerScopeCount();
    void incrementInnerScopeCount();
    scopeTable* getParentScope();
    void setParentScope(scopeTable* parentScope);
};

