#include "smooth.h"


int sort_function_dist(const void *a, const void *b)
/* sort function used for qsort-ing for distance, function FindNN */
{
  double diff;      
  struct sort *A = (struct sort *)a;
  struct sort *B = (struct sort *)b;

  if( (diff = A->dist - B->dist) > 0.0)  {
    return 1;
  } else if ( diff < 0.0) {
    return -1;
  } else {
    return 0;
  }
}

int set_actpoint_at_zero(struct sort *NN, int index)
/* set a point with a given index at the zero position.
   This function is needed if several points with the same coordinates 
   exist in the database. In this case it might occure, that the actual
   point itself is not at position zero after sorting for distance. 
   In this case the function switches 
   the actual point (index) with the point at position zero. */
{ 
  int i = 0;
  struct sort dummy;
  
  // search at which position the Point with the given index is stored
  while (NN[i].indexnn != index) {
     i++;
  }
  
  // i is the position where the Point is stored, we want it to be zero
  // if it is not we have to switch the two points
  if (i != 0) {
     dummy.indexnn = NN[0].indexnn;
     dummy.pointer = NN[0].pointer;
     dummy.dist = NN[0].dist;
     
     NN[0].indexnn = NN[i].indexnn;
     NN[0].pointer = NN[i].pointer;
     NN[0].dist = NN[i].dist;
     
     NN[i].indexnn = dummy.indexnn;
     NN[i].pointer = dummy.pointer;
     NN[i].dist = dummy.dist;
     
     // if (debug) 
       // fprintf(stdout, "Swapped point at position %d with point at position zero\n", i);
        
  } 
  return 0;  
} 


int sort_function_indexnn(const void *a, const void *b)
/* sort function used for qsort-ing for distance, function FindNN */
{
  struct sort *A = (struct sort *)a;
  struct sort *B = (struct sort *)b;

  return ( A->indexnn - B->indexnn);
}

int sort_function_residuals(const void *a, const void *b)
/* sort function used for qsort-ing for residuals, function UpdateDelta */
{
  double diff = *((double *)a) - *((double *)b);

  if( diff > 0.0)  {
    return 1;
  } else if ( diff < 0.0) {
    return -1;
  } else {
    return 0;
  }
}

int sort_function_index(const void *a, const void *b)
/* sort function used for qsort-ing for index, function smooth
   this brings the datas in the same order they had after reading */
{
  struct data **A = (struct data **)a;
  struct data **B = (struct data **)b;
  return ((*A)->index - (*B)->index);
}


int sort_function_x1(const void *a, const void *b)
/* sort function used for qsort, function returns value larger/equal/less 0
   if x1 of datastructure on which a points is larger/equal/less than x1 of
   datastructure on which b points */
{
  // definition
  int WriteData(FILE *out, struct data **P, int NoPoints);
  struct data **PointerA;
  struct data **PointerB;
  double diff;

  PointerA = (struct data**) a;
  PointerB = (struct data**) b;

  if( (diff = (*PointerA)->x1 - (*PointerB)->x1) > 0.0)  {
    return 1;
  } else if ( diff < 0.0) {
    return -1;
  } else {
    return 0;
  }
}



int sort_function_x2(const void *a, const void *b)
/* sort function used for qsort, function returns 1/0/-1
   if x1 of datastructure on which a points is larger/equal/less than x1 of
   datastructure on which b points */
{
  // definition
  int WriteData(FILE *out, struct data **P, int NoPoints);
  struct data **PointerA;
  struct data **PointerB;
  double diff;

  PointerA = (struct data**) a;
  PointerB = (struct data**) b;

  if( (diff = (*PointerA)->x2 - (*PointerB)->x2) > 0.0)  {
    return 1;
  } else if ( diff < 0.0) {
    return -1;
  } else {
    return 0;
  }
}


