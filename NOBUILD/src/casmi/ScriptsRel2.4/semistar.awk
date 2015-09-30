#
#   AWK script to create psxy input file for semifilled star
#   (hydraulic fractures with SS-regime).
#
BEGIN{pi=4*atan2(1,1)
      sq3 = sqrt(3)
  if (keep != "yes" ) {
      printf("SS semi star Quality A \n") > temp"/semistar_A_SS"
      printf("SS semi star Quality B \n") > temp"/semistar_B_SS"
      printf("SS semi star Quality C \n") > temp"/semistar_C_SS"
      printf("SS semi star Quality D \n") > temp"/semistar_D_SS"
      printf("SS semi star Quality E \n") > temp"/semistar_E_SS"
  }
}  
{  x      = $1
   y      = $2
   azi    = $3
   typ    = $7
   qual   = $8
   regime = $9
   use    = $10

   if(typ=="HF"||typ=="HFG"||typ=="HFM"||typ=="HFP") {

       if(regime=="SS") {
       
         if (use == "L") {
           print ">"

           for (i=0; i<=6; i++) {
	      if (i==2*int(i/2)) {
	        b=sq3*a
	      } else {
	        b=a
              }
              
              ang=pi*(azi+i*30)/180
              cs = cos(ang)
              sn = sin(ang)
              r[i]=x+b*cs
              s[i]=y+b*sn
            
              printf("%9.3f %9.3f\n", r[i], s[i])           
           }
           
           printf("%9.3f %9.3f\n", r[0], s[0])
         
         
         } else {
          
           if(qual=="A") len=sA
           if(qual=="B") len=sB
           if(qual=="C") len=sC
           if(qual=="D") len=sD
           if(qual=="E") len=sE
           a = len*sq3/6 * 1.2  # changed from /4 to /6 vw.

           if(qual == "A")  print ">" >> temp"/semistar_A_SS"
           if(qual == "B")  print ">" >> temp"/semistar_B_SS"
           if(qual == "C")  print ">" >> temp"/semistar_C_SS"
           if(qual == "D")  print ">" >> temp"/semistar_D_SS"
           if(qual == "E")  print ">" >> temp"/semistar_E_SS"

           for (i=0; i<=6; i++) {
	      if (i==2*int(i/2)) {
	        b=sq3*a
	      } else {
	        b=a
              }
              
              ang=pi*(azi+i*30)/180
              cs = cos(ang)
              sn = sin(ang)
              r[i]=x+b*cs
              s[i]=y+b*sn
            
              if(qual=="A") printf("%9.3f %9.3f\n", r[i], s[i]) >> temp"/semistar_A_SS" 
              if(qual=="B") printf("%9.3f %9.3f\n", r[i], s[i]) >> temp"/semistar_B_SS" 
              if(qual=="C") printf("%9.3f %9.3f\n", r[i], s[i]) >> temp"/semistar_C_SS" 
              if(qual=="D") printf("%9.3f %9.3f\n", r[i], s[i]) >> temp"/semistar_D_SS" 
              if(qual=="E") printf("%9.3f %9.3f\n", r[i], s[i]) >> temp"/semistar_E_SS" 
           }
           
           if(qual=="A") printf("%9.3f %9.3f\n", r[0], s[0]) >> temp"/semistar_A_SS" 
           if(qual=="B") printf("%9.3f %9.3f\n", r[0], s[0]) >> temp"/semistar_B_SS" 
           if(qual=="C") printf("%9.3f %9.3f\n", r[0], s[0]) >> temp"/semistar_C_SS" 
           if(qual=="D") printf("%9.3f %9.3f\n", r[0], s[0]) >> temp"/semistar_D_SS" 
           if(qual=="E") printf("%9.3f %9.3f\n", r[0], s[0]) >> temp"/semistar_E_SS" 
         }   
       }
    }
}
