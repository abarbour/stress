# script to prepare text file used for plotting sitecode. 
# The site code is plotted near the symbol, rectangular to the line 
# representing the direction

# Assume the following format:
# input file format:
# Format of stress.cartesian:
#    col. 1-3: cartesian  x, y, azi (mathematical from x over y positiv)
#              range of azi is from -180 to 180 
#    col. 4-6: geographic lon, lat, azi (NdegE)
#    col. 7  : type of data
#    col. 8  : quality
#    col. 9  : stress regime
#    col.10  : depth (not evaluated up to now)
#    col.11  : sitecode
# 
# output file format:
#    col. 1  : x
#    col. 2  : y
#    col. 3  : font size
#    col. 4  : angle (0)
#    col. 5  : fontno (0 = Helvetica)
#    col. 6  : justify (10 = bottom mid )
#    col. 7  : sitecode
# 
#
# input file from stdin, output to stdout
# fontsize, fonttype, size of symbols (sA, sB, sC, sD, sE) are 
# read from comand line

BEGIN{
 printf("      x       y   size   angle font justify        name \n") 
 offsetfact = 1.1
 d2r = 4*atan2(1,1)/180.

}
{
 if (NF >= 11) {   # take only those lines with sitecode information
    x = $1
    y = $2
    sitecode = $11
    azi = $3
 
    if ( (azi >= 0 && azi < 180) ) {
       angle = azi - 90
    } else if ( (azi >= -180 && azi < 0)) {
       angle = azi + 90 
    } 

    # calculate postion of text:
    if ($8 == "A") {
       dist = sA*0.5
    } else if ($8 == "B") {
       dist = sB*0.5
    } else if ($8 == "C") { 
       dist = sC*0.5
    } else if ($8 == "D") {
       dist = sD*0.5  
    } else if ($8 == "E") {
       dist = sE*0.5  
    }                
 
    newx = x+dist*offsetfact*cos(d2r*angle)
    newy = y+dist*offsetfact*sin(d2r*angle)

    printf("%8.3f %8.3f %3d 0.0 %1s 10 %7s\n",newx,newy,fontsize,fonttype,sitecode) 
  }
}
