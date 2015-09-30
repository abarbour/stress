#include <iostream.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

const int    TRUE = 1;
const int    FALSE = 0;
const int    ACTIVE = 2;            
const int    NOTSET = -1;

const double epsilon = 1e-8;         // epsilon, when comparing doubles
const int    debug = FALSE;
const int    GridMapInfo = TRUE;     // if set to TRUE information about
                                     // either number of neighbous in search radius (-A)
                                     // or distance and location to furthes point (-N) 
                                     // is given in fourth and following columns 
                                     // of .grdm file
const char   Version[6] = "2.2";
const int    MaxCharInLine = 512;    // maximum number of character in line
const int    DefaultMaxIterations = 1500;   // maximum number of iterations in hmsmoothing
const int    DEF_NRBIN = 5;          // number of bins for radius
const int    DEF_NABIN = 8;          // number of bins for azimuth
const double DeltaKFactor = 1e-10;   // criterion to stop iteration
			             // stop itteration if K_of_f changes less than
			             // K_of_f * DeltaKFactor 
const int    MaxData = 15000;
const float  MinNNRadius = 0.0001;   // minimum value for radius
const int    MinNNNumber = 2;        // minimum number of nearest neighbours
				     // used for smoothing
const int    MaxNNNumber = 3000;     // maximum number of nearest neighbours
				     // used for smoothing
const float  Aquality = 1.0;
const float  Bquality = 0.75;
const float  Cquality = 0.5;
const float  Dquality = 0.25;
const int    ignore_n = 2;
const int    ignore_w = 3;
const int    ignore_q = 4;
const int    twf = 1;                // abbrev. for tricubic weight function
const int    rtwf = 2;               // abbrev. for rescaled tricub. weight function
const int    ntwf = 5;               // abbrev. for number normalized tricub. weight function
const int    nbtwf = 7;              // abbrev. for number and bin normalized tricub. weight function
const int    nid = 3;                // input parameter pdf: abbrev. for inverse distance weight function
const int    rnid = 4;               // input parameter rpdf: abbrev. for rescaled inv. distance weight function
const int    nnid = 6;               // input parameter npdf: abbrev. for numbernormalized inv. distance weight function
const int    nbnid = 8;              // input parameter nbpdf: abbrev. for number and bin normalized inv. distance weight function  
const char   sdat[5] = "sdat";       // extensions for outputfile
const char   grdm[5] = "grdm";
const char   trjs[5] = "trjs";
const char   method[3] = "S";
const char   quality[3] = "A";
const char   regime[3] = "U";
const float  EarthRadius = 6371.0;   // Earth radius in km
const double pi = 4.0 * atan(1.0);   // definition of pi
const double FarPoint = EarthRadius * pi + 1000;      // far point, used for sorting, this distance is
                                     // the furthest distance that can occure, used for 
                                     // sorting 
const double DefTrajStep = 2.0;      // default stepwidth when following trajectory (in km!!)
                                     // Note: control.TrajStep is in radians per unit sphere!!!!!
                                     // equals approx. 1 km
const double d2r = pi / 180.0;       // convert degrees to radians
const double r2d = 180.0 / pi;       // convert radians to degrees


struct control {
   int    verbose;                    // TRUE: give extended information
   int    MaxIterations;
   int    Gridmap;                    // TRUE: calculate gridded map
   float  Gridmap_xinc;               // increment in degrees for gridded maps longitude
   float  Gridmap_yinc;               // increment in degrees for gridded maps latitude
   int    SmoothPoints;               // TRUE: write file with smoothed datapoints
                                      // file format: wsm-format
   int    Trajectories;               // TRUE: calculate trajectories
   int    InteractiveTrajectories;    // TRUE: read start points interactive from 
   char * FileTrajecStart;            // name of file containing the start points
                                      // for the calculation of trajectories
                                      // input format one line header, lon lat
   double TrajStep;                   // stepwidth when following trajectory (in radians on unity sphere)
                                      // can be read in, defaults to DefTrajStep[km]/EarthRadius
   int    IgnorePoint;                // switch which check should be applied when checking 
                                      // if a gridded  datapoint should be calculated
                                      // ignore_n: certain number of points needed
                                      // ignore_w: certain weighting sum needed
                                      // ignore_q: certain sum of quality weights needed
   double IgnoreNum;                  // number giving either number of points or weigth
   char * FileIn;                     // name of input file
   char * FileOut;                    // name of output file (without extension)
   int    AdditionalInfo;             // write additional info in outfile.
				      // at the moment write:
				      // 4th column: standard deviation (sum of all weighted
				      //    angles between predictor f^ and the measured direction)
				      // 5-7th column: ConstNNRadius: numnn, sumweights, sumquality
				      // 5-7th column: ConstNNNumber: distance and location of
				      //    furthest near neighbour used for smoothing
   int    ConstNNRadius;              // defines if const. Radius method is used
				      // FALSE: no const Radius method
   double NNRadius;                   // radius in km used for smoothing
   int    ConstNNNumber;              // defines if fixed number of nearest neighbours is used
				      // FALSE: no fixed number of nearest neighbours method
   int    NNNumber;                   // number of nearest neighbours used for smoothing
   int    DistanceWeight;             // defines which distance weighting is
				      // to be used (integer abbreviation set):
				      // twf: tricubic weight function
				      // rtwf: rescaled tricubic weight function
				      // nid: inverse distance weight function
				      // rnid: rescaled inverse distance weight function
   int    nid_power;                  // power when using id or rid weight function
   int  **bin;                        // bin for renormalizing distance weigths
   int    nrbin;                      // number of radius bins when renormalizing distance weigths
   int    nabin;                      // number of azimuth bins when renormalizing distance weigths
   int    UsedBins;                   // number of bins with 1 or more observations
   double*SegArea;                    // Not USED SegArea contains the size of the segments in bin
   int    UseQuality;                 // TRUE: use quality information in data (default)
				      // sort of second weighting function

   float  Aquality;
   float  Bquality;
   float  Cquality;
   float  Dquality;
   int    Robustness;                 // TRUE: calculate robustness weights
				      // (default is FALSE)
   double Lambda;                     // Lambda (see Hanson and Mount)
   int    NoPoints;                   // Number of datapoints
   double x1min;
   double x1max;
   double x2min;
   double x2max;
   int    UserBoundaries;
   double west;
   double east;
   double south;
   double north;
};


struct data
{
   int index;       // sorting index, equivalent to dataline (without E-quality)
   double x1;       // longitude of datapoint in radians !!
   double x2;       // latitude of datapoint in radians !!
   double y1;       // x-component of unity-vector for maesured field 
   double y2;       // y-component of unity-vector for maesured field
   double f1;       // x-component of unity-vector for smoothed field at m-th iteration
   double f2;       // y-component of unity-vector for smoothed field at m-th iteration
   double fm1;      // x-component of unity-vector for smoothed field at m+1-th iteration
   double fm2;      // y-component of unity-vector for smoothed field at m+1-th iteration
   double delta;    // roboustness weight for m-th itteration
   float  quality;  // quality of datapoint
   int    ix1;      // number of the arrayposition in X1 array of this point
   int    ix2;      // number of the arrayposition in X2 array of this point
   int    numnn;    // number of nearest neighbours
   struct data **nn; // !! pointer to an array which contains the pointers to the
		    // numnn nearest neighbouring points
		    // nn[0..numnn]
   double *dnn;     // distance in km to the respective neighbouring point
		    // dnn[0..numnn]
   double *wnn;     // weight of the respective neighbouring point
		    // either the rescaled or the 'normal' tricubic weight
		    // wnn[0..numnn]
   double *ann;     // azimuth of the respective neighbouring point in
		    // radians
   int    *rbin;    // number of radius bin in which point lies [0..nrbin-1]
   int    *abin;    // number of azimuth bin in which point lies [0..nabin-1]
};


struct sort
// structure used to sort the data for nearest neighbours
{
   int    indexnn;      // index of neighbour in P array, stored in datastructure
   data  *pointer;      // pointer to neighbour
   double dist;         // distance in km to the actual point
};


struct point
{
    double azim;      // azimuth in radians ( 0 < azim < 2*pi)
    double x1;        // longitude
    double x2;        // latitude
};    


struct traj
// structure storing the information needed to calculate stress trajectories
{
    struct point p;   // previous point on the trajectory
    struct point a;   // actual point on the trajectory
    struct point n;   // next point on the trajectory
};   

