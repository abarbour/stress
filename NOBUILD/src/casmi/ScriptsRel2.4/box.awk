#
#   AWK script to create psxy input file for empty box (geological indicators).
#
BEGIN{
   pi=4*atan2(1,1)
   sq3 = sqrt(3)

   if (keep != "yes") {    
      printf("NF A box \n") > temp"/box_A_NF"
      printf("TF A box \n") > temp"/box_A_TF"
      printf("SS A box \n") > temp"/box_A_SS"
      printf("U  A box \n") > temp"/box_A_U"
      printf("NF B box \n") > temp"/box_B_NF"
      printf("TF B box \n") > temp"/box_B_TF"
      printf("SS B box \n") > temp"/box_B_SS"
      printf("U  B box \n") > temp"/box_B_U"
      printf("NF C box \n") > temp"/box_C_NF"
      printf("TF C box \n") > temp"/box_C_TF"
      printf("SS C box \n") > temp"/box_C_SS"
      printf("U  C box \n") > temp"/box_C_U"
      printf("NF D box \n") > temp"/box_D_NF"
      printf("TF D box \n") > temp"/box_D_TF"
      printf("SS D box \n") > temp"/box_D_SS"
      printf("U  D box \n") > temp"/box_D_U"
      printf("NF E box \n") > temp"/box_E_NF"
      printf("TF E box \n") > temp"/box_E_TF"
      printf("SS E box \n") > temp"/box_E_SS"
      printf("U  E box \n") > temp"/box_E_U"
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

   if (typ=="PC"||typ=="GFI"||typ=="GFM"||typ=="GFS"||typ=="GVA") {

       if(qual=="A") { 
         siz=sA
         len=lA
         fileout = temp"/box_A_"
       }
       if(qual=="B") { 
         siz=sB
         len=lB
         fileout = temp"/box_B_"
       }
       if(qual=="C") { 
         siz=sC
         len=lC
         fileout = temp"/box_C_"
       }
       if(qual=="D"){ 
         siz=sD
         len=lD
         fileout = temp"/box_D_"
       } 
       if(qual=="E"){ 
         siz=sE
         len=lE
         fileout = temp"/box_E_"
       } 

       a = siz/2 * 1.2   # changed to * 1.2 vw.  
       l = len/2

       # generate box
       j=0
       for (i=0; i<=8; i++)  {

	    if (i==2*int(i/2)) { 
	       b=sin(pi/180*45)*a
	    } else {
	       b=a
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
