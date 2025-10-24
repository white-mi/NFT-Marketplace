#include <iostream>
#include <vector>

using namespace std;

int main(){
    int n, m, k;
    cin>>n>>m;
    vector<vector<int>> M1(n, vector<int>(n, 0));
    vector<vector<int>> M2(n, vector<int>(n, 0));
    for (int i = 0; i != m; ++i){
        cin>>k;
        vector<int> l(k);
        for (int j = 0; j != k; ++j){
            cin>>l[j];
        }
        vector<int> past;
        for (int j = 0; j != k-1; ++j){
            int u = l[j]-1;
            int v = l[j + 1]-1;
            M1[u][v] = 1;
            M1[v][u] = 1;
            M2[u][v] = 1;
            M2[v][u] = 1;
            for (size_t p=0; p != past.size(); ++p){
                int u = past[p];
                M2[u][v] = 1;
                M2[v][u] = 1;
            }
            past.push_back(u);
        }
    }
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n-1; j++) {
            cout << M1[i][j] << ' ';
        }
        cout << M1[i][n-1];
        cout << endl;
    }
    
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n-1; j++) {
            cout << M2[i][j] << ' ';
        }
        cout << M2[i][n-1];
        cout << endl;
    }
    
    return 0;
}