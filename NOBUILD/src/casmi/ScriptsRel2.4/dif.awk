#
#   AWK script to create psxy input file for empty dif (drilling induced fractures).
#
BEGIN{
   pi=4*atan2(1,1)
   sq3 = sqrt(3)

   if (keep != "yes") {    
      printf("NF A dif \n") > temp"/dif_A_NF"
      printf("TF A dif \n") > temp"/dif_A_TF"
      printf("SS A dif \n") > temp"/dif_A_SS"
      printf("U  A dif \n") > temp"/dif_A_U"
      printf("NF B dif \n") > temp"/dif_B_NF"
      printf("TF B dif \n") > temp"/dif_B_TF"
      printf("SS B dif \n") > temp"/dif_B_SS"
      printf("U  B dif \n") > temp"/dif_B_U"
      printf("NF C dif \n") > temp"/dif_C_NF"
      printf("TF C dif \n") > temp"/dif_C_TF"
      printf("SS C dif \n") > temp"/dif_C_SS"
      printf("U  C dif \n") > temp"/dif_C_U"
      printf("NF D dif \n") > temp"/dif_D_NF"
      printf("TF D dif \n") > temp"/dif_D_TF"
      printf("SS D dif \n") > temp"/dif_D_SS"
      printf("U  D dif \n") > temp"/dif_D_U"
      printf("NF E dif \n") > temp"/dif_E_NF"
      printf("TF E dif \n") > temp"/dif_E_TF"
      printf("SS E dif \n") > temp"/dif_E_SS"
      printf("U  E dif \n") > temp"/dif_E_U"
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

   if (typ=="DIF") {

       if(qual=="A") { 
         siz=sA
         len=lA
         fileout = temp"/dif_A_"
       }
       if(qual=="B") { 
         siz=sB
         len=lB
         fileout = temp"/dif_B_"
       }
       if(qual=="C") { 
         siz=sC
         len=lC
         fileout = temp"/dif_C_"
       }
       if(qual=="D"){ 
         siz=sD
         len=lD
         fileout = temp"/dif_D_"
       } 
       if(qual=="E"){ 
         siz=sE
         len=lE
         fileout = temp"/dif_E_"
       } 

       a = siz/2 * 1.2   # changed to * 1.2 vw.  
       l = len/2

       # generate box
       j=0
       for (i=0; i<=8; i++)  {

	    if (i==2*int(i/2)) { 
	       b=a
	    } else {
	       b=sin(pi/180*45)*a
	    }   
            ang=pi/180*(azi+i*45)
            cs = cos(ang)
            sn = sin(ang)
            r[j]=x+b*cs
            s[j]=y+b*sn
            j++
   
            if(i==4 || i==8)  {
              if (regime == "U" || regime == "L")  {
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

       #if(qual!="E") {
         if (use == "L")  {  # write to stdout
              print ">"
              for (i=0; i<j; i++)  {
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
