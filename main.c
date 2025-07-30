#include <stdio.h>
#include <stdlib.h>
#include <windows.h>

extern void compute_acceleration(int rows, float* input_data, int* results);

int main() {
    int rows;

    // Read number of cars
    printf("Enter number of cars: ");
    scanf_s("%d", &rows);

    // Allocate memory for input data and results
    float* input_data = (float*)malloc(rows * 3 * sizeof(float));
    int* results = (int*)malloc(rows * sizeof(int));

    if (!input_data || !results) {
        printf("Memory allocation failed!\n");
        return 1;
    }

    // Read input data
    printf("Enter data for each car (Vi, Vf, T):\n");
    for (int i = 0; i < rows; i++) {
        printf("Car %d: ", i + 1);
        scanf_s("%f, %f, %f", &input_data[i * 3], &input_data[i * 3 + 1], &input_data[i * 3 + 2]);
    }

    // Call assembly function to compute accelerations
    compute_acceleration(rows, input_data, results);

    // Print results
    printf("\nAcceleration values (m/s²):\n");
    for (int i = 0; i < rows; i++) {
        printf("%d\n", results[i]);
    }

    // Cleanup
    free(input_data);
    free(results);

    return 0;
}
