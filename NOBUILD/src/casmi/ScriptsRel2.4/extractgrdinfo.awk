# Extract Region and Projection from grdinfo run. 
# 
#
BEGIN { line = 0 
}
{
  line++
  if ( line == 2 ) {
      if (origfile == $4 && range == $5 && proj == $6 && $8 == resol) { 
        print "ok"
      } else {
        print "no"
      }   
  }    
}
