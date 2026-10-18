#include <iostream>
#include <fstream>
#include <sstream>
#include "symbolTable.cpp"

using namespace std;

int main() {
    freopen("input.txt", "r", stdin);
    freopen("output.txt", "w", stdout);

    int n;
    cin >> n;
    symbolTable* symboltable = new symbolTable(n);

    string firstLine;
    getline(cin, firstLine);
    

    string menu;
    int lineNumber = 1;
    while (getline(cin, menu)) {
        cout << endl;
        cout << "Cmd " << lineNumber++ << ": " << menu << endl;

        stringstream ss(menu);
        string command;
        ss >> command;

        if (command == "I") {
            string name, type;
            if (!(ss >> name >> type) || ss.rdbuf()->in_avail() != 0) {
                cout << "\tWrong number of arugments for the command I";
            }
            else {
                symboltable->insert(name, type);
            }
        }
        else if (command == "L") {
            string name;
            if (!(ss >> name) || ss.rdbuf()->in_avail() != 0) {
                cout << "\tWrong number of arugments for the command L";
            }
            else {
                symboltable->lookUp(name);
            }
        }
        else if (command == "E") {
            if (ss.rdbuf()->in_avail() != 0) {
                cout << "\tWrong number of arguments for the command E";
            }
            else {
               symboltable->exitScope();
            }
        }
        else if (command == "S") {
           if (ss.rdbuf()->in_avail() != 0) {
               cout << "\tWrong number of arguments for the command S";
        }
        else {
              symboltable->enterScope();
        }
        }
        else if (command == "D") {
            string name;
            if (!(ss >> name) || ss.rdbuf()->in_avail() != 0) {
                cout << "\tWrong number of arugments for the command D";
            }
            else {
                symboltable->remove(name);
            }
        }
        else if (command == "P") {
            string printCommand;
            ss >> printCommand;
            if (printCommand == "A")
                symboltable->printAllScope();
            else if (printCommand == "C")
                symboltable->printCurrentScope();
            else cout << "\tInvalid argument for the command P";
        }
        else if (command == "Q"){
            delete symboltable;
        }
    }

    //delete symboltable;
    return 0;
}
