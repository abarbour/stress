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
# STypeFMS STypeBO STypeHF STypeGI STypeOC STypeDFI STypeBS 
# which are set to y or n depending on the choice
# of the user.


{ ntotal++
  ##if (STypeFMS == "y")  {
  ##  if($6 =="FMS" || $6 =="FMA"|| $6 =="FMF") {
  ##    print
  ##    nsel++
  ##  }  
  if (STypeFMS == "y")  {
    if($6 =="FMS") {
      print
      nsel++
    }  
  } if (STypeFMA == "y")  {
    if($6 =="FMA") {
      print
      nsel++
    }  
  } if (STypeFMF == "y")  {
    if($6 =="FMF") {
      print
      nsel++
    }  
  } if (STypeOC == "y") {
    if($6 =="OC") {
      print
      nsel++
    }  
  } if (STypeBO == "y") {
    if($6=="BO"||$6=="BOC"||$6=="BOT") {
      print
      nsel++
    }  
  } if (STypeDIF == "y") {
    if($6=="DIF") {
      print
      nsel++
    }  
  } if (STypeBS == "y") {
    if($6=="BS") {
      print
      nsel++
    }  
  } if (STypeHF == "y") {
    if($6=="HF"||$6=="HFG"||$6=="HFM"||$6=="HFP"||$6=="HFS") {
      print
      nsel++
    }  
  } if (STypeGI == "y") {
    if ($6=="PC"||$6=="GFI"||$6=="GFM"||$6=="GFS"||$6=="GVA")  {
      print
      nsel++
    }      
  }
}
END {
  if (nsel == 0) {
    print "     no stress data information available for the choosen types " > temp"/info.filtertype"
    print "     total number of data processed:" ntotal                      >> temp"/info.filtertype"
  } else {
    print "    " nsel " out of " ntotal " data points of the desired types were selected " > temp"/info.filtertype"
  }
}
