# creating one serie of lon = 0 to lon = 360, radius in km (given by commandline)


BEGIN{
  
  # calculate the latitude which equals the radius
  
  lat = 90 - (360 * radius / (2*3.1415927*6371))
  step = 2
  
  
  for (i=0; i<=360; i=i+step) {
      print i"  "lat
  }

}


