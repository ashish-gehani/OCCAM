#include<stdio.h>

int mul (int arg1, int arg2){

	int result = arg1*arg2;
	return result;

}
int add(int arg1, int arg2){

	int result = mul(arg1,arg2) + arg1 + arg2;
	return result;
}


int main(){

	int num1 = 2232;
	int num2 = 3321;
	int result = add(num1,num2);

	return result;
}
