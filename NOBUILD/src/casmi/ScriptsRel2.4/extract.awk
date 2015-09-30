#
# Drop all odd lines and third column.
#    This extracts geographic coordinates of newly generated 
#     points from output of project.
#
{
  l=NR
  l2 = 2*int(l/2)
  if (l == l2)
     { 
       x = $1
       y = $2
       printf("%9.3f %9.3f \n",x,y) 
     }
}
