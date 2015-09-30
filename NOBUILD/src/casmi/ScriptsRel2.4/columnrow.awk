# return the value stored in the 'row' row and the 'column' column. Assume one
# line header
BEGIN{
   rownum = 0
}
{  
   if (rownum == row) {
      print $column
   } 
   rownum = rownum+1     
}   
