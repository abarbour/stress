# calculate the scale of a projection
# input file contains two lines with projected x y values in inches.
# which are 0.4 degrees apart
# from input line the latitude (lat) where points were calculated is known
BEGIN{
lines=0
pi=4*atan2(1,1)
}
{ lines++ 
  if (lines == 1) {
     x1 = $1
     y1 = $2
  } else if (lines == 2) {
     x2 = $1
     y2 = $2
  }
}
END{
  # calculate the distance in cm
  distmap = 2.54 * sqrt( (x2-x1) * (x2-x1) + (y2-y1) * (y2-y1) )
  distreal =  0.4 * 637800000*pi/180*cos(pi*lat/180)
  scale = distreal/distmap
  
  printf("%d", scale+0.5)
}    
