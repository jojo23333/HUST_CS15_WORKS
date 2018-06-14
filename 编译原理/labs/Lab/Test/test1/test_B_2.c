struct Result{
int i;
int j;
}text1, text2; text3;

int gcd(int a, int b) {
    if (b == 0)
    return a;
    else
    return gcd(b, a % b);
}


int main() {
    struct Result six;
    int x1, x2;

    x1 = 1;
    x2 = 7;
    six.i = 7;
    six.j = six.i + text1.i - 3;
    if (six.j < text2.j) {
        retun six.j + 3;
    }

    x1 = 14;
    x2 = 21;
    while(x1 < x2) {
        x1 = x1+ gcd(x1, x2);
    }

    return x1 > 3 x2;
}