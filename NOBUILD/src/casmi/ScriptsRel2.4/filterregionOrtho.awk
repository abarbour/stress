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
# lat_pro and lon_pro defining the projection center for the orthographic 
# projection.
# We want only those datapoints which are less than 1/4 Earthradius away from 
# the projection center. 

BEGIN { 
    nfilter = 0
    ntotal = 0
    d2r = 4*atan2(1.0,1.0)/180.0
    a0 = cos(d2r*lat_pro)*cos(d2r*lon_pro)
    a1 = cos(d2r*lat_pro)*sin(d2r*lon_pro)
    a2 = sin(d2r*lat_pro)
}

{
  ntotal++
  lonr = d2r*$3
  latr = d2r*$4
  b0 = cos(latr)*cos(lonr)
  b1 = cos(latr)*sin(lonr)
  b2 = sin(latr)
  
  dotproduct = a0*b0+a1*b1+a2*b2
  
  if (dotproduct > 0) {
      print
      nfilter++ 
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
