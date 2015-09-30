# SH: 19.Sept.98
# read in stress data.prep file and select the choosen depth 
# file format
#        col. 1: longitude (deg) new calculated point 99 km away
#        col. 2: latitude (deg) new calculated point 99 km away
#        col. 3: longitude (deg) original location 
#        col. 4: latitude (deg) original location
#        col. 5: azimuth of stress direction (deg)
#        col. 6: type 
#        col. 7: quality 
#        col. 8: regime 
#        col. 9: depth 
# 
# passed by command line are the following informations
# SDepthTop SDepthBot
# which are set to values depending on the choice
# of the user.


{ 
  ntotal++
  if ( ($9 >= SDepthTop) && ($9 <= SDepthBot) && ($9 != 999.000) ) {
     print
     nsel++
  }
}
END {
  if (nsel == 0) {
    print "     no stress data information available for the choosen depth " > temp"/info.filterdepth"
    print "     total number of data processed:" ntotal                      >> temp"/info.filterdepth"
  } else {
    print "    " nsel " out of " ntotal " data points of the desired depth were selected " > temp"/info.filterdepth"
  }
}
