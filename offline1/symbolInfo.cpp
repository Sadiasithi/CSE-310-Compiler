#include "symbolInfo.h"

symbolInfo::symbolInfo(string name, string type){
    this->name = name;
    this->type = type;
    this->next = nullptr;
}

symbolInfo::~symbolInfo(){
}

string symbolInfo::getName(){
    return this->name;
}

string symbolInfo::getType(){
    return this->type;
}

symbolInfo* symbolInfo::getNext(){
    return this->next;
}

void symbolInfo::setName(string name){
    this->name = name;

}

void symbolInfo::setType(string type){
    this->type = type;

}

void symbolInfo::setNext(symbolInfo* next){
    this->next = next;
}

ostream &operator << (ostream &output, symbolInfo &symbol){
    //if (&symbol){
        output << "(" << symbol.name << "," << symbol.type << ")";
    //}
    //else {
      //  output << "Not found" << endl;
    //}
    return output;
}
