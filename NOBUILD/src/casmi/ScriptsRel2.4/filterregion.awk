#
# read in stress data.prep file and select the choosen Quality and Type
# file format
#        col. 1: longitude (deg) new calculated point 99 km away
#        col. 2: latitude (deg) new calculated point 99 km away
#        col. 3: longitude (deg) original location (between -180 and 180 deg)
#        col. 4: latitude (deg) original location
#        col. 5: azimuth of stress direction (deg)
#        col. 6: type 
#        col. 7: quality 
#        col. 8: regime 
# 
# passed by command line are the following informations
# lon1 lon2 lat1 lat2 defining the choosen region.

BEGIN { 
       nfilter = 0
       ntotal = 0
       if (lon2 > 180) {
         range2search = 2
         lon2 = lon2 - 360
       } else {
         range2search =1
       }     
       
}

{
  ntotal++
  if (range2search == 1) {
    if ($3 >= lon1 && $3 <= lon2 && $4 >= lat1 && $4 <= lat2 )  {
      print
      nfilter++ 
    } 
  } else if (range2search == 2 ) {
    if ($3 >= lon1 && $3 <= 180 && $4 >= lat1 && $4 <= lat2 ||    \
        $3 >= -180 && $3 <= lon2 && $4 >= lat1 && $4 <= lat2 )  {
        print
        nfilter++ 
    } 
  }  
     
}

END {
  if (nfilter == 0 && ntotal != 0) {
    print "     no stress data information available in the choosen region " > temp"/info.filterregion"
    print "     total number of data processed:" ntotal                     >> temp"/info.filterregion"
  } else {
    print "    " nfilter " out of " ntotal " data points in the desired region were selected " > temp"/info.filterregion"
  }
}
