# Extract x and y resolution from grdinfo run. Calculate the number of points 
# in x and y direction for a given longitude and latitude interval (lon1, lon2 
# lat1, lat2; will be supplied by command line as range)
# 
#
BEGIN { line = 0 
split(range,coor,"/")
coor[1] = substr(coor[1],3)
}
{
  line++
  if ( line == 6 ) {                          # line with x information
     x_inc = $7
  } 
  if ( line == 7)  {
     y_inc = $7 
  }   
}
END{
 
# calculate number of points in x direction:
nx = (coor[2] - coor[1])/x_inc + 1
# calculate number of points in y direction:
ny = (coor[4] - coor[3])/y_inc + 1

# write info of original gridfile resolution to file 
printf("     the subregion of the original gridfile has \n") > temp"/origgrd.info"
printf("     nx: %5.0d times ny: %5.0d points\n", nx, ny) >> temp"/origgrd.info"

# calculte product of nx * ny and print to stdout
print nx*ny

}