#
#   AWK script to create psxy input file for empty circle (geological indicators).
#
BEGIN{
   pi=4*atan2(1,1)

   if (keep != "yes") {    
      printf("NF A circle \n") > temp"/circle_A_NF"
      printf("TF A circle \n") > temp"/circle_A_TF"
      printf("SS A circle \n") > temp"/circle_A_SS"
      printf("U  A circle \n") > temp"/circle_A_U"
      printf("NF B circle \n") > temp"/circle_B_NF"
      printf("TF B circle \n") > temp"/circle_B_TF"
      printf("SS B circle \n") > temp"/circle_B_SS"
      printf("U  B circle \n") > temp"/circle_B_U"
      printf("NF C circle \n") > temp"/circle_C_NF"
      printf("TF C circle \n") > temp"/circle_C_TF"
      printf("SS C circle \n") > temp"/circle_C_SS"
      printf("U  C circle \n") > temp"/circle_C_U"
      printf("NF D circle \n") > temp"/circle_D_NF"
      printf("TF D circle \n") > temp"/circle_D_TF"
      printf("SS D circle \n") > temp"/circle_D_SS"
      printf("U  D circle \n") > temp"/circle_D_U"
      printf("NF E circle \n") > temp"/circle_E_NF"
      printf("TF E circle \n") > temp"/circle_E_TF"
      printf("SS E circle \n") > temp"/circle_E_SS"
      printf("U  E circle \n") > temp"/circle_E_U"
   }
}
{
   x      = $1
   y      = $2
   azi    = $3
   typ    = $7
   qual   = $8
   regime = $9
   use    = $10

   if(typ=="FMS"||typ=="FMA"||typ=="FMF") {

       if(qual=="A") { 
         siz=sA
         len=lA
         fileout = temp"/circle_A_"
       }
       if(qual=="B") { 
         siz=sB
         len=lB
         fileout = temp"/circle_B_"
       }
       if(qual=="C") { 
         siz=sC
         len=lC
         fileout = temp"/circle_C_"
       }
       if(qual=="D"){ 
         siz=sD
         len=lD
         fileout = temp"/circle_D_"
       } 
       if(qual=="E"){ 
         siz=sE
         len=lE
         fileout = temp"/circle_E_"
       } 

       a = siz/2  
       l = len/2

       # generate circle
       j=0
       for (i=0; i<=30; i++)  {

            ang=pi/180*(azi+i*12)
            cs = cos(ang)
            sn = sin(ang)
            r[j]=x+a*cs
            s[j]=y+a*sn
            j++
            
            if(i==15 || i==30)  {
              if (regime == "U")  {
                r[j] = x+l*cs
                s[j] = y+l*sn
                j++
                r[j] = x
                s[j] = y
                j++
                r[j] = x+a*cs
                s[j] = y+a*sn
                j++
              } else {
                r[j] = x+l*cs
                s[j] = y+l*sn
                j++
                r[j] = x+a*cs
                s[j] = y+a*sn
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
