#include "2005119_symbolInfo.h"

symbolInfo::symbolInfo(string name, string type){
    this->name = name;
    this->type = type;
    this->next = nullptr;
}

symbolInfo::~symbolInfo(){
    delete next;
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

std::ostream &operator << (std::ostream &os, symbolInfo &symbol) {
  return os << "(" + symbol.getName() + "," + symbol.getType() + ")";
}


