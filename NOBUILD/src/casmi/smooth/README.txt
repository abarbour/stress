
         SMOOTH - a program to smooth stress direction data
                           Version 2.2 
                     written by Veronika Wehrle 

  USAGE: smooth <inputfile> -L<lambda> -N<number> -A<radius> 
                [-B] [-C<iterations>] [-D<weightmethod>] [-da<nabin>r<nrbin>]
                [-E] [-G<xinc>/<yinc>] [-I<ignore>/<num>] 
                [-O<outputfile>] [-Q<use>/<A>/<B>/<C>/<D>] 
                [-R<west>/<east>/<south>/<north>] [-S] 
                [-T<starttrajfile>/<trajstep>] [-V] 

       format for input file is (type is ignored, but expected):
              latitude longitude azimuth type quality ...

       -L set <lambda> 
          lambda controls the degree of smoothing. Smoothing is emphasized for 
          high lambda, fidelity to the data for small lambda
       -N set the <number> of nearest neighbors used in smoothing
       -A set the search radius for nearest neighbors (<radius> in km)
       -B means do robustness checking of smoothed data (BETA, default: no)
       -C give the maximum number of iteration steps before program stops 
          the iteration (default: 1500)
       -D <weightmethod> giving the method to use for distance weighting
           <twf>:   tricubic weight function
           <pdf>/<n>:   power distance weight function
            where <n> is the power of the distance (default: n=2)
          use with -A option
           <ntwf>:  number normalized tricubic weight function
           <nbtwf>: number and bin normalized tricubic weight function
           <npdf>/<n>:  number normalized power distance weight function (-A option)
           <nbpdf>/<n>: number and bin normalized power distance weight function (-A option)
          use with -N option
           <rtwf>:  rescaled tricubic weight function
           <rpdf>/<n>:  rescaled power distance weight function 
       -d applies to number normalization of distance weights (-Dnbtwf or -Dnbpdf)
          <nabin>: number of azimuth bins (default nabin=8)
          <nrbin>: number of radius bins (default nrbin=5)
       -E calculate sort of average deviation when writing gridded maps
          or trajectories; 
          the average deviation is written in the fourth column of 
          <outfile>.grdm and in the 3rd column of <outfile>.trjs
          Additional information are given in column 5 to 7 
       -G write gridded map to <outputfile>.grdm 
          <xinc> and <yinc> spacing in longitude and latitude in degrees 
          <yinc> defaults to <xinc> 
       -I <ignore> applies when calculating gridded maps or 
          trajectories using option -A.
          Do not calculate a gridded datapoint or do not continue trajectory if
            <n>: if less than <num> datapoints lie within search radius
            <w>: if the sum of all weights (distance*quality)
            is less than <num>
            <q>: if the sum of all quality weights is less than <num>
          Eg. with -In/5 no gridded datapoints for a specific location are
          calculated if less than 5 neighbours are found for smoothing.
          This option only applies to the calculation of the smoothed points,
          not to the iteration.
       -O <outputfile>: Name is <outputfile>.grdm for gridded maps, 
          <outputfile>.sdat for smoothed datapoints and 
          <outputfile>.trjs for trajectories
          If no outputfile-name is given the name defaults to inputfile 
       -Q <use> switch to define if quality information of datapoints is used.
          <n>: do not use quality information
          <y>: use quality information. <A>, <B>, <C>, <D> give the 
          weight which is assigned to the respective quality
          default is: -Qy/1.00/0.75/0.50/0.25 
       -R specify region for gridded map and/or for trajectories
          defaults to region given by datapoints
       -S write the smoothed datapoints to <outputfile>.sdat 
       -T write trajectories to <outputfile>.trjs 
          the file starttrajfile has the following format: 
          one line header, longitude latitude  
          starting from these points trajectories are calculated 
          for every trajstep km (default of trajstep is: 2.000 km)
          Set starttrajfile to 'stdin' to read the startpoints from 
          stdin during program run
       -V run in verbose mode 

  No blank between parameter identifier and parameter! 
