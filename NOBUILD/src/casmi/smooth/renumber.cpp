#include "smooth.h"

int AzimuthNeighbour(data *Point)
/* function allocates memory for azimuth to all
   nearest neighbours, calculates it and stores the azimuth in
   ann, azimuth is in radians between 0 and 2pi
   Additionally the memory for the rbin and abin are allocated */
{
   int numnn, i;
   double delta, angle;

   numnn = Point->numnn;

   // free the old memory, the number of neighbours may have changed !
   if ( Point->ann != NULL)  delete Point->ann;
   if ( Point->rbin != NULL) delete Point->rbin;
   if ( Point->abin != NULL) delete Point->abin;

   // allocate memory for storing the azimuths
   if ((Point->ann = new double [numnn+1]) == NULL)  {
       fprintf(stderr, "ERROR: not enough memory to store azimuths\n");
       return -1;
   }

   // allocate memory for storing abin and rbin
   if ( (Point->rbin=new int [numnn+1])==NULL) {
       fprintf(stderr, "ERROR: not enough memory to store bin numbers\n");
       return -1;
   }
   if ( (Point->abin=new int [numnn+1])==NULL) {
       fprintf(stderr, "ERROR: not enough memory to store bin numbers\n");
       return -1;
   }


   for (i=1; i<=numnn; i++)  {    // loop over all neighbours, calculate angle
   // all distances except dnn are in radians on unit sphere,
   // dnn in radians is dnn/EarthRadius
       delta = Point->x1 - Point->nn[i]->x1;

       if (delta*delta < epsilon)  {  // neighbour has the same longitude
				      // we take the square to avoid problems with sign
	  if (Point->x2 > Point->nn[i]->x2) {   // Neighbour is south of point
	     Point->ann[i] = pi;
	  } else {                              // Neighbour is north of point
	     Point->ann[i] = 0.0;
	  }

       } else { // we can use trigonometry on a sphere

	  delta = delta < -1*pi ? delta+2*pi : delta;
	  angle = acos((cos(0.5*pi-Point->nn[i]->x2)-\
		    cos(0.5*pi-Point->x2)*cos(Point->dnn[i]/EarthRadius))\
		    /(sin(0.5*pi-Point->x2)*sin(Point->dnn[i]/EarthRadius)));

	  // we do not want the azimuth to be equal 2pi, this will cause
	  // problems when determing the bin. Azimuth equal 2pi might only happen
	  // if angle is very small ...
	  if (angle > epsilon)  {
	     Point->ann[i] = delta<0 ? angle : 2*pi-angle;
	  }
       }

       if (Point->ann[i] >= 2*pi || Point->ann[i] < 0) {
	   printf("azimuth to %d neighbour %lf \n", i, r2d*Point->ann[i]);
       }
   }
   return 0;
}

int AllocateBin(struct control *pcontrol)
/* function to allocate the bin-array */
{
   int i, j;

   if ( (pcontrol->bin = new int *[pcontrol->nrbin]) == NULL) {
       fprintf(stderr, "ERROR: not enough memory to allocate bin matrix\n");
       return -1;
   }
   //
   for (i=0; i<pcontrol->nrbin; i++)  {
       if ( (pcontrol->bin[i] = new int [pcontrol->nabin]) == NULL) {
	  fprintf(stderr, "ERROR: not enough memory to store bin matrix\n");
	  return -1;
       }
       for (j=0; j<pcontrol->nabin; j++)  {
	  pcontrol->bin[i][j] = 0;
       }
   }
   return 0;
}

int CalcSegmentArea(struct control *pcontrol)
/* FUNCTION NOT USED: function to calculate the area of the segments
   whole area summs up to 1.0
   We only allocate a vector */
{
   int i;

   if ( (pcontrol->SegArea = new double [pcontrol->nrbin]) == NULL)  {
      fprintf(stderr, "ERROR: not enough memory to store segment area\n");
      return -1;
   }

   for (i=0; i<pcontrol->nrbin; i++)  {
      pcontrol->SegArea[i]= 1.0;
      // (2.0*i+1.0)/(pcontrol->nabin*pcontrol->nrbin*pcontrol->nrbin);
   }
   return 1;
}

void SetBinZero(struct control *pcontrol)
/* function sets all elements of the bin to zero */
{
   int i, j;
   for (i=0; i<pcontrol->nrbin; i++) {
       for (j=0; j<pcontrol->nabin; j++)  {
	   pcontrol->bin[i][j] = 0;
       }
   }
}


int CalcBinMatrix(struct control *pcontrol, data *Point)
/* function determing how many obersavations are available in
   the respective segment */
{
    int rbin, abin, i, j;
    double rbinstep, abinstep;
    int AzimuthNeighbour(data *Point);
    void SetBinZero(struct control *pcontrol);

    // calculate the azimuths of all nearest neighbours, return -1 if
    // error occured, here the array for the *ann and the rbin and abin
    // are allocated
    if ( AzimuthNeighbour(Point) < 0)  {
       fprintf(stderr,"ERROR: error occured in function AzimuthNeighbour\n");
       return -1;
    }

    // initialize the bin-matrix with zero
    SetBinZero(pcontrol);

    // determine number of observations in respective segment
    // loop over all neighbours
    rbinstep = pcontrol->nrbin/pcontrol->NNRadius;
    abinstep = pcontrol->nabin/(2*pi);
    for (i=1; i<=Point->numnn; i++)  {
	rbin = Point->rbin[i] = int( Point->dnn[i]*rbinstep);
	abin = Point->abin[i] = int( Point->ann[i]*abinstep);
	pcontrol->bin[rbin][abin]++;
    }
    
    // determine the number of used bins
    for (i=0, pcontrol->UsedBins=0; i<pcontrol->nrbin; i++)  {
        for (j=0; j<pcontrol->nabin; j++)  {
            if (pcontrol->bin[i][j] > 0) pcontrol->UsedBins++;
        }
    }        
    return 1;
}
