#
# write col. 3, 4, 5, 6, 7, 8, 9 to stdout 
# columns 1 and 2 will be extracted in splitnew.awk
# This splitting is realised in two scripts to be able to write to stdout,
# to increase speed.
 
{
  printf("%8.3f %8.3f %3d %3s %1s %2s %7.3f %6s\n",$3,$4,$5,$6,$7,$8,$9,$10) 
}
