#
# read in stress data file and check if azimuth is between 0 and 360 deg.
#
# E quality data may have an azimuth outside this range.
# To have the possibility to plot E quality data, we do not
# remove these data but replace the azimuth with 0 for E qualtiy.
# Data with quality A to D must not have an azimuth outside this range. 
# Therefore write those "wrong" data to trash.dat, 
# write the other data which are ok to ok.dat 
# 
#
BEGIN { command = "rm -f "temp"/info.checkazi"
       system(command)
       ntrash = 0
}

{
  if ($3 > 360 || $3 < 0)  {
    if ($5 == "E")  {
      # replace azimuth with 0
      printf("%8.3f %8.3f %3d %3s %1s %2s %7.3f %5s %s %s %s %8.2f\n", $1, $2, "0", $4, $5, $6, $7, $8, $9, $10, $11, $12)
    } else {    
       print >> temp"/trash.dat"
       ntrash++
    }   
  }
  else {
    print
  }
}

END{
  if (ntrash == 0) {
    print "     no wrong azimuths were found " > temp"/info.checkazi"
  } else {
    print " " ntrash " lines with A-D quality data were removed and written to file "temp"/trash.dat" > temp"/info.checkazi"
    print " check this file for wrong data"                                                          >> temp"/info.checkazi"
  }
}
