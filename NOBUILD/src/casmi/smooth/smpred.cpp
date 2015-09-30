#include "smooth.h"


int FindNNP(struct control *pcontrol, struct sort *NN, data *Point, data **P)
/* find the nearest neighbours, store the pointers to the nearest neighbours
   and the distance in the arrays nn and dnn (these are allocated in this 
   function ). NN is used as sorting array and allocated in the function 
   calling FindNNP. Function returns 1 if no nearest neighbours were found, 
   returns -1 if error occured.
   This function is only called when writing GridMaps or Trajectories, for
   writing SmoothedDataPoints the nearest neighbours of the datapoints 
   and the weights are already known */
{
   int i;
   double Distance(data *Point, data *P2);
   int sort_function_dist(const void *a, const void *b);
   
   // calculate the distance to all points in the array P
   for(i = 0; i<pcontrol->NoPoints; i++)  {
      NN[i].dist = Distance(Point, P[i]);
      NN[i].pointer = P[i];              // copy pointer of this point
   }

   // sort the NN array for increasing distance
   qsort(NN, pcontrol->NoPoints, sizeof(struct sort), sort_function_dist);

   if (pcontrol->ConstNNRadius)  {
   
      // find out how many neighbours lie within distance less NNRadius
      // in version 2.1: changed '>' to '>='. The neighbour at distance
      // NNRadius will be assigned a weight of zero, we do not need it
      for( i=0; i<pcontrol->NoPoints; i++) {
	 if (NN[i].dist >= pcontrol->NNRadius) break;
      }
      
      // the point at NN[0] counts as 1.st nearest neighbour, therefore numnn is i
      Point->numnn = i;
      
      // check if we have any nearest neighbours, if not return 1
      if (Point->numnn == 0) {
          return 1;
      }    
      
   } else if (pcontrol->ConstNNNumber)  {
      
      Point->numnn = pcontrol->NNNumber;
      
   }   

   // delete the memory to which the 'old' pointer points
   // we have to do this, because the number of nearest neighbours may 
   // change when using ConstNNRadius
   if (Point->nn != NULL) delete Point->nn;
   if (Point->dnn != NULL) delete Point->dnn;
   
   // allocate the memory to store pointer to neighbours and the distance
   // normally each point is its own 0-th neighbour, but for calculation of smoothing
   // predictor for GridMaps and Trajectories there is no 0-th neighbour !!!
   Point->nn = new data *[Point->numnn+1];
   Point->dnn = new double [Point->numnn+1];
   if (Point->nn == NULL || Point->dnn == NULL)  {
      fprintf(stderr, " ERROR: not enough memory to store information about neighbours\n");
      return -1;
   }

   // take the Point->numnn neighbours from sort array NN
   // first neighgbour is at point NN[0], the pointer and the distance to this 
   // point is stored at nn[1], dnn[1] respectively.
   // This is all a bit confusing, but the grid location is not part of the input data

   for (i=1; i <= Point->numnn; i++)  {
       Point->nn[i] = NN[i-1].pointer;
       Point->dnn[i]  = NN[i-1].dist;
   }     
   
   return 0;
}
   


int CalcWeightsP(struct control *pcontrol, data *Point)
/* function calculating the weights when calculating the prediced f^ 
   This function is only called when writing GridMaps or Trajectories, for
   writing SmoothedDataPoints the nearest neighbours of the datapoints 
   and the weights are already known 
   The nearest neighbours are stored in 1..numnn, 0 is empty!! */
{
   int j, k, numnn;
   double hx, A;
   int CalcBinMatrix(struct control *pcontrol, data *Point);

   // define some abbreviations
   numnn = Point->numnn;
   
   // free the old memory, the number of neighbours may have changed !
   if ( Point->wnn != NULL)  delete Point->wnn;

   // allocate memory for storing the weights
   if ( (Point->wnn = new double [numnn+1]) == NULL)  {
	fprintf(stderr, "ERROR: not enough memory to store weighting factors\n");
	return -1;
   }

   // set the weight of wnn[0] to 0.0, we have no 0.th nearest neighbour
   // no point itself (evtl. pointer ebenfalls NULL VERO)
   Point->wnn[0] = 0.0;
   
   if (numnn == 0) {   // should not happen ... 

      if (debug) fprintf(stdout, " No neighbours for location %f %f \n", r2d*Point->x1, r2d*Point->x2);
      return 1;
      
   } else {            // there is at least one nearest neighbour
          
      if (pcontrol->ConstNNNumber == TRUE)  {       // constant number of nearest neighbours
         // normalize distance with euclidean distance to the furthest point.
         // (Hanson and Mount: h(x))
         hx=Point->dnn[numnn];
      
         if ( hx <= epsilon) {
            // all neighbours are at the same location as the point where we calculate
            // stress direction

            // weights of all datapoints are set to 1.0
            for (k=1; k<=numnn; k++) {
                Point->wnn[k] = 1.0;
            }

         } else {
            // points are at different locations
            
            if (pcontrol->DistanceWeight == twf || pcontrol->DistanceWeight == rtwf \
               || pcontrol->DistanceWeight == ntwf || pcontrol->DistanceWeight == nbtwf)  {
               // calculate the tricubic weights

               for (j = 1; j <= numnn; j++)  {
	          Point->wnn[j] = pow( (1.0 - pow( (Point->dnn[j]/hx), 3)), 3);
               }

            } else if (pcontrol->DistanceWeight == nid || pcontrol->DistanceWeight == rnid \
                      || pcontrol->DistanceWeight == nnid || pcontrol->DistanceWeight == nbnid)  {
	       // calculate inverse distance weights
            
               for (j = 1; j <= numnn; j++)  {
                  Point->wnn[j] = 1.0 - pow( (Point->dnn[j] / hx), pcontrol->nid_power);
               }
            } 
         } 
               
      } else if (pcontrol->ConstNNRadius == TRUE) { 
         // normalize distance with SmoothingRadius
         A = pcontrol->NNRadius;

         if (pcontrol->DistanceWeight == twf || pcontrol->DistanceWeight == rtwf \
            || pcontrol->DistanceWeight == ntwf || pcontrol->DistanceWeight == nbtwf)  {
            // calculate the tricubic weights

            for (j = 1; j <= numnn; j++)  {
	       Point->wnn[j] = pow( (1.0 - pow( (Point->dnn[j]/A), 3)), 3);
            }

         } else if (pcontrol->DistanceWeight == nid || pcontrol->DistanceWeight == rnid \
            || pcontrol->DistanceWeight == nnid || pcontrol->DistanceWeight == nbnid)  {
	    // calculate inverse distance weights
            
            for (j = 1; j <= numnn; j++)  {
               Point->wnn[j] = 1.0 - pow( (Point->dnn[j] / A), pcontrol->nid_power);
            }
         } 

      } else { 
                    
         //add new weight here  
         fprintf(stderr, "ERROR: How did you manage to reach this point?\n");
                            
      }

      // renormalize the distance weights with number of data in segment
      // and with segment size
      if (pcontrol->DistanceWeight == nbtwf || pcontrol->DistanceWeight == nbnid)  {
	 // calculate the bin-matrix for this datapoint
	 if ( CalcBinMatrix(pcontrol, Point) < 0) {
	    fprintf(stderr, "ERROR: error occured in function CalcBinMatrix\n");
	    return -1;
	 }
	 for (j=1; j<=numnn; j++)  { // normalize by number of observations and area
	    Point->wnn[j] = Point->wnn[j]/(pcontrol->bin[ Point->rbin[j] ][ Point->abin[j] ]);
	 }
      }


      // VEROEND

      // independent of weighting method
      // weight the distance factor with the quality of the datapoints
      // if control.UseQuality is set to true;
      // here no 0.th datapoint
      if (pcontrol->UseQuality == TRUE)  {
         for (j = 1; j <= numnn; j++)  {
  	     Point->wnn[j] *= Point->nn[j]->quality;
	 }
      }
      
      return 0;
          
   }

}

int CalcPredictor(struct control *pcontrol, struct data *Point)
/* calculate the predictor f^ for a given point P. The estimates for the 
   datapoints (fm1 and fm2) were calculated iteratively and are stored in 
   fm1 and fm2. The predicted smoothed value is stored in f1 and f2.
   This function is called when calculating SmoothedDataPoints, GridMaps and 
   Trajectories. For SmoothedDataPoints wnn[0] is 1.0 
   this is the datapoint itself, this point is not used !!, for GridMaps and Traject.
   wnn[0] is 0.0. (VERO ....)
   Note: fm1 and f1 are switched compared to function Calc_fm */
{
   double A00, A01, A11, lambda1, lambda2, lambda, p2, q, radiant, sign_, fm1_div_fm2;
   int j;


   // calculate the components of the matrix A (A is symmetric !)
   // see equation (6) in Hanson and Mount. Loop starts always with 1
              
   for (j=1, A00=0, A01=0, A11=0; j <= Point->numnn; j++)  {
      A00 += pcontrol->Lambda * Point->nn[j]->fm1 * \
		      Point->nn[j]->fm1 * Point->wnn[j] * Point->nn[j]->delta;
      A01 += pcontrol->Lambda * Point->nn[j]->fm1 * \
		      Point->nn[j]->fm2 * Point->wnn[j] * Point->nn[j]->delta;
      A11 += pcontrol->Lambda * Point->nn[j]->fm2 * \
		      Point->nn[j]->fm2 * Point->wnn[j] * Point->nn[j]->delta;
   }

   // calculate the eigenvalues of A

   p2 = (0.5) * (A00 + A11);
   q  = A00*A11 - A01*A01;
   
   lambda1 = p2 + sqrt(p2*p2 - q);
   lambda2 = p2 - sqrt(p2*p2 - q);

   lambda = lambda1 > lambda2 ? lambda1 : lambda2;
       
   fm1_div_fm2 = (-1) * A01 / (A00 - lambda);
   sign_ = fm1_div_fm2 < 0 ? (-1.0) : 1.0;

   radiant =  A01*A01 + (A00-lambda)*(A00-lambda);
   Point->f1 = sign_ * sqrt( A01*A01 / radiant );
   Point->f2 = sqrt( (A00-lambda)*(A00-lambda)/radiant );
   
   return 0;
   
}




