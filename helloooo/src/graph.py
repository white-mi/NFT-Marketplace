import numpy as np
n, m = list(map(int, input().split()))
M1 = np.zeros(n*n, dtype=np.int16).reshape(n, n)
M2 = np.zeros(n*n, dtype=np.int16).reshape(n, n)
for i in range(m):
    l = list(map(int, input().split()))
    past = np.array([], dtype=np.int16)
    for j in range(1, l[0]):
        cur_0 = l[j]
        cur_1 = l[j + 1]
        M1[cur_0-1][cur_1-1] = 1
        M1[cur_1-1][cur_0-1] = 1
        M2[cur_0-1][cur_1-1] = 1
        M2[cur_1-1][cur_0-1] = 1
        for k in past:
            M2[k-1][cur_1-1] = 1
            M2[cur_1-1][k-1] = 1
        past = np.append(past, cur_0)
for i in range(n):
    print(*M1[i])
for i in range(n):
    print(*M2[i])