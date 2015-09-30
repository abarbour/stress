#
#   AWK script to create psxy input file for semi-filled box 
#            (geologic indicators).
#
BEGIN{pi=4*atan2(1,1)
  if (keep != "yes" ) {
      printf("SS box A Quality\n") > temp"/semibox_A_SS"
      printf("SS box B Quality\n") > temp"/semibox_B_SS"
      printf("SS box C Quality\n") > temp"/semibox_C_SS"
      printf("SS box D Quality\n") > temp"/semibox_D_SS"
      printf("SS box E Quality\n") > temp"/semibox_E_SS"
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

   if (typ=="PC"||typ=="GFI"||typ=="GFM"||typ=="GFS"||typ=="GVA") {

      if(regime=="SS")  {
	   
         if(qual=="A") len=sA
         if(qual=="B") len=sB
         if(qual=="C") len=sC
         if(qual=="D") len=sD
         if(qual=="E") len=sE

         a = len/2 * 1.2   # changed to * 1.2 vw. 
         b = a/sqrt(2)

         ang = fac*azi
         cs = cos(ang)
         sn = sin(ang)
         r[0]=x+b*cs
         s[0]=y+b*sn
         r[4]=x+b*cs
         s[4]=y+b*sn
         r[3]=x-b*cs
         s[3]=y-b*sn

         ang = fac* (azi+45)
         cs = cos(ang)
         sn = sin(ang)
         r[1]=x+a*cs
         s[1]=y+a*sn

         ang = fac* (azi+135)
         cs = cos(ang)
         sn = sin(ang)
         r[2]=x+a*cs
         s[2]=y+a*sn
         
         if (use == "L" ) {
           if(qual == "A") {
              print ">"
              for (i=0; i <= 4; i++) {
               printf("%9.3f %9.3f\n", r[i], s[i])
	      }
	   }   
           if(qual == "B") {
              print ">" 
              for (i=0; i <= 4; i++) {
               printf("%9.3f %9.3f\n", r[i], s[i])
	      }
	   }   
           if(qual == "C") {
              print ">" 
              for (i=0; i <= 4; i++) {
               printf("%9.3f %9.3f\n", r[i], s[i])
	      }
	   }   
           if(qual == "D") {
              print ">"
              for (i=0; i <= 4; i++) {
               printf("%9.3f %9.3f\n", r[i], s[i])
	      }
	   }   
           if(qual == "E") {
              print ">"
              for (i=0; i <= 4; i++) {
               printf("%9.3f %9.3f\n", r[i], s[i])
	      }
	   }   
         
         } else {
         
           if(qual == "A") {
              print ">" >> temp"/semibox_A_SS"
              for (i=0; i <= 4; i++) {
               printf("%9.3f %9.3f\n", r[i], s[i]) >> temp"/semibox_A_SS"
	      }
	   }   
           if(qual == "B") {
              print ">" >> temp"/semibox_B_SS"
              for (i=0; i <= 4; i++) {
               printf("%9.3f %9.3f\n", r[i], s[i]) >> temp"/semibox_B_SS"
	      }
	   }   
           if(qual == "C") {
              print ">" >> temp"/semibox_C_SS"
              for (i=0; i <= 4; i++) {
               printf("%9.3f %9.3f\n", r[i], s[i]) >> temp"/semibox_C_SS"
	      }
	   }   
           if(qual == "D") {
              print ">" >> temp"/semibox_D_SS"
              for (i=0; i <= 4; i++) {
               printf("%9.3f %9.3f\n", r[i], s[i]) >> temp"/semibox_D_SS"
	      }
	   } 
           if(qual == "E") {
              print ">" >> temp"/semibox_E_SS"
              for (i=0; i <= 4; i++) {
               printf("%9.3f %9.3f\n", r[i], s[i]) >> temp"/semibox_E_SS"
	      }
	   } 
	 }    
     }  
  }

}
