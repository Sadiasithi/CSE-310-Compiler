#include "scopeTable.cpp"
using namespace std;

class symbolTable {
private:
    int bucket;
    scopeTable* currentScope;
    int globalId;

public:
    symbolTable(int bucket);
    ~symbolTable();
    void enterScope();
    void exitScope();
    void insert(string name, string type);
    bool remove(string name);
    symbolInfo* lookUp(string name);
    void printCurrentScope();
    void printAllScope();
};
