#include <iostream>
#include <vector>

using namespace std;

vector<vector<int>> Transpose(const vector<vector<int>>& matrix){
    vector<vector<int>> A={};
    for (size_t i=0; i != matrix[0].size(); ++i){
        vector<int> a(matrix.size());
        A.push_back(a);
    }
    
    for (size_t i=0; i != matrix.size(); ++i){
        for (size_t j=0; j != matrix[0].size(); ++j){
            A[j][i] = matrix[i][j];
        }
    }
    return A;
}

int main() {
    vector<vector<int>> s=Transpose({{1, 2}, {1, 2}, {1, 2}});
    cout<<s[0][0]<<s[0][1]<<s[0].size()<<'\n';
}