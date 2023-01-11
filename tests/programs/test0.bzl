a = [[1, 2], [3, 4], [5, 6]]
b = [[1, 3, 5, 7], [2, 4, 6, 8]]
n = len(a)
p = len(a[0])
if p != len(b):
    exit(0)
m = len(b[0])
c = [[0]*m for _ in range(n)]

for k in range(p):
    for i in range(n):
        for j in range(m):
            c[i][j] += a[i][k] * b[k][j] 
print(c)