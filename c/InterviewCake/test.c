/* #include "test.h" */

/* int main() { */
/*   for (int i = 0; i < somedata_rows; i++) { */
/*     printf("%2d %7s ", i, somedata_h(i, "nb")); */
/*     for (int j = 1; j < somedata_cols; j++) { */
/*       const char *cell = somedata[i][j]; */
/*       printf("%5s %5g ", cell, 1000 * atof(cell)); */
/*     } */
/*     printf("Fuck\n"); */
/*   } */
/*   return 0; */
/* } */

int items[] = {1, 2, 3};

void printFirstItem(const int *items) { printf("%d\n", items[0]); }
