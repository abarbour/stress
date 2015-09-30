# creating a series of lon = 0 to lon = 360, lat = lat_fixed, starting with 
# lat_fixed = 0 in steps of +LatInc to 90 and lat_fixed = 0 -LatInc to -90
# used for PlateMotion


BEGIN{
  step = 2
  for ( lat = 90-LatInc; lat > -90; lat=lat-LatInc) {
    for (i=0; i<=360; i=i+step) {
      print i"  "lat
    }
  }
}


