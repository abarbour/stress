# Program reads Elon, Elat (Position of Euler pole), RadInc from comando
# line and returns poligons of small circles centered at Euler pole,
# starting with opening radius of 0 increasing with RadInc up to 180 deg.
# output is written to stdout 
BEGIN{

pi = 4.0*atan2(1,1);
deg2rad = pi/180;
rad2deg = 180/pi;
for (r=RadInc; r<180; r=r+RadInc) {
  print ">"
  for (i=0; i<=360 ; i=i+10) {
     Plon = Elon + sin(deg2rad*i)*r
     Plat = Elat + cos(deg2rad*i)*r
     print Plon"  "Plat
  }
}
}
