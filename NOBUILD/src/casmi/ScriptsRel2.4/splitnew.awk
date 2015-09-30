#
# write col. 1 and col. 2 to stdout 
# (coordinates of newly generated points).
# columns 3, 4, 5, 6, 7 and 8  will be extracted in splitold.awk
# This splitting is realised in two scripts to be able to write to stdout,
# to increase speed.
#
{
  printf("%8.3f %8.3f\n",$1,$2)
}
