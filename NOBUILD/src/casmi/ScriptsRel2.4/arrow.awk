#
#   AWK script to create psxy input file for empty arrow (borehole breakouts).
#
BEGIN{
   pi=4*atan2(1,1)
   sq3 = sqrt(3)

   if (keep != "yes") {    
      printf("NF A arrow \n") > temp"/arrow_A_NF"
      printf("TF A arrow \n") > temp"/arrow_A_TF"
      printf("SS A arrow \n") > temp"/arrow_A_SS"
      printf("U  A arrow \n") > temp"/arrow_A_U"
      printf("NF B arrow \n") > temp"/arrow_B_NF"
      printf("TF B arrow \n") > temp"/arrow_B_TF"
      printf("SS B arrow \n") > temp"/arrow_B_SS"
      printf("U  B arrow \n") > temp"/arrow_B_U"
      printf("NF C arrow \n") > temp"/arrow_C_NF"
      printf("TF C arrow \n") > temp"/arrow_C_TF"
      printf("SS C arrow \n") > temp"/arrow_C_SS"
      printf("U  C arrow \n") > temp"/arrow_C_U"
      printf("NF D arrow \n") > temp"/arrow_D_NF"
      printf("TF D arrow \n") > temp"/arrow_D_TF"
      printf("SS D arrow \n") > temp"/arrow_D_SS"
      printf("U  D arrow \n") > temp"/arrow_D_U"
      printf("NF E arrow \n") > temp"/arrow_E_NF"
      printf("TF E arrow \n") > temp"/arrow_E_TF"
      printf("SS E arrow \n") > temp"/arrow_E_SS"
      printf("U  E arrow \n") > temp"/arrow_E_U"
   }
}
{
   x      = $1
   y      = $2
   azi    = $3
   typ    = $7
   qual   = $8
   regime = $9
   use    = $10    # this switch is used to write to sdout (used for legend)

   if (typ=="BO"||typ=="BOC"||typ=="BOT") {

       if(qual=="A") { 
         siz=sA
         len=lA
         fileout = temp"/arrow_A_"
       }
       if(qual=="B") { 
         siz=sB
         len=lB
         fileout = temp"/arrow_B_"
       }
       if(qual=="C") { 
         siz=sC
         len=lC
         fileout = temp"/arrow_C_"
       }
       if(qual=="D"){ 
         siz=sD
         len=lD
         fileout = temp"/arrow_D_"
       } 
       if(qual=="E"){ 
         siz=sE
         len=lE
         fileout = temp"/arrow_E_"
       } 

       a = siz/2         # headlength of arrow
       l = len/2
       openangle = 30    # open angle of arrow, angle between direction and side of arrow
       b = 0.577*a       # half headwidth of arrow, here opening angle 30 deg
       c = a / 0.866025  # sidelength of arrow - head

       # generate arrow
       j=0
       for (i=0; i<=12; i++)  {

	    if (i==0 || i==6 || i==12) {
	       b=a
	    } else if (i==1 || i==5 || i==7 || i==11) {   
	       b=a/cos(pi/180*openangle)
	    } else if (i==2 || i == 8) {
	       b=0      # middle point
	    } else {
	       b = -1   # no point here
	    }   
            ang=pi/180*(azi+i*30)
            cs = cos(ang)
            sn = sin(ang)
            
            if (b != -1)  {
              r[j]=x+b*cs
              s[j]=y+b*sn
              j++
            
              if(i==6 || i==12)  {
                if (regime == "U")  {
                  r[j] = x+l*cs
                  s[j] = y+l*sn
                  j++
                  r[j] = x
                  s[j] = y
                  j++
                  r[j]=x+b*cs
                  s[j]=y+b*sn
                  j++
                } else {
                  r[j] = x+l*cs
                  s[j] = y+l*sn
                  j++
                  r[j]=x+b*cs
                  s[j]=y+b*sn
                  j++
                }  
              }   
           }    
       }  

       #if(qual!="E") {
         if (use == "L")  {        # write to stdout
 	      print ">"
              for (i=0; i<j; i++) {
	          printf("%9.3f %9.3f\n", r[i], s[i]) 
              }
         } else { 
           if(regime=="NF"||regime=="NS") {
	      print ">" >> fileout"NF"
              for (i=0; i<j; i++) {
	          printf("%9.3f %9.3f\n", r[i], s[i]) >> fileout"NF" 
              }
           } else if(regime=="TF"||regime=="TS") {
	      print ">" >> fileout"TF"
              for (i=0; i<j; i++) {
	          printf("%9.3f %9.3f\n", r[i], s[i]) >> fileout"TF" 
              }
           } else if(regime=="SS") {
              print ">" >> fileout"SS"
              for (i=0; i<j; i++) {
	          printf("%9.3f %9.3f\n", r[i], s[i]) >> fileout"SS" 
             }
           } else if(regime=="U") {
              print ">" >> fileout"U"
              for (i=0; i<j; i++) {
	          printf("%9.3f %9.3f\n", r[i], s[i]) >> fileout"U" 
              }
           }   
         }
       #}
    }
}
