#include <iostream>
#include <vector>

using namespace std;

int main(){
    int d, k, sz=0, h, c;
    cin>>d;
    vector<vector<int>> A(100, vector<int>(100, 0));
    for (int i=0; i !=d; ++i){
        cin>>k;
        if (k > 0){
            cin>>h;
        }
        if (h > sz){
            sz = h;
        }
        for (int j=1; j < k; ++j){
            cin>>c;
            A[h-1][c-1] = 1;
            A[c-1][h-1] = -1;
            if (c > sz){
                sz = c;
            }
        }
    }

    for (int i=0; i != sz; ++i){
        for (int j=0; j != sz; ++j) {
            cout<<A[i][j]<<' ';
        }
        cout<<'\n';
    }
}