#include "smooth.h"

int default_error(int parameter)
{
  fprintf(stderr, "ERROR: undefined paramter %c \n", parameter);
  fprintf(stderr, "Run program without parameters to get information about available parameter \n");
  return (-1);
}

int InfoControl(struct control *pcontrol)
/* write the actual setting of control to stdout */
{  
   char *pdummychar;
   char *exchangeExt(char *name, const char *ext);
   
   fprintf(stdout, "INFO:\n    lambda is set to %.2lf \n", pcontrol->Lambda);

   if (pcontrol->ConstNNNumber == TRUE)  {
      fprintf(stdout, "    using constant number of neighbours method for smoothing \n");
      fprintf(stdout, "    using the %d nearest neighbours for smoothing\n", pcontrol->NNNumber);
   }

   if (pcontrol->ConstNNRadius == TRUE)  {
      fprintf(stdout, "    using constant radius method for smoothing \n");
      fprintf(stdout, "    data within radius of %.3lf km are used for smoothing \n", pcontrol->NNRadius);
   }

   if( pcontrol->DistanceWeight == twf )  {
       fprintf(stdout, "    using tricubic weights for smoothing \n");
   } else if (pcontrol->DistanceWeight == rtwf )  {
       fprintf(stdout, "    using rescaled tricubic weights for smoothing \n");
   } else if (pcontrol->DistanceWeight == ntwf )  {
       fprintf(stdout, "    using number normalized tricubic weights for smoothing \n");
   } else if (pcontrol->DistanceWeight == nbtwf )  {
       fprintf(stdout, "    using number and bin normalized tricubic weights for smoothing \n");
   } else if (pcontrol->DistanceWeight == nid )  {
       fprintf(stdout, "    using power distance weights for smoothing \n");
       fprintf(stdout, "    power of distance %d\n", pcontrol->nid_power);     
   } else if (pcontrol->DistanceWeight == rnid )  {
       fprintf(stdout, "    using rescaled power distance weights for smoothing \n");
       fprintf(stdout, "    power of distance %d\n", pcontrol->nid_power);     
   } else if (pcontrol->DistanceWeight == nnid )  {
       fprintf(stdout, "    using number normalized power distance weights for smoothing \n");
       fprintf(stdout, "    power of distance %d\n", pcontrol->nid_power);     
   } else if (pcontrol->DistanceWeight == nbnid )  {
       fprintf(stdout, "    using number and bin normalized power distance weights for smoothing \n");
       fprintf(stdout, "    power of distance %d\n", pcontrol->nid_power);     
   }

   if (pcontrol->Robustness == TRUE) {
      fprintf(stdout, "    using robustness checking \n");
   }

   if (pcontrol->UseQuality == TRUE)  {
      fprintf(stdout, "    using quality information of data\n");
      fprintf(stdout, "    weights for A-quality=%.2f, B-quality=%.2f, C-quality=%.2f, D-quality=%.2f\n", \
                      pcontrol->Aquality, pcontrol->Bquality, pcontrol->Cquality, pcontrol->Dquality);
   } else {
      fprintf(stdout, "    ignoring quality information of the data\n");
   }

   if (pcontrol->SmoothPoints == TRUE)  {
      pdummychar = exchangeExt(pcontrol->FileOut, sdat);
      fprintf(stdout, "    smoothed datapoints will be written to file %s\n", pdummychar);
   }
      
   if (pcontrol->Gridmap == TRUE)  {
      pdummychar = exchangeExt(pcontrol->FileOut, grdm);
      fprintf(stdout, "    gridded map will be written to file %s\n", pdummychar);
      fprintf(stdout, "    gridding increment is %.2f deg longitude and %.2f deg latitude \n", r2d*pcontrol->Gridmap_xinc, r2d*pcontrol->Gridmap_yinc);
   }

   if (pcontrol->IgnorePoint != FALSE)  {
      if (pcontrol->IgnorePoint == ignore_n)  {
        fprintf(stdout, "    smoothed points will be calculated if at least\n");
        fprintf(stdout, "    %.0f points within search radius are available \n", pcontrol->IgnoreNum);
      } else if (pcontrol->IgnorePoint == ignore_w)  {
        fprintf(stdout, "    smoothed points will be calculated if sum of all \n");
        fprintf(stdout, "    weights is at least %.3f \n", pcontrol->IgnoreNum);
      } else if (pcontrol->IgnorePoint == ignore_q)  {
        fprintf(stdout, "    smoothed points will be calculated if sum of quality \n");
        fprintf(stdout, "    weights is at least %.3f \n", pcontrol->IgnoreNum);
      }
   }

   if (pcontrol->Trajectories == TRUE)  {
      pdummychar = exchangeExt(pcontrol->FileOut, trjs);
      fprintf(stdout, "    trajectories will be written to file %s\n", pdummychar);
      if (pcontrol->InteractiveTrajectories) {
        fprintf(stdout, "    startpoints for trajectories are taken from stdin\n");
      } else {     
        fprintf(stdout, "    startpoints for trajectories are taken from file %s\n", pcontrol->FileTrajecStart);
      }
      fprintf(stdout, "    calculating trajectory every %.3lf km\n", pcontrol->TrajStep * EarthRadius);
   }
   
   return 0;

}


int ReadData(FILE *in, struct control *pcontrol, struct data **P)
/* function reading data from inputfile;
   assumed file format is: lat lon azimut type quality dummy ...
   datalines with quality E are ignored, all other data are stored in a
   structure of type data.
   Maximum number of lines which can be stored is MaxData (defined in
   smooth.h). Function returns the number of datastructures which were
   allocated  */
{
  char line[MaxCharInLine] = " ";
  int i, linenum, ignoreline;
  double lat, lon, azim;
  char type[5], quality[2];

  i=0;
  linenum=0;
  ignoreline = 0;
  while ( (fgets(line, MaxCharInLine-1, in)) != 0 ) {
     linenum++;

     sscanf(line, "%lf %lf %lf %s %s", &lat, &lon, &azim, type, quality);

     // ignore datalines with quality E
     if (quality[0]=='A' || quality[0]=='B' || quality[0]=='C' || quality[0]=='D')  {
        
	if (!(P[i] = new data)) {
	   fprintf(stderr,"ERROR: not enough memory for datastructure %d\n", i);
	   return -1;
	}

	P[i]->index = i;

        // check if input data have the right longitude format 
	if ( lon >= -180.0 && lon <= 180.0 ) {
           P[i]->x1 = d2r*lon;
        } else if ( lon > 180.0 && lon <= 360.0 )  {
	   P[i]->x1 = d2r*(lon - 360.0);
           fprintf(stdout, "WARNING: datapoint in line %d did not have the correct input format\n", linenum);
	   fprintf(stdout, "      corrected from %lf to %lf \n", lon, r2d*P[i]->x1);
        } else {
           ignoreline=1;
           fprintf(stderr, "SERIOUS WARNING: datapoint in line %d has suspicious longitude value \n", linenum);
        }   

        // check if input data have the right latitude format 
	if ( lat >= -90.0 && lat <= 90.0 ) {
           P[i]->x2 = d2r*lat;
        } else {
           ignoreline=1;
           fprintf(stderr, "SERIOUS WARNING: datapoint in line %d has suspicious latitude value \n", linenum);
        }   

        // check if azimut is in the right format
	if ( azim >= -180.0 && azim <= 360.0 ) {
	   P[i]->y1 = sin(d2r*azim);
	   P[i]->y2 = cos(d2r*azim);
        } else {
           ignoreline=1;
           fprintf(stderr, "SERIOUS WARNING: datapoint in line %d has suspicious azimut value \n", linenum);
        }   
        
        // check also if one or more of the quality weightings are set to 0.0
	switch (quality[0]) {
	     case 'A':
	         if (pcontrol->Aquality == 0.0) ignoreline=2;
		 P[i]->quality = pcontrol->Aquality;
		 break;
	     case 'B':
	         if (pcontrol->Bquality == 0.0) ignoreline=2;
		 P[i]->quality = pcontrol->Bquality;
		 break;
	     case 'C':
	         if (pcontrol->Cquality == 0.0) ignoreline=2;
		 P[i]->quality = pcontrol->Cquality;
		 break;
	     case 'D':
	         if (pcontrol->Dquality == 0.0) ignoreline=2;
		 P[i]->quality = pcontrol->Dquality;
		 break;
	}

	// check if maximum number of storeable data structures is reached or if wrong values were found
	if (ignoreline == 1) {
           fprintf(stderr, "                 ... ignoring this line  \n");
           ignoreline = 0;
        } else if (ignoreline == 2) {
           // if (pcontrol->verbose) fprintf(stdout, "                 ... quality weight for quality %c is 0.0, ignoring this line \n", quality[0]);
           ignoreline = 0;
        } else if (i < MaxData-1)  {
	   i++;
	} else {
	   fprintf(stderr, "ERROR: Inputfile contains to much data\n");
	   fprintf(stderr, " Maximum number of datalines (except E-quality data) is %d\n",MaxData);
	   fprintf(stderr, " Either reduce your input data, or change the parameter \n");
	   fprintf(stderr, " MaxData in the file smooth.h and recompile the program.\n\n");
	   return -1;
	}
     }
  }
  fprintf(stdout, "    inputfile contains %d lines with usable data\n", i);
  return i;
}


int WriteData(FILE *out, struct data **P, int NoPoints)
/* function not used */
{
  int i;
  for (i=0; i < NoPoints; i++)  {
      fprintf(out, "number in array: %d index: %d x1: %lf x2: %lf quality: %f \n", i, P[i]->index, r2d*P[i]->x1, r2d*P[i]->x2, P[i]->quality);
  }
  return 0;
}

int WriteDataPoints(FILE *out, struct control *pcontrol, struct data **P)
/* function not used */
{
  int i;
  
  // write header in file
  fprintf(out, "# Smooth inputfile: %s, lambda: %lf, Method: , \n", pcontrol->FileIn, pcontrol->Lambda); 

  for (i=0; i < pcontrol->NoPoints; i++)  {
      fprintf(out, "%lf %lf %lf %s %s %s\n", r2d*P[i]->x2, r2d*P[i]->x1, r2d*atan(P[i]->f1/P[i]->f2), "BO", "A", "U");
  }
  return 0;
}


int GiveBoundaries(struct data **X1, struct data **X2, struct control *pcontrol)
/* function writing the maximum and minimum in x1 and x2 direction to
   stdout and to the control structure */
{
  pcontrol->x1min = X1[0]->x1;
  pcontrol->x1max = X1[pcontrol->NoPoints-1]->x1;
  pcontrol->x2min = X2[0]->x2;
  pcontrol->x2max = X2[pcontrol->NoPoints-1]->x2;
  fprintf(stdout, "    datapoints range from %.2f to %.2f deg longitude\n", r2d*pcontrol->x1min, r2d*pcontrol->x1max);
  fprintf(stdout, "                 and from %.2f to %.2f deg latitude\n", r2d*pcontrol->x2min, r2d*pcontrol->x2max);

  if (!pcontrol->UserBoundaries) { // round to full degrees
     pcontrol->west = d2r*floor(r2d*pcontrol->x1min);
     pcontrol->east = d2r*ceil(r2d*pcontrol->x1max);
     pcontrol->south = d2r*floor(r2d*pcontrol->x2min);
     pcontrol->north = d2r*ceil(r2d*pcontrol->x2max);
  }   
   
  if (pcontrol->Trajectories || pcontrol->Gridmap) {
     fprintf(stdout, "    gridmap and/or trajectories will be calculated \n");
     fprintf(stdout, "                 from %.2f to %.2f deg longitude and \n", r2d*pcontrol->west, r2d*pcontrol->east);
     fprintf(stdout, "                 from %.2f to %.2f deg latitude\n", r2d*pcontrol->south, r2d*pcontrol->north);
  }   
  return 0;
}


double Distance(struct data *p1, struct data *p2) 
/* function to calculate the distance between to points on the earth in km,
   note that x1 and x2 are already in radians
   assuming that EarthRadius is also given in km */ 

{
  double a[3], b[3];
  double dotproduct;
  double angle;
  int i;

  // transform the points on the sphere to vector in carthesian coordinates
  // calculate on unity sphere
  a[0] = cos(p1->x2) * cos(p1->x1);
  a[1] = cos(p1->x2) * sin(p1->x1);
  a[2] = sin(p1->x2);

  b[0] = cos(p2->x2) * cos(p2->x1);
  b[1] = cos(p2->x2) * sin(p2->x1);
  b[2] = sin(p2->x2);

  // angle between the two vectors
  for (i=0, dotproduct = 0; i<3; i++)  {
     dotproduct+= a[i]*b[i];
  }
  // check if due to rounding effects dotproduct is 
  // larger 1 or smaller -1
  if ( dotproduct > 1.0 ) {
     // if (debug) fprintf(stdout, " corrected dotproduct from %.10lf to 1.0 \n", dotproduct);
     dotproduct = 1.0;
  } else if (dotproduct < -1.0)  {
     // if (debug) fprintf(stdout, " corrected dotproduct from %.10lf to -1.0 \n", dotproduct);
     dotproduct = -1.0;
  }
  angle = acos(dotproduct);
  double dist = angle * EarthRadius;
  return (dist);
}  


double Distance(struct point *p1, struct point *p2) 
/* function to calculate the distance between to points on the earth in km,
   note that x1 and x2 are already in radians
   assuming that EarthRadius is also given in km */ 

{
  double a[3], b[3];
  double dotproduct;
  double angle;
  int i;

  // transform the points on the sphere to vector in carthesian coordinates
  // calculate on unity sphere
  a[0] = cos(p1->x2) * cos(p1->x1);
  a[1] = cos(p1->x2) * sin(p1->x1);
  a[2] = sin(p1->x2);

  b[0] = cos(p2->x2) * cos(p2->x1);
  b[1] = cos(p2->x2) * sin(p2->x1);
  b[2] = sin(p2->x2);

  // angle between the two vectors
  for (i=0, dotproduct = 0; i<3; i++)  {
     dotproduct+= a[i]*b[i];
  }
  // check if due to rounding effects dotproduct is 
  // larger 1 or smaller -1
  if ( dotproduct > 1.0 ) {
     if (debug) fprintf(stdout, " corrected dotproduct from %.10lf to 1.0 \n", dotproduct);
     dotproduct = 1.0;
  } else if (dotproduct < -1.0)  {
     if (debug) fprintf(stdout, " corrected dotproduct from %.10lf to -1.0 \n", dotproduct);
     dotproduct = -1.0;
  }
  angle = acos(dotproduct);
  double dist = angle * EarthRadius;
  return (dist);
}  


int FindNNForAllData(control *pcontrol, data **P, data **X1, data **X2)
/* find nearest neighbours for all datapoints
   if control.ConstNNNumber is set to true, we search for the control.NNNumber
   neighbours and calculate the distance. If control.ConstNNRadius is set to 
   true, we calculate the distance to all other datapoints and take all those
   datapoints which are not more than NNRadius away. The number of the nearest
   neighbours is stored in P[].numnn */
{
  int elemNN;
  struct sort *NN;
  int FindNNConstNNNumber(control *pcontrol, sort *NN, int elemNN, data *Point, data **X1, data **X2);
  int FindNNConstNNRadius(control *pcontrol, sort *NN, int elemNN, data *Point, data **P);
  
  if (pcontrol->ConstNNNumber == TRUE)  {

     // allocate 1d-array to store distance to the respective neighbours
     // we have to check the +/-NNNumber neighbours in X1 and X2
     // results in 4 * NNNumber + 2
     elemNN = 4*pcontrol->NNNumber + 2;
     
  } else if (pcontrol->ConstNNRadius == TRUE)  {
     
     // allocate 1-d array 
     elemNN =  pcontrol->NoPoints;
  
  } else {
     fprintf(stderr, "ERROR: how did you manage to reach this point ?\n");
     return -2;
  }
  
  NN = (struct sort *) malloc(sizeof(struct sort)*elemNN);
  if ( NN == NULL )  {
     fprintf(stderr, "ERROR: not enough memory for determing nearest neighbours\n");
     return -1;
  }
     
  // loop over all datapoints
  for (int i=0; i < pcontrol->NoPoints; i++)  {
     // determine the nearest neighbours for the actual datapoint
     if (pcontrol->verbose) {
        if (i == 0) {
           fprintf(stdout, "    of point %6d", P[i]->index+1);
           fflush(stdout);
        } else {
           fprintf(stdout, "\b\b\b\b\b\b%6d", P[i]->index+1);
           fflush(stdout);
        }
        if (i == pcontrol->NoPoints-1) {
           fprintf(stdout, "\n");
        }
     }
     if (pcontrol->ConstNNNumber)  {    
       if (FindNNConstNNNumber(pcontrol, NN, elemNN, P[i], X1, X2) != 0)  {
          fprintf(stderr, "ERROR: occured in function FindNNConstNNNumber called for datapoint %d\n", i);
	  return -1;
       }
     } else if (pcontrol->ConstNNRadius)  {    
       if (FindNNConstNNRadius(pcontrol, NN, elemNN, P[i], P) != 0)  {
          fprintf(stderr, "ERROR: occured in function FindNNConstNNRadius called for datapoint %d\n", i);
	  return -1;
       }
     }
       
  }
  
  free (NN);
          
  return 0;
}


int FindNNConstNNRadius(struct control *pcontrol, struct sort *NN, int elemNN, struct data *Point, struct data **P)
/* function to calculate the nearest neighbours of the actual point.
   The neighbours used have a distance less or equal NNRadius. 
   The pointer to the actual point itself is stored in nn[0].
   Write pointer to the respective neighbour in the array on which nn points,
   the distance to the respective neighbour in the array to which dnn points
   (the arrays are allocated in this function) */
{
   double Distance(struct data *p1, struct data *p2);
   int sort_function_dist(const void *a, const void *b);
   int set_actpoint_at_zero(struct sort *NN, int index);
   int i;
      
   // calculate the distance to all other points, including to itsself
   for(i = 0; i<pcontrol->NoPoints; i++)  {
      NN[i].dist = Distance(Point, P[i]);
      NN[i].indexnn = P[i]->index;        // needed for set_actpoint_at_zero
      NN[i].pointer = P[i];               // copy pointer of this point
   }

   // sort the NN array for increasing distance, the point itself should 
   // have a distance zero to itself, therefor be at position 0. 
   // call function set_actpoint_at_zero to ensure this.
   qsort(NN, elemNN, sizeof(struct sort), sort_function_dist);
   set_actpoint_at_zero(NN, Point->index);
   
   // find out how many neighbours lie within distance less NNRadius
   // at version 2.1: changed '>' to '>='. The neighbour at distance NNRadius
   // will be assigned a weight of zero, we do not want it.
   // it might cause problems when determing the bins
   for( i=0; i<pcontrol->NoPoints; i++) {
      if (NN[i].dist >= pcontrol->NNRadius) break;
   }
   
   // point at position 0 is the point itself and counts as its 0.th neighbour
   // different to function FindNNP, there the 0.th neighbour does not exist.
   Point->numnn = i-1;
 
   // if (debug) fprintf(stdout, "Number of neighbours: %d for point \n", Point->numnn);
   
   // allocate the memory to store pointer to neighbours and the distance
   // each point is its own 0-th neighbour
   Point->nn = new data *[Point->numnn+1];
   Point->dnn = new double [Point->numnn+1];
   if (Point->nn == NULL || Point->dnn == NULL)  {
      fprintf(stderr, " ERROR: not enough memory to store information about neighbours\n");
      return -1;
   }

   // take the NNNumber neighbours from sort array NN, points occuring more than once are
   // already removed
   for (i=0; i <= Point->numnn; i++)  {
       Point->nn[i] = NN[i].pointer;
       Point->dnn[i]  = NN[i].dist;
   }     
   
   return 0;
}


int FindNNConstNNNumber(struct control *pcontrol, struct sort *NN, int elemNN, struct data *Point, struct data **X1, struct data **X2)
/* function to calculate the nearest neighbours of the actual point,
   write pointer to the respective neighbour in the array on which nn points,
   the distance to the respective neighbour in the array to which dnn points
   (the arrays are allocated in this function) */
{
   int NNNumber = pcontrol->NNNumber;
   double Distance(struct data *p1, struct data *p2);
   int sort_function_dist(const void *a, const void *b);
   int sort_function_indexnn(const void *a, const void *b);
   int i;
   int cix1, cix2, ix1, ix2;
      
   // calculate the distance to the neighbours in x1 direction
   for(i = 0, ix1 = Point->ix1 - NNNumber; ix1 <= Point->ix1 + NNNumber; ix1 ++)  {
      // Point->ix1 ranges from 0 to NNNumber-1, thus up to here
      // ix1 can range from -NNNumber to NoPoints-1+NNNumber.
      // This is not correct. For ix1 smaller than 0 we want to calculate the
      // distance to the points at the end of the X1 array (360 degree
      // periodicity) for those over NoPoints-1 we calculate the distance to
      // the points at the beginning of the array X1.
      // calculate circular index cix1.
      cix1 = (ix1 + pcontrol->NoPoints) % pcontrol->NoPoints;
      NN[i].dist = Distance(Point, X1[cix1]);
      NN[i].indexnn = X1[cix1]->index;  // copy index of this point
      NN[i++].pointer = X1[cix1];       // copy pointer of this point
   }

   // calculate the distance to the neighbours in x2 direction
   for(ix2 = Point->ix2 - NNNumber; ix2 <= Point->ix2 + NNNumber; ix2 ++)  {
      // calculate circular index cix2.
      cix2 = (ix2 + pcontrol->NoPoints) % pcontrol->NoPoints;
      NN[i].dist = Distance(Point, X2[cix2]);
      NN[i].indexnn = X2[cix2]->index;  // copy index of this point
      NN[i++].pointer = X2[cix2];       // copy pointer of this point
   }

   // now we have to eleminate the points which occure more than once
   // sort the NN array for indexnn (index of the neighbour, stored in datastructure)
   qsort(NN, elemNN, sizeof(struct sort), sort_function_indexnn);
   
   // set the distance for all points which occure the second time to FarPoint
   // FarPoint is defined in smooth.h (FarPoint = pi * EarthRadius)
   for (i=1; i < elemNN; i++)  {
      // if two points have the same index, move the second point out of the way
      if (NN[i].indexnn == NN[i-1].indexnn) {
          NN[i].dist = FarPoint;
      }
   }

   // sort the NN array for increasing distance
   qsort(NN, elemNN, sizeof(struct sort), sort_function_dist);

   // allocate the memory to store pointer to neighbours and the distance
   // each point is its own 0-th neighbour
   Point->nn = new data *[NNNumber+1];
   Point->dnn = new double [NNNumber+1];
   if (Point->nn == NULL || Point->dnn == NULL)  {
      fprintf(stderr, " ERROR: not enough memory to store information about neighbours\n");
      return -1;
   }

   // take the NNNumber neighbours from sort array NN, points occuring more than once are
   // already removed
   for (i=0; i <= NNNumber; i++)  {
       Point->nn[i] = NN[i].pointer;
       Point->dnn[i]  = NN[i].dist;
   }     
   
   // store the number of 
   Point->numnn = i - 1;

   return 0;
}

double Norm(double xcomp, double ycomp)
/* calculate the norm of a 2-dimensional vector */
{
   return sqrt(xcomp*xcomp + ycomp*ycomp);
}


char *exchangeExt(char *name, const char *ext)
/* function to exchange the extension of a file, 
   if name has no extension, .ext is appended
   function returns pointer to newname */
{
   char *lastpoint;       // pointer on last "." in filename
   char *newname;
   char *copyname;        // copy of name, we can not modify name   
   size_t lengthname;     // length of string name
   size_t lengthext;      // length of extension
   
   // determine length of name
   lengthname = strlen(name);
   
   // make a copy of name, name might still be needed in main
   if ( (copyname = new char [lengthname+1]) == NULL)  {
         fprintf(stderr, "ERROR: while allocating memory\n");
         return NULL;
   }
   copyname[0] = '\0';
   strcpy(copyname, name);

   // determine length of ext
   lengthext = strlen(ext);
   
   // allocate memory for newname, in the 'worst case' we need the whole space   
   if ( (newname = new char [lengthname+lengthext+2]) == NULL)  {
         fprintf(stderr, "ERROR: while allocating memory\n");
         return NULL;
   }
   newname[0] = '\0';
   
   // find last point in copyname if there is any
   if( (lastpoint = strrchr(copyname, '.')) != NULL )  {  // there is a point in name
     
      // check if old and new extension are different

      if (strcmp( (lastpoint+1), ext) == 0 )  {  // same extension, just add extension
         strcpy(newname, copyname);
         strcat(newname, ".");
         strcat(newname, ext);
         
         return newname;

      } else {
         
         // write a \0 in copyname, so that we have a new end
         *(lastpoint+1) = '\0';
         strcpy( newname, copyname);
         strcat( newname, ext);
         
         return newname;
         
      }

   } else {   // name has no extension
         
      strcpy(newname, copyname);     
      strcat(newname, ".");
      strcat(newname, ext);
         
      return newname;
          
   }
       
}


/*
int matherr(struct exception *x)
{ 
  char *sterr;
  if (!strcmp(x->name,"pow")) {
     fprintf(stdout, "FUNCTION: %s\n",x->name);
     switch (x->type) {
        case DOMAIN:
            fprintf(stdout, "Vero: DOMAIN error occured in function %s\n", x->name);
            sterr = strerror (EDOM);
            if (isnan(x->arg1)) fprintf(stdout, "vero: arg1 is a NaN\n");
            if (isnan(x->arg2)) fprintf(stdout, "vero: arg2 is a NaN\n");
            fprintf(stdout, " vero: %s failed: %s\n",x->name, sterr);
            fprintf(stdout, "vero: called with arguments %le and %le\n", x->arg1, x->arg2);
            fprintf(stdout, "vero: the return value is %le\n", x->retval);
     }
  } else {
     fprintf(stdout, "Vero: DOMAIN error occured in function %s\n", x->name);
     sterr = strerror (EDOM);
     fprintf(stdout, "vero: %s failed: %s\n",x->name, sterr);
     fprintf(stdout, "vero: arg1 is %le\n", x->arg1);
     fprintf(stdout, "vero: arg2 is %le\n", x->arg2);
  }   
  return 0;
}  
*/       