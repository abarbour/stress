#include "smooth.h"

int HMsmooth(struct control *pcontrol, data **P)
/* function implementing the smoothing algorithm suggested by Hanson and Mount
   in their paper. After the iteration the predicted values are stored in fm1 and fm2!
   f1 and f2 contains the start values for the last iteration (results from the previous
   iteration) ...*/

{
  int i, m, K_of_f_max_step;
  double K_of_f, K_of_f_prev_itt, K_of_f_max, DeltaK;
  int CalcWeights(struct control *pcontrol, struct data **P);
  int Calc_fm(struct control *pcontrol, struct data **P);
  int UpdateDelta(struct control *pcontrol, struct data **P);
  double Kfm(struct control *pcontrol, struct data **P);
  int AllocateBin(struct control *pcontrol);
  int CalcSegmentArea(struct control *pcontrol);

  // initialize the structures set those pointers which will
  // be checked later to NULL to indicate, that they are not yet
  // set
  for (i=0; i < pcontrol->NoPoints; i++)  {
      P[i]->delta = 1.0;
      P[i]->f1 = P[i]->y1;
      P[i]->f2 = P[i]->y2;
      P[i]->ann = NULL;
      P[i]->rbin = NULL;
      P[i]->abin = NULL;
  }

  // check if we need the bin array and the SegArea-vector, allocate them
  // done here once, instead of every time in the subroutine
  if (pcontrol->DistanceWeight == nbtwf || pcontrol->DistanceWeight == nbnid)  {
     // check if bin has not been allocated before, we initialized bin with NULL
     if (pcontrol->bin == NULL) {   // allocate
	if (AllocateBin(pcontrol) < 0)  {
	   fprintf(stderr,"ERROR: occured in function AllocateBin \n");
	   return -1;
	}
     }
     // SEGMENT AREA NOT USED calculate the area of the segments if necesary
     //if (pcontrol->SegArea == NULL)  {  // not yet calculated
	//if (CalcSegmentArea(pcontrol) < 0)  {
	//   fprintf(stderr, "ERROR: error occured in function CalcSegmentArea\n");
	//   return -1;
	//}
     // }
  }

  // compute the weights of all datapoints, weights include quality
  // if control.UseQuality is set to true, only delta (robustness)
  // is stored seperatly as it has to be updated for every iteration step.
  // From here on we do not have to bother for quality any more
  if (debug) printf("calculating weights\n");
  if (CalcWeights(pcontrol, P) != 0)  {
     fprintf(stderr, "ERROR: occured in function CalcWeights\n");
     return -1;
  }
  
  if (debug) fprintf(stdout, "entering iteration loop\n");
  // iteration loop, iteration step m
  m=0;
  K_of_f_max = 0;    // maximal value of K_of_f encountered
  K_of_f_max_step = 0;
  do {
     
     // calculate the estimate f(m+1) for all datapoints
     // store the updated values in fm1 and fm2
     Calc_fm(pcontrol, P);

     if (pcontrol->Robustness == TRUE )  {
	 // update the roboustness weight for all datapoints
	 // use the estimate f(m+1)
	 UpdateDelta(pcontrol, P);
     }
     
     // calculate K(f) and decide if iteration can be stopped
     // DeltaKFactor is defined in smooth.h
     K_of_f = Kfm(pcontrol, P);

     if (K_of_f_max < K_of_f) {
         K_of_f_max = K_of_f;
         K_of_f_max_step = m;
     }    
     if ( m >= 1 )  {
        // calculate change of K_of_f  ( we need it positive)
	DeltaK = K_of_f - K_of_f_prev_itt;
	// if (pcontrol->verbose)
	fprintf(stdout, "    K(f) for iteration %d is %.10lf, change %.10lf\n", m, K_of_f, DeltaK);
	if (fabs(DeltaK) < (DeltaKFactor * K_of_f)) {
	   fprintf(stdout, "    stopped after iteration step %d, change in K(f) less than %g percent\n", m, DeltaKFactor * 100);
           if (K_of_f < K_of_f_max) {    // we had a larger value for K_of_f before!!
              fprintf(stdout, "    WARNING: Use iteration with caution\n");
              fprintf(stdout, "      maximum value for K(f) was %.10lf in iteration step %d\n", K_of_f_max,K_of_f_max_step );
              fprintf(stdout, "      difference is %.10lf\n", K_of_f_max - K_of_f);
           }
           break;
        }    
     }

     // prepare for next iteration step, use fm1 and fm2 as f1 and f2 for
     // next iteration
     m++;
     for (i = 0; i<pcontrol->NoPoints; i++)  {
	 P[i]->f1 = P[i]->fm1;
	 P[i]->f2 = P[i]->fm2;
     }
     K_of_f_prev_itt = K_of_f;

  } while (m < pcontrol->MaxIterations);

  return 0;

}


double Kfm(struct control *pcontrol, struct data ** P)
/* function to calculate K(f) for the m+1 th iteration, use equation (2)
   in Hanson and Mount (checked with Watson equation (15)) */
{
   int i, j;
   double K_of_f = 0;
   double K;

   // loop over all datapoints
   for (i=0; i<pcontrol->NoPoints; i++)  {
       K = 0;

       // calculate second term first
       for ( j=1; j <= P[i]->numnn; j++)  {
	   K += P[i]->wnn[j] * P[i]->nn[j]->delta *  pow( (P[i]->fm1 * P[i]->nn[j]->fm1 + P[i]->fm2 * P[i]->nn[j]->fm2),2);
       }
       
       K *= pcontrol->Lambda;
       
       // first term (
       K += P[i]->wnn[0] * P[i]->nn[0]->delta * pow( (P[i]->fm1 * P[i]->y1 + P[i]->fm2 * P[i]->y2), 2);

       K_of_f += K;
   }

   return K_of_f;

}


int UpdateDelta(struct control *pcontrol, data **P)
/* update the roboustness weights for the all datapoints */
{
   double *residuals, *sortResiduals, residual, delta;
   double Norm( double xcomp, double ycomp);
/* following line added by Stefan Hettel 31.August 2001*/
   int i;

   int sort_function_residuals(const void*, const void *);

   // allocate memory for storing the residuals ||y - fm||
   // make a copy of the residuals used for sorting...
   residuals = new double [pcontrol->NoPoints];
   sortResiduals = new double [pcontrol->NoPoints];

   for (int i=0; i<pcontrol->NoPoints; i++)  {
       residual =  Norm( (P[i]->y1 - P[i]->fm1), (P[i]->y2 - P[i]->fm2));
       residuals[i] = residual;
       sortResiduals[i] = residual;
   }

   qsort( (void*) residuals, pcontrol->NoPoints, sizeof(double), sort_function_residuals);

   // s (see Hanson and Mount) is defined to be the median of the residuals
   double s = sortResiduals[(int) (pcontrol->NoPoints / 2)];

   delete sortResiduals;

   // calculate the updated robustness weights, use equation (10) in Hanson
   // and Mount
   for (i=0; i<pcontrol->NoPoints; i++)  {
       delta = residuals[i]/(6.0*s);
       P[i]->delta = delta < 1.0 ? (1.0-delta*delta)*(1.0-delta*delta) : 0.0;
   }
   delete residuals;
   return 0;
}



int Calc_fm(struct control *pcontrol, struct data **P)
/* calculate the eigenvector belonging to the larger eigenvalue,
   store the components of the eigenvalues in Point->fm1 and
   Point->fm2 */
{
   double A00, A01, A11, lambda1, lambda2, lambda, p2, q, radiant, sign_, fm1_div_fm2;
   struct data *Point;
   int i, j;

   for (i=0; i<pcontrol->NoPoints; i++)  {
       //if (debug) fprintf(stdout, " calculating fm for point %d\n", i);

       Point = P[i];     // define for abbreviation

       // calculate the components of the matrix A (A is symmetric !)
       // wnn contains already (if desired) the quality information.
       A00 =  Point->y1 * Point->y1 * Point->wnn[0] * Point->delta;
       A01 =  Point->y1 * Point->y2 * Point->wnn[0] * Point->delta;
       A11 =  Point->y2 * Point->y2 * Point->wnn[0] * Point->delta;

       for (j=1; j <= Point->numnn; j++)  {
	   A00 += pcontrol->Lambda * Point->nn[j]->f1 * \
		      Point->nn[j]->f1 * Point->wnn[j] * Point->nn[j]->delta;
	   A01 += pcontrol->Lambda * Point->nn[j]->f1 * \
		      Point->nn[j]->f2 * Point->wnn[j] * Point->nn[j]->delta;
	   A11 += pcontrol->Lambda * Point->nn[j]->f2 * \
		      Point->nn[j]->f2 * Point->wnn[j] * Point->nn[j]->delta;
       }

       // calculate the eigenvalues of A

       p2 = (0.5) * (A00 + A11);
       q  = A00*A11 - A01*A01;
   
       lambda1 = p2 + sqrt(p2*p2 - q);
       lambda2 = p2 - sqrt(p2*p2 - q);

       lambda = lambda1 > lambda2 ? lambda1 : lambda2;
       
       // 
       fm1_div_fm2 = (-1) * A01 / (A00 - lambda);
       sign_ = fm1_div_fm2 < 0 ? (-1.0) : 1.0;

       radiant =  A01*A01 + (A00-lambda)*(A00-lambda);
       P[i]->fm1 = sign_ * sqrt( A01*A01 / radiant );
       P[i]->fm2 = sqrt( (A00-lambda)*(A00-lambda)/radiant );
       if (debug) {
        //  if (isnan(P[i]->fm1)) fprintf(stdout, "P[%d]->fm1 is a NaN\n", i);
        //  if (isnan(P[i]->fm2)) fprintf(stdout, "P[%d]->fm2 is a NaN\n", i);
       }   
   }
   return 0;
}


int CalcWeights(struct control *pcontrol, struct data **P)
/* calculate the weights (storage for wnn allocated here):
   depending on control.DistanceWeight calculate either
   tricubic weights given by Hanson and Mount after Cleveland,
   rescaled tricubic weights after equation (9) given by Hanson and Mount,
   tricubic weights normalized by the number of neighbours (ntwf) or
   normalized inverse distance weights after w(x) = 1 - (dnn/SmoothRadius)**nid_power
   or rescaled normalized inverse distance weights
   the quality of the datapoints is used in the weights if
   control.UseQuality is set to TRUE. */
{
   int numnn, i, j, k;
   double hx;
   double A;         
   double Gx;        // sum of all tricubic/inverse distance weights
   double checksum;  // sum over all rescaled tricubic weights should be 1

   int CalcBinMatrix(struct control *pcontrol, data *Point);

   for (i = 0; i < pcontrol->NoPoints; i++)  {    // loop over all points
       
       // define some abbreviations
       numnn = P[i]->numnn;

       // allocate memory for storing the weights
       if ( (P[i]->wnn = new double [numnn+1]) == NULL)  {
	  fprintf(stderr, "ERROR: not enough memory to store weighting factors\n");
	  return -1;
       }

       // set the weight of the point itself to 1.0
       P[i]->wnn[0] = 1.0;

       if (numnn == 0) {   // no nearest neighbours

	  if (debug) fprintf(stdout, " Point %d has no neighbours \n", i);

       } else {            // there is at least one nearest neighbour

	  if (pcontrol->ConstNNNumber == TRUE)  {       // constant number of nearest neighbours
             
             // normalize distance with euclidean distance to the furthest point.
             // (Hanson and Mount: h(x))
             hx=P[i]->dnn[numnn];
             
             // CHECK if hx is zero or very small! This may happen if two different
             // datapoints are at the same location.
             if ( hx <= epsilon) {
                // all neighbours of this point are at the same location as the point
                // itself. Datapoint itself has weight 1.0, all other data points, too.
                // type of distance weighting is unimportant

                for (k=1, Gx = 0.0; k<=numnn; k++) {
                   P[i]->wnn[k] = 1.0;
 	           // calculate sum of all tricubic weights (not always used later)
	           Gx += P[i]->wnn[k];
                }
            
		if (debug) fprintf(stdout, "INFO: encountered hx = 0 when calculating weigths for point %d\n",i);

             } else { 

                // loop over all neighbouring points of the actual point
                
                if (pcontrol->DistanceWeight == twf || pcontrol->DistanceWeight == rtwf\
                   || pcontrol->DistanceWeight == ntwf || pcontrol->DistanceWeight == nbtwf)  {
                
                   // calculate the tricubic weights and the sum of all tricubic weigths
                   for (j = 1, Gx = 0.0; j <= numnn; j++)  {

	              // calculate tricubic weights
	              P[i]->wnn[j] = pow( (1.0 - pow( (P[i]->dnn[j]/hx), 3)), 3);

	              // calculate sum of all tricubic weights (not always used later)
	              Gx += P[i]->wnn[j];

                   }
                
                } else if (pcontrol->DistanceWeight == nid || pcontrol->DistanceWeight == rnid \
                || pcontrol->DistanceWeight == nnid || pcontrol->DistanceWeight == nbnid)  {
             
                   for (j = 1, Gx = 0.0; j <= numnn; j++)  {
   
	              // calculate inverse distance weights
	              P[i]->wnn[j] = 1.0 - pow( (P[i]->dnn[j] / hx), pcontrol->nid_power);

	              // calculate sum of all tricubic weights (not always used later)
	              Gx += P[i]->wnn[j];
                   }

                }
             
             }
          
          } else if (pcontrol->ConstNNRadius == TRUE)  {  // constant smoothing radius   
            
             // normalize distance with SmoothingRadius
	     A = pcontrol->NNRadius;
             
	     if (pcontrol->DistanceWeight == nid || pcontrol->DistanceWeight == rnid \
	        || pcontrol->DistanceWeight == nnid || pcontrol->DistanceWeight == nbnid)  {

                for (j = 1, Gx = 0.0; j <= numnn; j++)  {
   
	           // calculate normalized inverse distance weights
	           P[i]->wnn[j] = 1.0 - pow( (P[i]->dnn[j] / A), pcontrol->nid_power);

	           // calculate sum of all tricubic weights (not always used later)
	           Gx += P[i]->wnn[j];
                }
                
             } else if (pcontrol->DistanceWeight == twf || pcontrol->DistanceWeight == rtwf \
                       || pcontrol->DistanceWeight == ntwf || pcontrol->DistanceWeight == nbtwf)  {

		for (j = 1, Gx = 0.0; j <= numnn; j++)  {
   
	           // calculate tricubic weights
		   P[i]->wnn[j] = pow( (1.0 - pow( (P[i]->dnn[j]/A), 3)), 3);

	           // calculate sum of all tricubic weights (not always used later)
		   Gx += P[i]->wnn[j];
                }
             }             

          } else {
             
             // add new weight here
             fprintf(stderr, "ERROR: How did you manage to reach this point?\n");
                            
          }
          

          // now all weights are calculated

          // calculate the rescaled weights
	  if ((pcontrol->DistanceWeight == rnid && Gx > 0.0) || (pcontrol->DistanceWeight == rtwf && Gx > 0.0)) {

             // for only 1 nearest neighbour wnn[1] is zero, thus Gx is zero, too.
             // Gx may also be zero, if we have more than one nearest neighbour, but
             // all nearest neighbours have the same distance (in this case the weight
             // of all these points is zero and Gx is zero too).
             // therefore we must not rescale if Gx is zero (otherwise we devide by zero!)

	     for (j = 1, checksum = 0; j <= numnn; j++)  {
	        P[i]->wnn[j] /= Gx;
                checksum += P[i]->wnn[j];
	     }
             if (debug && (fabs(checksum - 1.0) > epsilon)){ 
                fprintf(stdout, "STRANGE: something is not ok with the rescaled weigths \n");
             }

	  } else if (pcontrol->DistanceWeight == ntwf || pcontrol->DistanceWeight == nnid) {
	     // normalize by number of observations
	     for (j = 1; j <= numnn; j++)  {
	        P[i]->wnn[j] /= numnn;
	     }

	  } else if (pcontrol->DistanceWeight == nbtwf || pcontrol->DistanceWeight == nbnid) {
	     // renormalize distance weights by number of data in segment
	     // also divide by the number of used segments, to ensure balance between 
	     // the two terms in K(f). Not done in function CalcWeightsP !!

	     if ( CalcBinMatrix(pcontrol, P[i]) < 0) {
		fprintf(stderr, "ERROR: error occured in function CalcBinMatrix\n");
		return -1;
	     }
	     for (j=1; j<=numnn; j++)  { // normalize by number of observations and area
		P[i]->wnn[j] = P[i]->wnn[j]/pcontrol->UsedBins/(pcontrol->bin[ P[i]->rbin[j] ][ P[i]->abin[j] ]);
	     }

          }             
             
          // independent of weighting method
          // weight the distance factor with the quality of the datapoints
          // if control.UseQuality is set to true;
          // ! we weight also the weighting factor of the datapoint itself !
          if (pcontrol->UseQuality == TRUE)  {
	     for (j = 0; j <= numnn; j++)  {
	         P[i]->wnn[j] *= P[i]->nn[j]->quality;
	     }
	  }
          
       }

       // we do not need the azimuth or the binnumbers any longer
       // free this memory
       if (pcontrol->DistanceWeight == nbtwf || pcontrol->DistanceWeight == nbnid) {
	  delete P[i]->ann;
	  delete P[i]->rbin;
	  delete P[i]->abin;
        }
   }
   
   return 0;
   
}


 
