# script to add information needed to plot names. 
# Assume the following format:
#   one line header
#   lon lat name [alignment (justification)]
#
# input file from stdin, output to stdout
# fontsize und fonttype und ofsetX und ofsetY werden uebegeben

BEGIN{
      printf("      x       y   size   angle font justify        name \n") 
     }
{
# skip first line, this is only the header
if( NR != 1) {
 x = $1
 y = $2
 name = $3
 alignment = $4
 angle = 0.0
 
 if (alignment == 1) {
   x = x + offsetX
   y = y + offsetY
 } else if (alignment == 2) { 
   y = y + offsetY
 } else if (alignment == 3) { 
   x = x - offsetX
   y = y + offsetY
 } else if (alignment == 5) { 
   x = x + offsetX
 } else if (alignment == 6) {
   x = x
   y = y 
 } else if (alignment == 7) { 
   x = x - offsetX
 } else if (alignment == 9) { 
   x = x + offsetX
   y = y - offsetY
 } else if (alignment == 10) { 
   y = y - offsetY
 } else if (alignment == 11) { 
   x = x - offsetX
   y = y - offsetY
 } else {
   x = x + offsetX
   y = y + offsetY
   alignment = 1
 }  
 
 printf("%8.3f %8.3f %3d %8.3f %1s %1s %24s\n",x,y,fontsize,angle,fonttype,alignment,name) 
}

}
