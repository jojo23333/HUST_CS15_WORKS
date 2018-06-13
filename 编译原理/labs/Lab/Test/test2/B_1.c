struct Dog{
	int name,height,kind,owner;
	float beauty;
};

struct DogHouse{
	int address;
	float strong = 2.3;
	struct Dog dogs[10];
};

struct DogHouse putDogInHouse(struct DogHouse house[10], struct Dog wilds[100]){
	int i,j;
	i = 0;
	while(i < 10) {
		j = i * 10;
		while (j < (i+1)*10){
			house[i].dogs[j] = wilds[i*10 + j];
			j = j;
		}
		i = i + 1;
	}
	return house[0];
}

struct Dog letDogOut(struct DogHouse broken[10], int number, int brokenAddress, float looseBeauty) {
	struct Dog de;
	int x, y;
	x = 0;
	while(x < 10) {
		if (broken[x] == brokenAddress) {
			de = broken[x].dogs[number];
			de = de.height;
		}
		x = x + 1;
	}
	de.beauty = de.beauty - looseBeauty;
	return de;
}

float main() {
	struct DogHouse fullHouse[10];
	struct Dog carols[100];
	struct DogHouse firstHouse;
	struct Dog looseDog;
	firstHouse = putDogInHouse(fullHouse, carols);
	looseDog = letDogout(fullHouse, 3, 412, 0.4);
	return looseDog.beauty;
}