int a[20][20];

struct Type{
	int name[20];
	int hair[20];
};

int main() {
	int i, N, sum;
	struct Type t;
	i = 0;
	N = 10;
	sum = 0;
	while(i < N){
		t.name[i] = a[i][i];
		t.hair[i] = a[i][N - i - 1];
		i = i + 1;
	}
	while(i >= 0){
		sum = sum + t.name[i] * t.hair;
		i = i - 1;
	}
	return sum;
}
