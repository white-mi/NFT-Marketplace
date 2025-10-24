#include <iostream>
#include <vector>

using namespace std;

int main(){
    int sz;
    cin>>sz;
    vector<vector<int>> M(sz, vector<int>(sz, 0));

    for (int i=0; i != sz; ++i){
        for (int j=0; j != sz; ++j){
            cin>>M[i][j];
        }
    }

    for (int k = 0; k < sz; k++) {
        for (int i = 0; i < sz; i++) {
            for (int j = 0; j < sz; j++) {
                if (M[i][k] && M[k][j]) {
                    M[i][j] = 1;
                }
            }
        }
    }

    for (int i=0; i != sz; ++i){
        for (int j=0; j != sz; ++j) {
            cout<<M[i][j]<<' ';
        }
        cout<<'\n';
    }
}