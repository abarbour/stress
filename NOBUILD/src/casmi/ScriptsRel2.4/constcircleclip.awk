#
# read in CirclePoint.pq file and clip to the map boundaries

#        col. 1: longitude (deg) 
#        col. 2: latitude (deg) 
# 
# passed by command line are the following informations
# lon1 lon2 lat1 lat2 defining the choosen region.

BEGIN { 
       if (lon2 > 180) {
         range2search = 2
         lon2 = lon2 - 360
       } else {
         range2search =1
       } 
       
       clip = 0    
       
}

{
  if (range2search == 1) {
    if ($1 >= lon1 && $1 <= lon2 && $2 >= lat1 && $2 <= lat2 )  {
      print
      clip = 0
    } else {
      if (clip == 0) {
        print ">"
        clip = 1
      }  
    }  
  } else if (range2search == 2 ) {
    if ($1 >= lon1 && $1 <= 180 && $2 >= lat1 && $2 <= lat2 ||    \
        $1 >= -180 && $1 <= lon2 && $2 >= lat1 && $2 <= lat2 )  {
      print
      clip = 0
    } else {
      if (clip == 0) {
        print ">"
        clip = 1
      }  
    }
  }  
     
}
