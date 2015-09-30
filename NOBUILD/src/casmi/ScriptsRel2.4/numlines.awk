# count number of data lines, assume one line header
BEGIN{
   linenum = 0
}
{  
   linenum = linenum + 1   
} 
  END{
   print linenum-1      
}