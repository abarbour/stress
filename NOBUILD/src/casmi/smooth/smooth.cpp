#include "smooth.h"



// main program
int main (int argc, char **argv)
{
struct control control = { FALSE, DefaultMaxIterations, FALSE, 0.0, 0.0, FALSE, FALSE, FALSE,\
                           NULL, 0.0, FALSE, 0.0, NULL, NULL, FALSE, \
			   FALSE, 0.0, FALSE, 0, NOTSET, 2, NULL, DEF_NRBIN, DEF_NABIN, 0, \
			   NULL, NOTSET, \
                           0.0, 0.0, 0.0, 0.0, FALSE, \
			  -1.0, 0, 0.0, 0.0, 0.0, 0.0, FALSE, 0.0, 0.0, 0.0, 0.0};
struct data *P[MaxData];
FILE *in;
int i, n;
char *cpointer;
int nid_power;
float xinc, yinc, west, east, south, north, ignorenum, Aq, Bq, Cq, Dq;
char *charPSlash;
int error = 0;

// functions used in main
int default_error(int parameter);
int InfoControl(struct control *pcontrol);
int ReadData(FILE *in, struct control *pcontrol, struct data *P[]);
int WriteData(FILE *out, struct data *P[], int NoPoints);
int sort_function_x1(const void *, const void *);
int sort_function_x2(const void *, const void *);
int sort_function_index(const void *, const void *);
int GiveBoundaries(struct data ** X1, struct data **X2, struct control *control);
int FindNNForAllData(struct control *pcontrol, data **P, data **X1, data **X2);
int HMsmooth(struct control *pcontrol, data **P);
int WriteDataPoints(FILE *out, struct control *pcontrol, data **P);
int WriteSmoothPoints(int argc, char **argv, struct control *pcontrol, data **P);
int WriteGridmap(int argc, char **argv, struct control *pcontrol, data **P);
int WriteTrajectories(int argc, char **argv, struct control *pcontrol, data **P);

   fprintf(stdout,"\n         SMOOTH - a program to smooth stress direction data\n");
   fprintf(stdout,"                           Version %s \n", Version);
   fprintf(stdout,"                     written by Veronika Wehrle \n\n");

   // read input parameters
   for (i = 1; i < argc; i++) {
       if (argv[i][0] == '-') {
	  switch (argv[i][1]) {
		  case 'L':
		      if ( (control.Lambda=atof((char*)&(argv[i][2]))) < 0.0)  {
			 fprintf(stderr, "ERROR: lambda must be larger than zero\n");
			 error++;
		      }
		      break;
		  case 'N':
		      if( (control.NNNumber=atoi((char*)&(argv[i][2]))) <= MinNNNumber )  {
			 fprintf(stderr, "ERROR: number of nearest neighbours used for smoothing must at \n");
			 fprintf(stderr, "       be larger than %d \n\n", MinNNNumber);
			 error++;
		      }
		      control.ConstNNNumber = TRUE;
		      break;
		  case 'A':
		      if( (control.NNRadius=atof((char*)&(argv[i][2]))) <= MinNNRadius) {
			 fprintf(stderr, "ERROR: the smoothing radius you supplied is to small \n");
			 error++;
		      }
		      control.ConstNNRadius = TRUE;
		      break;
		  case 'B':
		      control.Robustness = TRUE;
		      break;
		  case 'C':
		      if( (control.MaxIterations=atoi((char*)&(argv[i][2]))) <= 1 )  {
			 fprintf(stderr, "ERROR: Number of iteration steps must at least be 1 \n");
			 error++;
		      }
		      break;
		  case 'D':
		      if( strcmp("twf",(char*)&(argv[i][2])) == 0 )  {
			 control.DistanceWeight = twf;
		      } else if ( strcmp("rtwf",(char*)&(argv[i][2])) == 0 )  {
			 control.DistanceWeight = rtwf;
		      } else if ( strcmp("ntwf",(char*)&(argv[i][2])) == 0 )  {
			 control.DistanceWeight = ntwf;
		      } else if ( strcmp("nbtwf",(char*)&(argv[i][2])) == 0 )  {
			 control.DistanceWeight = nbtwf;
		      } else if ( strncmp("pdf",(char*)&(argv[i][2]),3) == 0 )  {
			 control.DistanceWeight = nid;
			 if ( (n = sscanf( (char*)&(argv[i][6]), "%d", &nid_power)) == 1)  {
			    if ((control.nid_power=nid_power) < 1) {
			       fprintf(stderr, "ERROR: power for power distance function must be positive\n");
			       error++;
			    }
			 }   
		      } else if ( strncmp("rpdf",(char*)&(argv[i][2]),4) == 0 )  {
			 control.DistanceWeight = rnid;
			 if ( (n = sscanf( (char*)&(argv[i][7]), "%d", &nid_power)) == 1)  {
			    if ((control.nid_power=nid_power) < 1) {
			       fprintf(stderr, "ERROR: power for rescaled power-distance-function must be positive\n");
			       error++;
			    }
			 }   
		      } else if ( strncmp("npdf",(char*)&(argv[i][2]),4) == 0 )  {
			 control.DistanceWeight = nnid;
			 if ( (n = sscanf( (char*)&(argv[i][7]), "%d", &nid_power)) == 1)  {
			    if ((control.nid_power=nid_power) < 1) {
			       fprintf(stderr, "ERROR: power for number normalized power-distance-function must be positive\n");
			       error++;
			    }
			 }   
		      } else if ( strncmp("nbpdf",(char*)&(argv[i][2]),5) == 0 )  {
			 control.DistanceWeight = nbnid;
			 if ( (n = sscanf( (char*)&(argv[i][7]), "%d", &nid_power)) == 1)  {
			    if ((control.nid_power=nid_power) < 1) {
			       fprintf(stderr, "ERROR: power for number normalized power-distance-function must be positive\n");
			       error++;
			    }
			 }   
		      } else {
			 fprintf(stderr, "ERROR: unsupported parameter for -D option\n\n");
			 error++;
		      }
		      break;
		  case 'd':
		      if ( (cpointer = strchr( (char*)&(argv[i][2]), 'a' )) != NULL) {
			 n=sscanf(cpointer+1, "%d", &control.nabin);
			 if (n == NULL || control.nabin <= 0)  {
			   fprintf(stderr, "ERROR: give useful number of azimuth bins \n");
			   error++;
			 }
		      }
		      if ( (cpointer = strchr( (char*)&(argv[i][2]), 'r' )) != NULL) {
			 n=sscanf(cpointer+1, "%d", &control.nrbin);
			 if (n == NULL || control.nrbin <= 0)  {
			   fprintf(stderr, "ERROR: give useful number of radius bins\n");
			   error++;
			 }
		      }
		      break;
		  case 'E':
		      control.AdditionalInfo = TRUE;
		      break;
		  case 'G':
		      if( ( n = sscanf((char*)&(argv[i][2]), "%f/%f", &xinc, &yinc)) == 2) {
		         if (xinc > 0.0 && yinc > 0.0) {
		            control.Gridmap_xinc = d2r*xinc;
		            control.Gridmap_yinc = d2r*yinc;
		         } else {
		            fprintf(stderr, "ERROR: negative gridding intervals make no sense \n");
                            error++;
		         }       
                      } else if (n == 1)  {   // yinc defaults to xinc
		         if (xinc > 0.0) {
		            control.Gridmap_xinc = d2r*xinc;
		            control.Gridmap_yinc = d2r*xinc;
		         } else {
		            fprintf(stderr, "ERROR: negative gridding intervals make no sense \n");
                            error++;
		         }       
                      } else {
                         fprintf(stderr, "ERROR: can not identify gridmap intervall \n");
                         error++;
                      }  
		      control.Gridmap = TRUE;
		      break;
		  case 'I':
		      if ( (n = sscanf((char*)&(argv[i][4]), "%f", &ignorenum)) != 1)  {
		         fprintf(stderr, "ERROR: could not identify ignore number, check parameter -I\n");
		         error++;
		      }
		      if(argv[i][2] == 'n')  {
			 control.IgnorePoint = ignore_n;
		      } else if(argv[i][2] == 'w')  {
			 control.IgnorePoint = ignore_w;
		      } else if(argv[i][2] == 'q')  {
			 control.IgnorePoint = ignore_q;
		      } else {
		         fprintf(stderr, "ERROR: could not identify <ignore> option, \n");
		         fprintf(stderr, "       possible options are n, w, and q\n");
		         error++;
		      }       
		      if (ignorenum <= 0) {
                         fprintf(stdout, "ERROR: option -I, negative number makes no sense\n");
                         error++;
 		      } else {
			 control.IgnoreNum = ignorenum;
		      }
		      break;
		  case 'O':
		      control.FileOut = (char *)&(argv[i][2]);
		      break;
		  case 'Q':
		      if(argv[i][2] == 'n')  {          // do not use quality information
			 control.UseQuality = FALSE;
		      } else if (argv[i][2] == 'y')  {  // use quality information
		        if( ( n = sscanf((char*)&(argv[i][4]), "%f/%f/%f/%f", &Aq, &Bq, &Cq, &Dq)) == 0) { 
		           // no quality weigthing is given, using defaults
		           control.UseQuality = TRUE;
		           control.Aquality = Aquality;
		           control.Bquality = Bquality;
		           control.Cquality = Cquality;
		           control.Dquality = Dquality;
		        } else if (n == 4) {  
		           control.UseQuality = TRUE;
                           if (Aq < Bq || Bq < Cq || Cq < Dq)  {
                              fprintf(stdout, "ERROR: the quality ranking sheme is A to D with A as best quality\n");
                              fprintf(stdout, "       the weighting should be A >= B >= C >= D \n");
                              error++;
                           }
		           control.Aquality = Aq;
		           control.Bquality = Bq;
		           control.Cquality = Cq;
		           control.Dquality = Dq;
		        } else {
		           fprintf(stderr, "ERROR: wrong quality weights, check parameter -Q \n");
                           error++;
		        }       
		      } else {
		        fprintf(stderr, "ERROR: wrong parameters for quality option -Q, use -Qy or -Qn\n");
                        error++;
		      }
		               
		      break;
		  case 'R':
		      if( ( n = sscanf((char*)&(argv[i][2]), "%f/%f/%f/%f", &west, &east, &south, &north)) == 4) {
		         if (west < east && south < north) {
		            control.west = d2r*west;
		            control.east = d2r*east;
		            control.south = d2r*south;
		            control.north = d2r*north;
		         } else {
		            fprintf(stderr, "ERROR: wrong parameters for region given, check -R option \n");
                            error++;
		         }       
                         control.UserBoundaries = TRUE;
                      } else {
		         fprintf(stderr, "ERROR: wrong parameters for region given, check -R option \n");
                         error++;
                      }
       		  case 'S':
		      control.SmoothPoints = TRUE;
		      break;
		  case 'T':
       		      if( ( charPSlash = strrchr((char*)&(argv[i][2]), '/')) == NULL) { // no optional parameter trajstep
		         control.TrajStep = DefTrajStep/EarthRadius;                   // use default (DefTrajSTep is in km)
                      } else {                                                         // optional paramter trajstep is given
                         if( (control.TrajStep = atof(charPSlash + 1)/EarthRadius) < 0.0) {
                            fprintf(stderr, "ERROR: negative trajectory steps make no sense \n");
                            error++;
		         } 
                         *charPSlash = '\0';     // replace / with endof string, so that we can read the filename
                      } 
		      if ( strcmp(control.FileTrajecStart = (char *)&(argv[i][2]), "stdin") == 0) {
		         control.InteractiveTrajectories = TRUE;
		      } else {
		         control.InteractiveTrajectories = FALSE;
		      }    
		      control.Trajectories = TRUE;
		      break;
		  case 'V':
		      control.verbose = TRUE;
		      break;
		  default:
		      error++;
		      default_error (argv[i][1]);
		      break;
	  }
       } else {
	  control.FileIn = argv[i];
       }
   }

   if (argc == 1) {
      fprintf(stdout,"  USAGE: smooth <inputfile> -L<lambda> -N<number> -A<radius> \n");
      fprintf(stdout,"                [-B] [-C<iterations>] [-D<weightmethod>] [-da<nabin>r<nrbin>]\n");
      fprintf(stdout,"                [-E] [-G<xinc>/<yinc>] [-I<ignore>/<num>] \n");
      fprintf(stdout,"                [-O<outputfile>] [-Q<use>/<A>/<B>/<C>/<D>] \n");
      fprintf(stdout,"                [-R<west>/<east>/<south>/<north>] [-S] \n");
      fprintf(stdout,"                [-T<starttrajfile>/<trajstep>] [-V] \n\n");
      fprintf(stdout,"       format for input file is (type is ignored, but expected):\n");
      fprintf(stdout,"              latitude longitude azimuth type quality ...\n\n");
      fprintf(stdout,"       -L set <lambda> \n");
      fprintf(stdout,"          lambda controls the degree of smoothing. Smoothing is emphasized for \n");
      fprintf(stdout,"          high lambda, fidelity to the data for small lambda\n");
      fprintf(stdout,"       -N set the <number> of nearest neighbors used in smoothing\n");
      fprintf(stdout,"       -A set the search radius for nearest neighbors (<radius> in km)\n");
      fprintf(stdout,"       -B means do robustness checking of smoothed data (BETA, default: no)\n");
      fprintf(stdout,"       -C give the maximum number of iteration steps before program stops \n");
      fprintf(stdout,"          the iteration (default: %d)\n", DefaultMaxIterations);
      fprintf(stdout,"       -D <weightmethod> giving the method to use for distance weighting\n");
      fprintf(stdout,"           <twf>:   tricubic weight function\n");
      fprintf(stdout,"           <pdf>/<n>:   power distance weight function\n");
      fprintf(stdout,"            where <n> is the power of the distance (default: n=%d)\n", control.nid_power);
      fprintf(stdout,"          use with -A option\n");
      fprintf(stdout,"           <ntwf>:  number normalized tricubic weight function\n");
      fprintf(stdout,"           <nbtwf>: number and bin normalized tricubic weight function\n");
      fprintf(stdout,"           <npdf>/<n>:  number normalized power distance weight function (-A option)\n");
      fprintf(stdout,"           <nbpdf>/<n>: number and bin normalized power distance weight function (-A option)\n");
      fprintf(stdout,"          use with -N option\n");
      fprintf(stdout,"           <rtwf>:  rescaled tricubic weight function\n");
      fprintf(stdout,"           <rpdf>/<n>:  rescaled power distance weight function \n");
      fprintf(stdout,"       -d applies to number normalization of distance weights (-Dnbtwf or -Dnbpdf)\n");
      fprintf(stdout,"          <nabin>: number of azimuth bins (default nabin=%d)\n", DEF_NABIN);
      fprintf(stdout,"          <nrbin>: number of radius bins (default nrbin=%d)\n", DEF_NRBIN);
      fprintf(stdout,"       -E calculate sort of average deviation when writing gridded maps\n");
      fprintf(stdout,"          or trajectories; \n", grdm);
      fprintf(stdout,"          the average deviation is written in the fourth column of \n");
      fprintf(stdout,"          <outfile>.grdm and in the 3rd column of <outfile>.trjs\n");
      fprintf(stdout,"          Additional information are given in column 5 to 7 \n");
      fprintf(stdout,"       -G write gridded map to <outputfile>.%s \n", grdm);
      fprintf(stdout,"          <xinc> and <yinc> spacing in longitude and latitude in degrees \n");
      fprintf(stdout,"          <yinc> defaults to <xinc> \n");
      fprintf(stdout,"       -I <ignore> applies when calculating gridded maps or \n");
      fprintf(stdout,"          trajectories using option -A.\n");
      fprintf(stdout,"          Do not calculate a gridded datapoint or do not continue trajectory if\n");      
      fprintf(stdout,"            <n>: if less than <num> datapoints lie within search radius\n");
      fprintf(stdout,"            <w>: if the sum of all weights (distance*quality)\n");
      fprintf(stdout,"            is less than <num>\n");
      fprintf(stdout,"            <q>: if the sum of all quality weights is less than <num>\n");
      fprintf(stdout,"          Eg. with -In/5 no gridded datapoints for a specific location are\n");
      fprintf(stdout,"          calculated if less than 5 neighbours are found for smoothing.\n");
      fprintf(stdout,"          This option only applies to the calculation of the smoothed points,\n");
      fprintf(stdout,"          not to the iteration.\n");
      fprintf(stdout,"       -O <outputfile>: Name is <outputfile>.%s for gridded maps, \n", grdm);
      fprintf(stdout,"          <outputfile>.%s for smoothed datapoints and \n", sdat);
      fprintf(stdout,"          <outputfile>.%s for trajectories\n", trjs);
      fprintf(stdout,"          If no outputfile-name is given the name defaults to inputfile \n");
      fprintf(stdout,"       -Q <use> switch to define if quality information of datapoints is used.\n");
      fprintf(stdout,"          <n>: do not use quality information\n");
      fprintf(stdout,"          <y>: use quality information. <A>, <B>, <C>, <D> give the \n");
      fprintf(stdout,"          weight which is assigned to the respective quality\n");
      fprintf(stdout,"          default is: -Qy/%.2f/%.2f/%.2f/%.2f \n", Aquality, Bquality, Cquality, Dquality);      
      fprintf(stdout,"       -R specify region for gridded map and/or for trajectories\n");
      fprintf(stdout,"          defaults to region given by datapoints\n");
      fprintf(stdout,"       -S write the smoothed datapoints to <outputfile>.%s \n", sdat);
      fprintf(stdout,"       -T write trajectories to <outputfile>.%s \n", trjs);
      fprintf(stdout,"          the file starttrajfile has the following format: \n");
      fprintf(stdout,"          one line header, longitude latitude  \n");
      fprintf(stdout,"          starting from these points trajectories are calculated \n");
      fprintf(stdout,"          for every trajstep km (default of trajstep is: %.3lf km)\n", DefTrajStep);
      fprintf(stdout,"          Set starttrajfile to 'stdin' to read the startpoints from \n");
      fprintf(stdout,"          stdin during program run\n");
      fprintf(stdout,"       -V run in verbose mode \n\n");
      fprintf(stdout,"  No blank between parameter identifier and parameter! \n");

      return 1;
   }

   // check if all necessary parameters are given
   if (! control.FileIn) {
      fprintf(stderr, "ERROR: must specify input file \n");
      error++;
   }
   if (control.Lambda < 0.0) {
      fprintf(stderr, "ERROR: must supply lambda\n");
      error++;
   }
   if (control.ConstNNRadius == FALSE && control.ConstNNNumber == FALSE) {
      fprintf(stderr, "ERROR: no method given for smoothing, either give -A or -N \n");
      error++;
   }
   if (control.ConstNNRadius == TRUE && control.ConstNNNumber == TRUE) {
      fprintf(stderr, "ERROR: two methods for smoothing, either give -A or -N \n");
      error++;
   }
   if (control.ConstNNNumber == TRUE && (control.DistanceWeight == nnid || control.DistanceWeight == ntwf || \
                                         control.DistanceWeight == nbnid || control.DistanceWeight == nbtwf)) {
      fprintf(stderr, "WARNING: for option -N the number normalized distance weighting is\n");
      fprintf(stderr, "         rather unusual, please check if this is what you want to do !\n");
   } 
   if (control.ConstNNRadius == TRUE && (control.DistanceWeight == rnid || control.DistanceWeight == rtwf)) {
      fprintf(stderr, "WARNING: for option -A the rescaling of distance weighting is\n");
      fprintf(stderr, "         rather unusual, please check if this is what you want to do !\n");
   } 


   // break if error occured
   if (error != 0) {
      fprintf(stderr, "PROGRAM TERMINATED ... \n\n");
      return -2;
   }
   
   // defaults ....
   // check if output filename is given, if not set outputfilename to inputfile
   if (! control.FileOut) {
      control.FileOut = control.FileIn;
   }
   if (control.UseQuality == NOTSET) {   // no -Q option was specified, use defaults
      control.UseQuality = TRUE;
      control.Aquality = Aquality;
      control.Bquality = Bquality;
      control.Cquality = Cquality;
      control.Dquality = Dquality;
   }
   if (control.DistanceWeight == NOTSET) { //vero
      if (control.ConstNNRadius == TRUE) {
          control.DistanceWeight = rnid;
      } else if (control.ConstNNNumber == TRUE) {
          control.DistanceWeight = rtwf;    
      } else {
         fprintf(stderr, " ERROR: how did you manage to reach this point? \n");
      }
   }
         
   // give information about choosen parameters
   InfoControl(&control);

   if ((in=fopen(control.FileIn,"rt")) == NULL)  {
      fprintf(stderr, "ERROR: could not open input file %s\n\n", control.FileIn);
      return -1;
   }

   // read data from input file, check if NNNumber is larger than the number
   // of datapoints (this would make no sense)
   fprintf(stdout, "\n... reading data from file %s \n", control.FileIn);
   if ( (control.NoPoints=ReadData(in, &control, P)) <= 0) {
      fprintf(stderr, "Program terminated due to ERROR in function ReadData\n");
      return -1;
   } else if (control.NNNumber >= control.NoPoints)  {
      fprintf(stdout, "WARNING: the number of datapoints is smaller or equal to \n");
      fprintf(stdout, "      the number of nearest neighbours you want to use for smoothing\n");
      fprintf(stdout, "      this makes no sense, resetting number of nearest neighbours to %d\n", control.NoPoints-1);
      control.NNNumber = control.NoPoints-1;
   }
   
   // sort pointers to data structures in ascending x1 order,
   // qsort changes the order of the pointer on the data structure in the array P
   fprintf(stdout, "\n... sorting data for longitude \n");
   qsort( (void *) P, control.NoPoints, sizeof(struct data *), sort_function_x1);

   // write a copy of the actual array P in the array X1 (this array contains
   // the pointers on the datastructures sorted for ascending x1
   struct data **X1 = new data *[control.NoPoints];
   if ( X1 == NULL)  {
      fprintf(stderr,"ERROR: not enough memory for copy of x1 sorted pointers \n");
      return -1;
   } else {
      for (i=0; i<control.NoPoints; i++)  {
	 X1[i] = P[i];    // write sorted pointers in X1 array
	 P[i]->ix1 = i;   // write array index in datastructure
      }
   }

   // sort in ascending x2 order, qsort changes the order of the
   // pointer on the data structure in the array P
   fprintf(stdout, "\n... sorting data for latitude \n");
   qsort( (void *) P, control.NoPoints, sizeof(struct data *), sort_function_x2);

   // write a copy of the actual array P in the array X2 (this array contains
   // the pointers on the datastructures sorted for ascending x2
   struct data **X2 = new data *[control.NoPoints];
   if ( X2 == NULL)  {
      fprintf(stderr,"ERROR: not enough memory for copy of x2 sorted pointers \n");
      return -1;
   } else {
      for (i=0; i<control.NoPoints; i++)  {
	 X2[i] = P[i];    // write sorted pointer in array
	 P[i]->ix2 = i;   // write array index in datastructure
      }
   }

   // re-sort for index
   qsort( (void *) P, control.NoPoints, sizeof(struct data *), sort_function_index);

   GiveBoundaries(X1, X2, &control);

   // find the nearest neighbours for all points
   fprintf(stdout, "\n... searching the nearest neighbours \n");
   if ( FindNNForAllData(&control, P, X1, X2) != 0)  {
      fprintf(stderr,"ERROR: occured in function FindNNForAllData \n");
      return -1;
   }

   // calculate f for every datapoint
   fprintf(stdout, "\n... starting iteration \n");
   if ( HMsmooth(&control, P) != 0)  {
      fprintf(stderr, "ERROR: occured in function HMsmooth \n");
      return -1;
   }
    
   // write smoothed datapoints if desired 
   if (control.SmoothPoints) {
      fprintf(stdout, "\n... calculating and writing smoothed data\n");
      if (WriteSmoothPoints(argc, argv, &control, P) != 0)  {
         fprintf(stderr, "ERROR: occured in function WriteSmoothPoints\n");
      }
   }
     
   // write gridded map if desired
   if (control.Gridmap) {
      fprintf(stdout, "\n... calculating and writing gridded map\n");
      if (WriteGridmap(argc, argv, &control, P) != 0)  {
         fprintf(stderr, "ERROR: occured in function WriteGridmap\n");
      }
   }     

   // write trajectories if desired
   if (control.Trajectories) {
      fprintf(stdout, "\n... calculating and writing trajectories\n");
      if (WriteTrajectories(argc, argv, &control, P) != 0)  {
         fprintf(stderr, "ERROR: occured in function WriteTrajectories\n");
      }
   }     
   fprintf(stdout,"\nOutput written to file(s) %s\n\nProgram terminated sucessfully ...\n", control.FileOut);
   return 0;
}
