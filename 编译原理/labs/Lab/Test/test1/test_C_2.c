int map[10][10];
int dis[10][10];
int floyd(int num){
    int i,j,k;
    i = j = k = 0;
    while(i < num) {
        while(j < num) {
            while(k < num) {
                if (dis[j][i] + dis[i][k] < dis[j][k]) {
                    i = j + k;
                }
                k = k + 1;
            }
            j = j + 1;
        }
        i = i + 1;
    }
    return 1;
}

int main(){
    int number, i;
    number = 3;
    dis = map;
    floyd(number);
    return number;
}