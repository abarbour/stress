#include "smooth.h"


int WriteSmoothPoints(int argc, char **argv, struct control *pcontrol, struct data **P)
/* Function writing smoothed datapoints to file.
   The predicted direction (f^) is calculated from the estimated fm1 and 
   fm2 which optimize K(f) according to equation (6) in Hanson and Mount. */
{
  
  int i, numnn;
  FILE *out;
  double azimuth, azimuthfN;
  struct sort *NN;
  data *Point;
  
  FILE *PrepareFileOut(int argc, char **argv, struct control *pcontrol, const char *ext);
  int FindNNP(struct control *pcontrol, sort *NN, data *Point, data **P);
  int CalcWeightsP(struct control *pcontrol, data *Point);
  int CalcPredictor(struct control *pcontrol, data *Point);
  double Azimuth(double f1, double f2);
  int AllocateBin(struct control *pcontrol);
  int CalcSegmentArea(struct control *pcontrol);

  // set switch in pcontrol to indicate that actually SmootheDataPoints are
  // calculated (at the end of this subroutine  the switch is set back to TRUE
  pcontrol->SmoothPoints = ACTIVE;
  
  // open output file and write header with information in the file
  if ( (out = PrepareFileOut(argc, argv, pcontrol, sdat)) == NULL)  {
     fprintf(stderr, "ERROR: occured in function PrepareFileOut\n");
     return -1;
  }

  // allocate memory for datapoint
  if ((Point = new data) == NULL) {
      fprintf(stderr, "ERROR: not enough memory for datapoint\n");
      return -1;
  } 
  Point->nn = NULL;
  Point->dnn = NULL;
  Point->wnn = NULL;
  Point->ann = NULL;
  Point->rbin = NULL;
  Point->abin = NULL;

  // allocate memory for nearest neighbour search array
  NN = (struct sort *) malloc(sizeof(struct sort)*pcontrol->NoPoints);
  if ( NN == NULL )  {
     fprintf(stderr, "ERROR: not enough memory for determing nearest neighbours while writing smoothed data\n");
     return -1;
  }

  // allocate memory for bin array if normalization of weights is set
  if (pcontrol->DistanceWeight == ntwf || pcontrol->DistanceWeight == nnid)  {
     // check if bin has not been allocated before, we initialize bin with NULL
     if (pcontrol->bin == NULL) {   // allocate
	if (AllocateBin(pcontrol) < 0)  {
	   fprintf(stderr,"ERROR: occured in function AllocateBin \n");
	   return -1;
	}
     }
     // calculate the area of the segments if necesary
     if (pcontrol->SegArea == NULL)  {  // not yet calculated
	if (CalcSegmentArea(pcontrol) < 0)  {
	   fprintf(stderr, "ERROR: error occured in function CalcSegmentArea\n");
	   return -1;
	}
     }
  }

  // calculate smoothing predictors for all datapoints,
  // the neighbours are already calculated
  // but the weights may have been changed due to rescaling or renormalization !!!
  // therefore we search again the neighbours and calclulate the weights
  // for the neighbours again
  // It is easier to use the routines written for the trajectories and the grdmaps
  for (i=0; i < pcontrol->NoPoints; i++)  {
  
      Point->x1 = P[i]->x1;
      Point->x2 = P[i]->x2;

      // find nearest neighbours, store the nearest neighbours in nn(1..numnn)
      // and the distance in dnn(1..numnn), nn(0) and dnn(0) are not used!!
      if ( FindNNP(pcontrol, NN, Point, P) < 0 )  {
         fprintf(stderr, "ERROR: occured in function FindNNP \n");
         return -1;
      }
      
      // calculate the weights, set the wnn[0] = 0.0 
      // function returns -1 if error occured
      if (CalcWeightsP(pcontrol, Point) == -1 )  {  
         fprintf(stderr, "ERROR: occured in function CalcWeightsP \n");
         return -1;
      }   
     
      // calculate the predictor by calculating the matrix and the eigenvectors
      // the predicted values are stored in Point->f1 and Point->f2  
      if (CalcPredictor(pcontrol, Point) != 0 )  {
         fprintf(stderr, "ERROR: occured in function CalcPredictor \n");
         return -1;
      }   

      // calculate the azimuth 
      // the predictor is stored in Point->f1 and Point->f2
      azimuth = Azimuth(Point->f1, Point->f2);
      
      azimuthfN = Azimuth(P[i]->f1, P[i]->f2);
         
      fprintf(out, "%8.3lf %8.3lf %8.3lf %s %s %s", r2d*Point->x2, r2d*Point->x1, r2d*azimuth, "S", "A", "U");
      
      if (pcontrol->AdditionalInfo)  {          // write additional info 
         numnn = P[i]->numnn;
         if (pcontrol->ConstNNNumber) {
         // write information about which is furthest point used for smoothing
            fprintf(out, "%10.3lf %8.3lf %8.3lf %8.3lf\n", P[i]->dnn[numnn], r2d*P[i]->nn[numnn]->x1, r2d*P[i]->nn[numnn]->x2, r2d*azimuthfN);
         } else if (pcontrol->ConstNNRadius) {
         // write information about how many datapoints have been used for smoothing and location of furthest point
            fprintf(out, "%6d %8.3lf %8.3lf %8.3lf\n", numnn, r2d*P[i]->nn[numnn]->x1, r2d*P[i]->nn[numnn]->x2, r2d*azimuthfN);
         }
      } else {
         fprintf(out, "\n");
      }   
  }

  pcontrol->SmoothPoints = TRUE;
  
  fclose(out);
  free (NN);
  
  return 0;
}



int WriteGridmap(int argc, char **argv, struct control *pcontrol, data **P)
/* function writing a gridded map to the outputfile. The outputformat is,
   same as for the SmoothedPoints, input format for GMT-Script for plotting
   of stress data */
{
  double x, y;
  data *Point;
  int check, NoNeighbour;
  struct sort *NN;
  FILE *out;
  int CalcPredictor(struct control *pcontrol, data *Point);
  FILE *PrepareFileOut(int argc, char **argv, struct control *pcontrol, const char *ext);
  int FindNNP(struct control *pcontrol, sort *NN, data *Point, data **P);
  int CalcWeightsP(struct control *pcontrol, data *Point);
  int WriteGridPoint( struct control *pcontrol, FILE *out, data *Point);
  int AllocateBin(struct control *pcontrol);
  int CalcSegmentArea(struct control *pcontrol);

  // set to indicate that actually gridded maps are calculated
  pcontrol->Gridmap = ACTIVE;
  
  // open output file and write header with information in the file
  if ( (out = PrepareFileOut(argc, argv, pcontrol, grdm)) == NULL)  {;
     fprintf(stderr, "ERROR: occured in function PrepareFileOut\n");
     return -1;
  }
  
  // allocate memory for gridding datapoint, initialise the array pointers with
  // NULL 
  if ((Point = new data) == NULL) {
      fprintf(stderr, "ERROR: not enough memory for griddatapoint\n");
      return -1;
  } 
  Point->nn = NULL;
  Point->dnn = NULL;
  Point->wnn = NULL;
  Point->ann = NULL;
  Point->rbin = NULL;
  Point->abin = NULL;

  // allocate memory for nearest neighbour search array
  NN = (struct sort *) malloc(sizeof(struct sort)*pcontrol->NoPoints);
  if ( NN == NULL )  {
     fprintf(stderr, "ERROR: not enough memory for determing nearest neighbours while gridding\n");
     return -1;
  }

  // allocate memory for bin array if normalization of weights is set
  if (pcontrol->DistanceWeight == ntwf || pcontrol->DistanceWeight == nnid)  {
     // check if bin has not been allocated before, we initialize bin with NULL
     if (pcontrol->bin == NULL) {   // allocate
	if (AllocateBin(pcontrol) < 0)  {
	   fprintf(stderr,"ERROR: occured in function AllocateBin \n");
	   return -1;
	}
     }
     // calculate the area of the segments if necesary
     if (pcontrol->SegArea == NULL)  {  // not yet calculated
	if (CalcSegmentArea(pcontrol) < 0)  {
	   fprintf(stderr, "ERROR: error occured in function CalcSegmentArea\n");
	   return -1;
	}
     }
  }


  // calculate smoothing predictors 
  for (x=pcontrol->west, check = 0; x<= pcontrol->east; x+=pcontrol->Gridmap_xinc)  {

      for (y=pcontrol->south; y<= pcontrol->north; y+=pcontrol->Gridmap_yinc)  {
      
         Point->x1 = x;
         Point->x2 = y;
         if (pcontrol->verbose) {
            if (check == 0) {
               check = 1;
               fprintf(stdout, "    of location %7.2lf %7.2lf", r2d*x, r2d*y);
               fflush(stdout);
            } else {
               fprintf(stdout, "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b%7.2lf %7.2lf", r2d*x, r2d*y);
               fflush(stdout);
            }
         }
         
         // find nearest neighbours, store the nearest neighbours in nn(1..numnn)
         // and the distance in dnn(1..numnn), nn(0) and dnn(0) are not used!!
         if ( (NoNeighbour = FindNNP(pcontrol, NN, Point, P)) < 0 )  {
            fprintf(stderr, "ERROR: occured in function FindNNP \n");
            return -1;
         } else if (NoNeighbour == TRUE) {   // smoothing makes no sense
	    if (debug)
	      fprintf(stdout, "No smoothed Gridmap Datapoint for location %lf %lf\n", r2d*Point->x1,r2d*Point->x2);
         } else {
            // calculate the weights, set the wnn[0] = 0.0 
            // function returns -1 if error occured
            if (CalcWeightsP(pcontrol, Point) == -1 )  {  
               fprintf(stderr, "ERROR: occured in function CalcWeightsP \n");
               return -1;
            }   

            // calculate the predictor by calculating the matrix and the eigenvectors
            // the predicted values are stored in Point->f1 and Point->f2  
            if (CalcPredictor(pcontrol, Point) != 0 )  {
               fprintf(stderr, "ERROR: occured in function CalcPredictor \n");
               return -1;
            }   
            
            // write smoothed grid point to file, check if this point should be
            // ignored (control.IgnorePoint). Could have been done after
            // calculating the weights, but is easier to do here.
            // depending on GridMapInfo (defined in smooth.h) this function writes
            // additional information to the output file
            WriteGridPoint(pcontrol, out, Point);

         } 
         
      }   

  }

  // write newline due to animation
  if (pcontrol->verbose) fprintf(stdout, "\n");

  pcontrol->Gridmap = TRUE;

  fclose (out);
  free (NN);
  return 0;

}


int WriteGridPoint( struct control *pcontrol, FILE *out, data *Point) 
/* function writing the gridded datapoint to file out. Function checks
   if the actual calculated data point should be ignored and writes
   additional info to file if -E option is used. */
{
  double sumweights, sumquality, azimuth, deviation ;
  int numnn, i, use = TRUE;
  double Azimuth(double f1, double f2);
  double Deviation(struct control *pcontrol, data *Point);
   
  // calculate the azimuth
  azimuth = Azimuth(Point->f1, Point->f2);

  numnn = Point->numnn;
     
  // calculate the weighted standard deviation
  deviation = Deviation(pcontrol, Point);
     
  // calculate the rest of values which might be checked 
  if (pcontrol->ConstNNRadius) {
     for (i=1, sumweights=0.0, sumquality=0.0; i<numnn; i++) {
         sumweights += Point->wnn[i];
         sumquality += Point->nn[i]->quality;
     }  
     
     if (pcontrol->IgnorePoint == ignore_n && numnn < pcontrol->IgnoreNum) {
        use = FALSE;
     } else if (pcontrol->IgnorePoint == ignore_w && sumweights < pcontrol->IgnoreNum) {
        use = FALSE;
     } else if (pcontrol->IgnorePoint == ignore_q && sumquality < pcontrol->IgnoreNum) {
        use = FALSE;
     } 
  }
     
  // write point to output file
  if (use) { 

     if (pcontrol->ConstNNNumber) {

        fprintf(out, "%8.3lf  %8.3lf  %8.3lf  ", r2d*Point->x1, r2d*Point->x2, r2d*azimuth);
        
        if (pcontrol->AdditionalInfo)  {
           fprintf(out, "%9.3lg  %8.3lf  %8.3lf  %8.3lf\n", deviation, Point->dnn[numnn], r2d*Point->nn[numnn]->x1, r2d*Point->nn[numnn]->x2);
        } else {
           fprintf(out, "\n");
        } 
          
     } else if (pcontrol->ConstNNRadius) {
     
        fprintf(out, "%8.3lf  %8.3lf  %8.3lf  ", r2d*Point->x1, r2d*Point->x2, r2d*azimuth);
        
        if (pcontrol->AdditionalInfo)  {
           fprintf(out, "%9.3lg  %6d  %9.3lg  %9.3lg\n", deviation, numnn, sumweights, sumquality);
        } else {
           fprintf(out, "\n");
        } 
         
     }

  }
     
  return 0;
  
}


double Deviation(struct control *pcontrol, data *Point)
/* function calculating the 'error' of a gridded datapoint. At the moment the error is 
   calculated as follow: for each gridded datapoint the sum of the angle (degrees) between
   the gridded datapoint
   direction and the original datapoint direction multiplied with the weighting function is 
   calculted and gives , divided by numnn the error. */
{  
  int i;
  double sumweightangle, error;
  double Angle(struct data *Point, struct data *OrigData);
  
  for (i=1, sumweightangle=0; i<=Point->numnn; i++)  {
      
      // calculate angle between predictor and the measured directions.
      sumweightangle += r2d*Angle(Point, Point->nn[i])*Point->wnn[i];
  
  }   
  
  // error 
  error = sumweightangle / Point->numnn;
  
  return error;
}
     
      
double Angle(struct data *Point, struct data *OrigData)  
/* function returns the angle between the predicted 
   direction f^ (stored in Point->f1 and 
   Point->f2) and the measured direction of the OrigData 
   (OrigData->y1 and OrigData->y2) */
{
  double dotproduct, angle;
  
  dotproduct = Point->f1*OrigData->y1 + Point->f2*OrigData->y2;

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

  // up to now angle is between 0 and pi, we want values between 0 and pi/2
  // (direction 0 and pi is the same, our data have pi periodicity).
  
  if (angle > 0.5*pi) angle = pi - angle;
  
  return (angle);

}


double Azimuth(double f1, double f2)
/* calculate the azimuth, check if f2 is zero, return the azimuth
   in radians */
{
  
  if ( fabs(f2) < epsilon)  {    
          return 0.0;
  } else {
         return (atan(f1/f2));
  }
        
}


FILE *PrepareFileOut(int argc, char **argv, struct control *pcontrol, const char *extension)
/* function to create an output filename, open the file and write one line
   header with command line to file, function returns the pointer to the
   output file */
{
  char *FileOut;
  FILE *out;
  int i;
  char *exchangeExt(char *name, const char *ext);

  // get output filename
  FileOut = exchangeExt(pcontrol->FileOut, extension);
  
  if ( (out = fopen(FileOut, "w+")) == NULL) {
     fprintf(stderr, "ERROR: when creating output file %s\n", FileOut);
     return NULL;
  }
     
  // write header in file
  fprintf(out, "#SMOOTH Version %s (", Version);
  for (i=0; i<argc; i++)  {
      fprintf(out, "%s ", argv[i]);
  } 
  fprintf(out, ")\n");
      

  return out;

}   

