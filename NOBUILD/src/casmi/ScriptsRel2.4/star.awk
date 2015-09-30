#
#   AWK script to create psxy input file for empty star (hydraulic fractures).
#
BEGIN{
   pi=4*atan2(1,1)
   sq3 = sqrt(3)

   if (keep != "yes") {    
      printf("NF A star \n") > temp"/star_A_NF"
      printf("TF A star \n") > temp"/star_A_TF"
      printf("SS A star \n") > temp"/star_A_SS"
      printf("U  A star \n") > temp"/star_A_U"
      printf("NF B star \n") > temp"/star_B_NF"
      printf("TF B star \n") > temp"/star_B_TF"
      printf("SS B star \n") > temp"/star_B_SS"
      printf("U  B star \n") > temp"/star_B_U"
      printf("NF C star \n") > temp"/star_C_NF"
      printf("TF C star \n") > temp"/star_C_TF"
      printf("SS C star \n") > temp"/star_C_SS"
      printf("U  C star \n") > temp"/star_C_U"
      printf("NF D star \n") > temp"/star_D_NF"
      printf("TF D star \n") > temp"/star_D_TF"
      printf("SS D star \n") > temp"/star_D_SS"
      printf("U  D star \n") > temp"/star_D_U"
      printf("NF E star \n") > temp"/star_E_NF"
      printf("TF E star \n") > temp"/star_E_TF"
      printf("SS E star \n") > temp"/star_E_SS"
      printf("U  E star \n") > temp"/star_E_U"
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

   if (typ=="HF"||typ=="HFG"||typ=="HFM"||typ=="HFP"||typ=="HFS") {

       if(qual=="A") { 
         siz=sA
         len=lA
         fileout = temp"/star_A_"
       }
       if(qual=="B") { 
         siz=sB
         len=lB
         fileout = temp"/star_B_"
       }
       if(qual=="C") { 
         siz=sC
         len=lC
         fileout = temp"/star_C_"
       }
       if(qual=="D"){ 
         siz=sD
         len=lD
         fileout = temp"/star_D_"
       } 
       if(qual=="E"){ 
         siz=sE
         len=lE
         fileout = temp"/star_E_"
       } 

       a = siz*sq3/6 * 1.2 # changed from /4 to /6 vw. 
       l = len/2

       # generate star of David
       j=0
       for (i=0; i<=12; i++)  {

	    if (i==2*int(i/2)) { 
	       b=sq3*a
	    } else  {
	       b=a
	    }   
            ang=pi/180*(azi+i*30)
            cs = cos(ang)
            sn = sin(ang)
            r[j]=x+b*cs
            s[j]=y+b*sn
            j++
            
            if(i==6 || i==12)  {
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
       
         if (use == "L" ) {
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
