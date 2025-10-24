#include <iostream>
#include <vector>

using namespace std;

int main(){
    int n, m, result=1;
    cin >> n >> m;
    vector<vector<int>> room(n, vector<int>(m, 0));
    for (int i = 0; i != n; ++i){
        for (int j = 0; j != m; ++j){
            char c;
            cin>>c;
            if (c == '#'){
                room[i][j] = 2;
            } else {
                room[i][j] = 0;
            }
        }
    }

    int b0, b1, l, v=0;
    cin >> b0 >> b1 >> l;
    b0--;
    b1--;
    for (int i=0; i != l; ++i) {
        char c;
        cin>>c;
        if (c == 'R'){
            if (v<3)
                v += 1;
            else
                v = 0;
        } else if (c == 'L'){
            if (v>0)
                v -= 1;
            else
                v = 3;
        } else if (c == 'M'){
            if (v == 0 && b0 > 0){
                if (room[b0-1][b1] < 2){
                    room[b0][b1] = 1;
                    b0 -= 1;
                    if (room[b0][b1] == 0)
                        result += 1;
                }
            } else if (v == 1 && b1 < m - 1){
                if (room[b0][b1+1] < 2){
                    room[b0][b1] = 1;
                    b1 += 1;
                    if (room[b0][b1] == 0)
                        result += 1;
                }
            } else if (v == 3 &&  b1 > 0){
                if (room[b0][b1-1] < 2){
                    room[b0][b1] = 1;
                    b1 -= 1;
                    if (room[b0][b1] == 0)
                        result += 1;
                }
            } else if (v == 2 && b0 < n - 1){
                if (room[b0+1][b1] < 2){
                    room[b0][b1] = 1;
                    b0 += 1;
                    if (room[b0][b1] == 0)
                        result += 1;
                }
            }
        }
    }
    cout<<result;
}