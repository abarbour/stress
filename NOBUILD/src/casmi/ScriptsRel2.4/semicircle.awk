#
#   AWK script to create psxy input file for filled semi circles.
#
BEGIN{
  pi=4*atan2(1,1)
  if (keep != "yes" ) {
      printf("SS semi-circle A Quality\n") > temp"/semicircle_A_SS"
      printf("SS semi-circle B Quality\n") > temp"/semicircle_B_SS"
      printf("SS semi-circle C Quality\n") > temp"/semicircle_C_SS"
      printf("SS semi-circle D Quality\n") > temp"/semicircle_D_SS"
      printf("SS semi-circle E Quality\n") > temp"/semicircle_E_SS"
     }
}     
{  x      = $1
   y      = $2
   azi    = $3
   fac    = pi/180
   typ    = $7
   qual   = $8
   regime = $9
   use    = $10

   if(qual=="A") len=sA
   if(qual=="B") len=sB
   if(qual=="C") len=sC
   if(qual=="D") len=sD
   if(qual=="E") len=sE
   a = len/2
   
 if(typ=="FMS"||typ=="FMA"||typ=="FMF") {

   if(regime=="SS") {

     if (use == "L")  {
       print ">" 
       for (i=0; i <= 180; i=i+12)  {  # make 12 deg steps to approximate circle
          ang = fac*(azi+i)
          cs = cos(ang)
          sn = sin(ang)
          r=x+a*cs
          s=y+a*sn
          printf("%9.3f %9.3f\n", r, s) 
       }
       ang = fac*azi
       cs = cos(ang)
       sn = sin(ang)
       r=x+a*cs
       s=y+a*sn
       printf("%9.3f %9.3f\n", r, s) 

     } else {

       if(qual == "A")  print ">" >> temp"/semicircle_A_SS"
       if(qual == "B")  print ">" >> temp"/semicircle_B_SS"
       if(qual == "C")  print ">" >> temp"/semicircle_C_SS"
       if(qual == "D")  print ">" >> temp"/semicircle_D_SS"
       if(qual == "E")  print ">" >> temp"/semicircle_E_SS"
      
       for (i=0; i <= 180; i=i+12)  {  # make 12 deg steps to approximate circle
          ang = fac*(azi+i)
          cs = cos(ang)
          sn = sin(ang)
          r=x+a*cs
          s=y+a*sn
          if(qual=="A") printf("%9.3f %9.3f\n", r, s) >> temp"/semicircle_A_SS" 
          if(qual=="B") printf("%9.3f %9.3f\n", r, s) >> temp"/semicircle_B_SS" 
          if(qual=="C") printf("%9.3f %9.3f\n", r, s) >> temp"/semicircle_C_SS" 
          if(qual=="D") printf("%9.3f %9.3f\n", r, s) >> temp"/semicircle_D_SS" 
          if(qual=="E") printf("%9.3f %9.3f\n", r, s) >> temp"/semicircle_E_SS" 
       }
       ang = fac*azi
       cs = cos(ang)
       sn = sin(ang)
       r=x+a*cs
       s=y+a*sn
       if(qual=="A") printf("%9.3f %9.3f\n", r, s) >> temp"/semicircle_A_SS" 
       if(qual=="B") printf("%9.3f %9.3f\n", r, s) >> temp"/semicircle_B_SS" 
       if(qual=="C") printf("%9.3f %9.3f\n", r, s) >> temp"/semicircle_C_SS" 
       if(qual=="D") printf("%9.3f %9.3f\n", r, s) >> temp"/semicircle_D_SS" 
       if(qual=="E") printf("%9.3f %9.3f\n", r, s) >> temp"/semicircle_E_SS" 
     }
   }
  }
}
