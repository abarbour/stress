BEGIN{
 line = 0
 write = 0
 print "# range: "mini" "maxi
}
{

line = line +1
if (line != 1) {

  if ($1 == ">" && write == 1) {
     print ">"
    
  } else if (NF == 3) { 
 
     if ($3 <= maxi && $3 >= mini) {
       if (write == 0) {
         print ">"
         print px"  "py
         print $1"  "$2"  "$3
         write = 1
       } else {
         print $1"  "$2"  "$3     
       }   
     } else {
       write = 0
     } 
  }
}
  
px = $1
py = $2

}