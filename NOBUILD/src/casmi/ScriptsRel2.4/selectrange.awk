#
# read in stress data file and check if azimuth is between 0 and 360 deg.
# write the "wrong" data to trash.dat, those which are ok to ok.dat 
# 
#
BEGIN {
       nselect = 0
}

{
  if ($3 > 360 || $3 < 0)  {
    printf("%8.3f %8.3f %3d %3s %1s %2s %8.3f %2s %3d \n",$1,$2,$3,$4,$5,$6,$7,$8,$9) >> temp"/trash.dat"
    ntrash++
  } else {
    printf("%8.3f %8.3f %3d %3s %1s %2s %8.3f %2s %3d \n",$1,$2,$3,$4,$5,$6,$7,$8,$9) 
  }  
}

END{

print " " ntrash " lines were removed and written to file temp"/trash.dat" > temp"/info.checkazi"

}