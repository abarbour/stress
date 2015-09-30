# awk script to split a multiple segment file into several single segment 
# files each with its own penstyle and fill.
#
# expected file format for the multiple segment file:
# first line: HEADER
# one or more segments, each seperated by 
# [x,] >, Segment name, pen style (for example 4/0/0/0ta), fill pattern
# if a segment starts with an "x" it will be omitted.

# If a fill pattern is given, the endpoints of each segment will be connected
# automatically. For plotting closed polygons without filling, set fill to "close",
# For plotting lines (endpoints will not be connected) set fill to "no".
#
# via command line the following information is given:
# mpolygdata: name of file with the multiple segment (without path), used for creating 
# the names of the single files.
# temp: the temporary directory.
# append: append to existing MEPolyg.... files if append is set to yes, if not
# delete old MPolyg files

BEGIN {
segment = 0
line = 0
if (append != "yes") {
  printf (" ") > temp"/MEPolygData"
  printf (" ") > temp"/MEPolygPenAttri"
  printf (" ") > temp"/MEPolygFilCol"
  outputfile = "dummy"
}

# extract first part from multiple file segment name 
split(mpolygdata, namearray, ".")
name = namearray[1]

}

{
line++

if (line != 1) {       # skip header line

   if ($1 == "x" || $1 == "x," || $1 == "x>," || $1 == "x>") {   # skip segment with x

      read = "no"

   } else if ($1 == ">" || $1 == ">," || $1 == ",>" || $1 == ",") {

      read = "yes"
      headline = $0
      
      if ( (numparam = split(headline, param, ",")) < 4) {
         print " Wrong file format in line " line
         print "   found " numparam " parameters, expecting 4 or more"
         print "   skipping this segment"
         read = "no"

      }
      
      if (read == "yes" )  {
        segment++
        if (segment == 1) {
      
          printf("     extracting polygon segment number  %4d", segment) 
      
        } else {
          printf("\b\b\b\b%4d",segment)
          close (outputfile)
        }
      
        outputfile = temp"/"name segment param[2]".gmt"
        gsub(" ", "_",outputfile) 
        print "Segment number "segment" extracted from " mpolygfile > outputfile
        print param[1]" ,"param[2]" ,"param[3]" ,"param[4]  >> outputfile

        printf("%s ", outputfile) >> temp"/MEPolygData"
        printf("%s ", param[3])   >> temp"/MEPolygPenAttri"
        if (filigno == "y" ) {
           printf("%s ","close")  >> temp"/MEPolygFilCol"
        } else {
           printf("%s ", param[4]) >> temp"/MEPolygFilCol"
        }

      }  
      
   } else if (NF >= 2 && read == "yes") {

      print $0 >> outputfile

   } else if (NF >= 2 && read == "no") {
      

   } else {

      print   " Unexpected file format check file "mpolygfile
      print   " segment " segment "line " line
      print   " found " $0
}   
      
      
      
}      
   
}
