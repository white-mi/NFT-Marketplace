#include <iostream>
#include <vector>

using namespace std;

int main(){
    int n, k, sz=0;
    cin>>n;
    vector<vector<int>> M(1000, vector<int>(1000, 0));
    for (int i = 0; i != n; ++i){
        cin>>k;
        vector<int> l(k);
        for (int j = 0; j != k; ++j){
            cin>>l[j];
            if (l[j] > sz){
                sz = l[j];
            }
        }
        vector<int> past;
        for (int j = 0; j != k-1; ++j){
            int u = l[j]-1;
            int v = l[j + 1]-1;
            M[u][v] = 1;
            M[v][u] = 1;
            for (size_t p=0; p != past.size(); ++p){
                int u = past[p];
                M[u][v] = 1;
                M[v][u] = 1;
            }
            past.push_back(u);
        }
    }
    for (int i = 0; i < sz; i++) {
        for (int j = 0; j < sz-1; j++) {
            cout << M[i][j] << ' ';
        }
        cout << M[i][sz-1];
        cout << endl;
    }
    
    return 0;
}