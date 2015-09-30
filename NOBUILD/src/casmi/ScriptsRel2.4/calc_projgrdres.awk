# Calculate the number of points in x and y direction for a projected grid
# with a given Resolution 
# 

BEGIN {
res = substr(res,3)
nx = width*res + 1
ny = height*res + 1 

# write info of projected gridfile resolution to file 
printf("     the subregion of the projected gridfile will have \n") > temp"/projgrd.info"
printf("     nx: %5.0d times ny: %5.0d points\n", nx, ny) >> temp"/projgrd.info"

# calculte product of nx * ny and print to stdout
print nx*ny

}