#include "smooth.h"


int WriteTrajectories(int argc, char **argv, struct control *pcontrol, data **P)
/* function calulating and writing trajectories */
{
  int GoOn, i;
  double x1, x2, azim, dist_plus, dist_minus, deviation, deviation_start;
  double azim_plus, azim_minus;  
  double start_azim[2];
  struct traj traj;
  struct point nextPoint_plus;         // next point in direction azim
  struct point nextPoint_minus;        // next point in reverse direction 
  struct sort *NN;
  struct data *Point; 
  FILE *trajstart, *out;
  char line[MaxCharInLine] = " ";
  void NextPoint(struct point *nextPoint, double azim, const double c, double x1, double x2); 
  FILE *PrepareFileOut(int argc, char **argv, struct control *pcontrol, const char *ext);
  double UpdateAzim(struct control *pcontrol, sort *NN, data *Point, data **P);
  int BoundaryCheck(struct point *actualpoint, struct control *pcontrol);
  double Distance(struct point *p1, struct point *p2);
  double Deviation(struct control *pcontrol, data *Point);
  int AllocateBin(struct control *pcontrol);
  int CalcSegmentArea(struct control *pcontrol);

  
  // allocate memory for gridding datapoint and initialise the array pointers 
  // needed later with NULL 
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



  if (pcontrol->InteractiveTrajectories)  {
     trajstart = stdin;
     fprintf(stdout, "    ENTER startpoints for trajectories (lon lat), give END to stop\n");
  } else {   
     // open the file with the startpoints for the trajectories and
     // skip first line, this line is a headerline
     if ( (trajstart = fopen(pcontrol->FileTrajecStart, "r")) == NULL) {
        fprintf(stderr, "ERROR: could not open file %s for reading starting points of trajectories \n", pcontrol->FileTrajecStart);
        return -1;
     } 
     fgets(line, MaxCharInLine-1, trajstart);                          // skip header line
  }
  
  // open output file and write header with information in the file
  if ( (out = PrepareFileOut(argc, argv, pcontrol, trjs )) == NULL)  {
     fprintf(stderr, "ERROR: occured in function PrepareFileOut\n");
     return -1;
  }
   
  // loop over all points in FileTrajecStart
  while ( (fgets(line, MaxCharInLine-1, trajstart) != NULL) && (strncmp(line, "END", 3) != 0) ) {
    sscanf(line, " %lf %lf ", &x1, &x2);   
    Point->x1 = d2r*x1;
    Point->x2 = d2r*x2;
    if (pcontrol->verbose) 
        fprintf(stdout, "    following trajectory starting at %.3f deg longitude %.3f deg latitude\n", x1, x2 ); 
    // calculate the azimuth (the predictor for the direction) for the starting point.
    // function returns values between -pi/2 and pi/2 if smoothing was possible,
    // if no neighbours were found, function returns pi. When an error occured,
    // function returns -pi.
    if ( (azim = UpdateAzim(pcontrol, NN, Point, P)) < (-0.5)*pi)  {
        fprintf(stderr, "ERROR: occured in function UpdateAzim \n");
        return -1;
    } else if (azim > 0.5 * pi) {    // no smoothing was possible
        if(pcontrol->verbose) fprintf(stdout, "    lost this trajectory, follow next ...\n");
        if (pcontrol->InteractiveTrajectories) fprintf(stdout, "     new startpoint for trajectory, give END to stop calculation\n");
        continue; // stop following this trajectory, read new startpoints... 
    }   
    // calculate the deviation at the starting point
    deviation_start = Deviation(pcontrol, Point);
    
    // atan returns values between -pi/2 and pi/2, we want positive values
    // between 0 and 2pi (in radians!!).
    // We have two azimuths, one in the 'positive' direction, the second in the 
    // reverse direction. They are stored in the array start_azim
    start_azim[0] = azim >= 0.0 ? azim : (pi + azim);            // plus direction
    start_azim[1] = azim >= 0.0 ? (azim + pi) : (2*pi + azim);   // minus direction

    for (i=0; i<=1; i++)  {
       // write the values of the start point in struct Point (this struct is used for 
       // calculating the updated azimuth, and for calculating the nextPoint).
       // For i=0 this values are already stored in Point, we need it for the second run.
       Point->x1 = d2r*x1;
       Point->x2 = d2r*x2;

       // store the values of start point in structure traj, write the startpoint to outfile
       // if i==0 follow start_azim_plus direction, else follow start_azim_minus direction
       traj.p.x1 = d2r*x1;
       traj.p.x2 = d2r*x2;       
       traj.p.azim = start_azim[i];
       
      
       if (pcontrol->AdditionalInfo) {
          fprintf(out, "> %d \n %lf %lf %lf\n", i, x1, x2, deviation_start);
       } else {
          fprintf(out, "> %d \n %lf %lf \n", i, x1, x2); 
       }

       // follow direction of traj.p.azim, calculate next point in this direction
       NextPoint(&nextPoint_plus, traj.p.azim, pcontrol->TrajStep, Point->x1, Point->x2);

       // write the location of nextPoint_plus in traj.a and in Point
       traj.a.x1 = Point->x1 = nextPoint_plus.x1;
       traj.a.x2 = Point->x2 = nextPoint_plus.x2;
       
       // write the location of the next Point to outfile
       if (pcontrol->AdditionalInfo) {
          deviation = Deviation(pcontrol, Point);
          fprintf(out, " %lf %lf %lf \n", r2d*Point->x1, r2d*Point->x2, deviation); 
       } else {
          fprintf(out, " %lf %lf\n", r2d*Point->x1, r2d*Point->x2); 
       }
       
       
       // calculate the azimuth for this second point
       if ( (azim = UpdateAzim(pcontrol, NN, Point, P)) < (-0.5)*pi)  {
           fprintf(stderr, "ERROR: occured in function UpdateAzim \n");
           return -1;
       } else if (azim > 0.5 * pi) {    // no smoothing was possible, no neighbours
           if(pcontrol->verbose) fprintf(stdout, "    lost this trajectory, follow next ...\n");
           if (i==1 && pcontrol->InteractiveTrajectories) 
              fprintf(stdout, "     new startpoint for trajectory, give END to stop calculation\n");
           continue; // follow trajectory in the other direction 
       }   
 
       // follow this trajectory until map boundaries are reached 
       // what happens if no next point can be calculated (-A option) VERO
       do {               
          // atan returns values between -pi/2 and pi/2, we want positive values
          // between 0 and 2pi (in radians!!)
          azim_plus = azim >= 0.0 ? azim : (pi + azim);
          azim_minus = azim >= 0.0 ? (azim + pi) : (2*pi + azim);
          NextPoint(&nextPoint_plus, azim_plus, pcontrol->TrajStep , traj.a.x1, traj.a.x2);
          NextPoint(&nextPoint_minus, azim_minus, pcontrol->TrajStep , traj.a.x1, traj.a.x2);
       
          // decide which point is the furthest away from the location used two steps before
          dist_plus = Distance(&nextPoint_plus, &(traj.p));
          dist_minus = Distance(&nextPoint_minus, &(traj.p));
       
          if (dist_plus > dist_minus) {   // dist_plus is the point we want
              // now we use traj.a as traj.p and nextPoint_plus as traj.a
              traj.p.x1 = traj.a.x1;
              traj.p.x2 = traj.a.x2;
              traj.p.azim = azim_plus;
              traj.a.x1 = Point->x1 = nextPoint_plus.x1;
              traj.a.x2 = Point->x2 = nextPoint_plus.x2;
              if (pcontrol->AdditionalInfo) {
                 deviation = Deviation(pcontrol, Point);
                 fprintf(out, " %lf %lf %lf\n", r2d*Point->x1, r2d*Point->x2, deviation);
              } else {
                 fprintf(out, " %lf %lf\n", r2d*Point->x1, r2d*Point->x2);    
              }
              
          } else {                        // dist_minus is the point we want                           
              // now we use traj.a as traj.p and nextPoint_minus as traj.a

              traj.p.x1 = traj.a.x1;
              traj.p.x2 = traj.a.x2;
              traj.p.azim = azim_minus;
              traj.a.x1 = Point->x1 = nextPoint_minus.x1;
              traj.a.x2 = Point->x2 = nextPoint_minus.x2;
              if (pcontrol->AdditionalInfo) {
                 deviation = Deviation(pcontrol, Point);
                 fprintf(out, " %lf %lf %lf\n", r2d*Point->x1, r2d*Point->x2, deviation);
              } else {
                 fprintf(out, " %lf %lf\n", r2d*Point->x1, r2d*Point->x2);    
              }

          }
       
          // calculate the azimuth for the 'new' actual point
          if ( (azim = UpdateAzim(pcontrol, NN, Point, P)) < (-0.5)*pi)  {
              fprintf(stderr, "ERROR: occured in function UpdateAzim \n");
              return -1;
          } else if (azim > 0.5 * pi) {    // no smoothing was possible, no neighbours
              if(pcontrol->verbose) fprintf(stdout, "    lost this trajectory at point %lf %lf, follow next ...\n",r2d*Point->x1, r2d*Point->x2 );
              break; // break do loop, stop following this trajectory in this direction ... 
          } 
          
          GoOn = BoundaryCheck(&(traj.a), pcontrol);
 
       } while(GoOn);
       
     }
     
     fflush(out);
     
     if (pcontrol->InteractiveTrajectories) {
        fprintf(stdout, "    new startpoint for trajectory, give END to stop calculation\n");
     }   

  }
  fclose(trajstart);
  fclose(out);
  free(NN);
  return 0;
  
}

int BoundaryCheck(struct point *actualpoint, struct control *pcontrol)
/* function checking if actual point is still withing the boundaries defined by
   pcontrol->x1min ... 
   Function returns 1 if still within boundaries, 0 when outside */
{
   if ( (actualpoint->x1 > pcontrol->east) || (actualpoint->x1 < pcontrol->west) )  {
      return 0;
   } else if ( (actualpoint->x2 > pcontrol->north) || (actualpoint->x2 < pcontrol->south) )  {
      return 0;
   } else {
      return 1;
   }
}         
    

double UpdateAzim(struct control *pcontrol, sort *NN, data *Point, data **P)
/* function calculating the predicted f^ (azimuth) for a given location stored
   in Point.
   Function returns the azimuth between -pi/2 and pi/2, returns -pi if error 
   occured and pi if no azimuth could be calculated (for example if no neighbours
   were found */
{
  int NoNeighbour, i, use=TRUE, numnn;
  double azim, sumweights, sumquality;
  double Azimuth(double f1, double f2);
  int FindNNP(struct control *pcontrol, sort *NN, data *Point, data **P);
  int CalcWeightsP(struct control *pcontrol, data *Point);
  int CalcPredictor(struct control *pcontrol, data *Point);
  
  if ( (NoNeighbour = FindNNP(pcontrol, NN, Point, P)) < 0 )  {
     fprintf(stderr, "ERROR: occured in function FindNNP \n");
     return (-1) * pi;
  } else if  (NoNeighbour == TRUE) {
     if (debug)
        fprintf(stdout, " INFO: no neighbour for smoothing ... \n");
     return pi;
  }      
  if (CalcWeightsP(pcontrol, Point) != 0 )  {
     fprintf(stderr, "ERROR: occured in function CalcWeightsP \n");
     return (-1)*pi;
  }   
  if (CalcPredictor(pcontrol, Point) != 0 )  {
     fprintf(stderr, "ERROR: occured in function CalcPredictorP \n");
     return (-1)*pi;
  }   
  
  // number of neighbours for this location, define abreviation
  numnn = Point->numnn;
  
  // calculate the values needed to check if this point should be ignored 
  // due to a -I option
  use = TRUE;
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
  
  if (use) {
    azim = Azimuth(Point->f1,Point->f2);
    return azim;
  } else {
    return pi;
  }  
}  
  
void NextPoint(struct point *nextPoint, double azim, const double dist, double x1, double x2)
/* function calculating the next point in a given distance dist in the direction of azim from
   point x1 (lon) x2 (lat). azim, x1, x2 and dist are in radians, nx1, nx2, deltaLat and deltaLon, too. 
   Note: function assumes, that dist is smaller pi, is ok */
{
   double co_x2, cos_c, dummy_a, dummy_b, cos_beta, beta;
   
   // change to co-latitude
   co_x2 = 0.5*pi - x2;
   
   cos_c = cos(azim)*sin(dist)*sin(co_x2)+cos(dist)*cos(co_x2);
   
   dummy_a = asin(cos_c);
   
   dummy_b = sin(azim)*sin(dist)/cos(dummy_a);
   
   cos_beta = (cos(dist)-cos_c*cos(co_x2))/(cos(dummy_a)*sin(co_x2));
   
   beta = atan2(dummy_b,cos_beta);
   
   nextPoint->x1 = x1 + beta;
   
   if(nextPoint->x1 > pi)  nextPoint->x1 = nextPoint->x1 - 2*pi;
   if(nextPoint->x1 < -1*pi) nextPoint->x1 = nextPoint->x1 + 2*pi;
   
   nextPoint->x2 = dummy_a;
   
   return;
}   
   
   
   
   
   
