#
#   AWK script to create psxy input file for arrow (borehole breakouts).
#
BEGIN{pi=4*atan2(1,1)
  if (keep != "yes") {
      printf("SS A semi arrow \n") > temp"/semiarrow_A_SS"
      printf("SS B semi arrow \n") > temp"/semiarrow_B_SS"
      printf("SS C semi arrow \n") > temp"/semiarrow_C_SS"
      printf("SS D semi arrow \n") > temp"/semiarrow_D_SS"
      printf("SS E semi arrow \n") > temp"/semiarrow_E_SS"
  }
}
{  x      = $1
   y      = $2
   azi    = $3
   typ    = $7
   qual   = $8
   regime = $9
   use    = $10

   fac    = pi/180

   if (typ=="BO"||typ=="BOC"||typ=="BOT") {

     if (regime=="SS")  {
     
       if(qual=="A") { 
         len=sA
         fileout = temp"/semiarrow_A_"
       }
       if(qual=="B") { 
         len=sB
         fileout = temp"/semiarrow_B_"
       }
       if(qual=="C") { 
         len=sC
         fileout = temp"/semiarrow_C_"
       }
       if(qual=="D"){ 
         len=sD
         fileout = temp"/semiarrow_D_"
       } 
       if(qual=="E"){ 
         len=sE
         fileout = temp"/semiarrow_E_"
       } 

       a = len/2         # headlength of arrow
       b = 0.577*a       # half headwidth of arrow, here opening angle 30 deg
       c = a / 0.866025  # sidelength of arrow - head

       r[0] = x
       s[0] = y
       
       ang = fac*(90 - azi)
       r[1] = x+a*sin(ang)
       s[1] = y+a*cos(ang)

       ang = fac*(90 - (azi + 30))
       r[2] = x+c*sin(ang)
       s[2] = y+c*cos(ang)

       r[3] = x
       s[3] = y
       
       ang = fac*(90 - (azi + 180))
       r[4] = x+a*sin(ang)
       s[4] = y+a*cos(ang)

       ang = fac*(90 - (azi + 150))
       r[5] = x+c*sin(ang)
       s[5] = y+c*cos(ang)
       
       #if(qual!="E") {

          if (use == "L")  {   # write to stdout

            print ">" 
            for (i=0; i <= 2; i++) {
               printf("%9.3f %9.3f\n", r[i], s[i]) 
            }
            print ">" 
            for (i=3; i <= 5; i++) {
               printf("%9.3f %9.3f\n", r[i], s[i]) 
            }

        } else {

             print ">" >> fileout"SS"
             for (i=0; i <= 2; i++) {
                printf("%9.3f %9.3f\n", r[i], s[i]) >> fileout"SS"
             }
             print ">" >> fileout"SS"
             for (i=3; i <= 5; i++) {
                printf("%9.3f %9.3f\n", r[i], s[i]) >> fileout"SS"
             }
         }
             
       #}

    }  
      
  }
}  

