#
# read in stress data.prep file and select the choosen Quality 
# file format
#        col. 1: longitude (deg) new calculated point 99 km away
#        col. 2: latitude (deg) new calculated point 99 km away
#        col. 3: longitude (deg) original location 
#        col. 4: latitude (deg) original location
#        col. 5: azimuth of stress direction (deg)
#        col. 6: type 
#        col. 7: quality 
#        col. 8: regime 
# 
# passed by command line are the following informations
# SQualA SQualB SQualC SQualD SQualE
# which are set to y or n depending on the choice
# of the user.


{
  #SQualE = n
  ntotal++
  if (SQualA == "y")  {
    if($7 == "A") {
      print
      nsel++
    }  
  } if (SQualB == "y") {
    if($7 == "B") {
      print
      nsel++
    }  
  } if (SQualC == "y")  {
    if($7 == "C") {
      print
      nsel++
    }  
  } if (SQualD == "y") {
    if($7 == "D") {
      print
      nsel++
	}
  } if (SQualE == "y") {
    if($7 == "E") {
      print
      nsel++
	}
  }

}
END {
  if (nsel == 0) {
    print "     no stress data information available for the choosen quality " > temp"/info.filterquality"
      print "     total number of data processed:" ntotal                      >> temp"/info.filterquality"
  } else {
    print "    " nsel " out of " ntotal " data points of the desired quality were selected " > temp"/info.filterquality"
  }
  }
