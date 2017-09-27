#include <stdio.h>
#include <stdlib.h>

void printArr(int arr[], int dim);

/**este mai rapida decat bubble sort */
void selectionSort(int arr[], int dim){
    int i, j, pozitie ;

    for(i=0; i<dim; i++){
        pozitie = i;
        for(j=i; j<dim; j++){
            if(arr[pozitie]>arr[j]){
                pozitie=j;
            }
        }
        int temp = arr[i];
        arr[i] = arr[pozitie];
        arr[pozitie]=temp;
    }
    printArr(arr, dim);
}

void bubbleSort(int arr[], int dim){
    int i,j;
    int temp;

    for(i=0; i<dim; i++){
        for(j=0; j<dim-1; j++){
            if(arr[j]>arr[j+1]){
                temp = arr[j+1];
                arr[j+1]= arr[j];
                arr[j] = temp;
            }
        }
    }
    printArr(arr, dim);
}

void printArr(int arr[], int dim){
    int i;
    for(i=0; i<dim; i++){
        printf("myArr[%d] = %d \n", i, arr[i]);
   }
}

int main()
{
    printf("Hello world!\n");

    int myArr[15] ={34,55,67,34,56,67,23,21,25,45,34,39,2,1,20};
    printArr(myArr, 15);
    puts("SORTARE BUBBLE SORT");
    bubbleSort(myArr,15);
    puts("SORTARE PRIN SELECTIE");
    selectionSort(myArr, 15);

    return 0;
}
