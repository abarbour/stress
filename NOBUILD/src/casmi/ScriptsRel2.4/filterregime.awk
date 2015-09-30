#
# read in stress data.prep file and select the choosen Quality and Type
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
# SRegimeTF SRegimeTS SRegimeSS SRegimeNS SRegimeNF SRegimeU
# which are set to y or n depending on the choice
# of the user.


{ ntotal++
  ##if (STypeFMS == "y")  {
  ##  if($6 =="FMS" || $6 =="FMA"|| $6 =="FMF") {
  ##    print
  ##    nsel++
  ##  }  
  if (SRegimeTF == "y")  {
    if($8 =="TF") {
      print
      nsel++
    }  
  } if (SRegimeTS == "y") {
    if($8 =="TS") {
      print
      nsel++
    }  
  } if (SRegimeSS == "y") {
    if($8 =="SS") {
      print
      nsel++
    }  
  } if (SRegimeNS == "y") {
    if($8 =="NS") {
      print
      nsel++
    }  
  } if (SRegimeNF == "y") {
    if($8 =="NF") {
      print
      nsel++
    }  
  } if (SRegimeU == "y") {
    if($8 =="U") {
      print
      nsel++
    }  
  }
}
END {
  if (nsel == 0) {
    print "     no stress data information available for the choosen regimes " > temp"/info.filterregime"
    print "     total number of data processed:" ntotal                      >> temp"/info.filterregime"
  } else {
    print "    " nsel " out of " ntotal " data points of the desired regimes were selected " > temp"/info.filterregime"
  }
}
