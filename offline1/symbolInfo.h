using namespace std;

class symbolInfo {
private:
    string name;
    string type;
    symbolInfo* next;
public:
    symbolInfo(string name, string type);
    ~symbolInfo();
    string getName();
    string getType();
    symbolInfo* getNext();
    void setName(string name);
    void setType(string type);
    void setNext(symbolInfo* next);
    friend ostream &operator << (ostream &output, symbolInfo &symbol);
};
