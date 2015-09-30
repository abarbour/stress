#
#   AWK script to create psxy input file for over-coring methods
#
BEGIN{pi=4*atan2(1,1)
  if (keep != "yes") {
      printf("NF A bs \n") > temp"/bs_A_NF"
      printf("TF A bs \n") > temp"/bs_A_TF"
      printf("SS A bs \n") > temp"/bs_A_SS"
      printf("U  A bs \n") > temp"/bs_A_U"
      printf("NF B bs \n") > temp"/bs_B_NF"
      printf("TF B bs \n") > temp"/bs_B_TF"
      printf("SS B bs \n") > temp"/bs_B_SS"
      printf("U  B bs \n") > temp"/bs_B_U"
      printf("NF C bs \n") > temp"/bs_C_NF"
      printf("TF C bs \n") > temp"/bs_C_TF"
      printf("SS C bs \n") > temp"/bs_C_SS"
      printf("U  C bs \n") > temp"/bs_C_U"
      printf("NF D bs \n") > temp"/bs_D_NF"
      printf("TF D bs \n") > temp"/bs_D_TF"
      printf("SS D bs \n") > temp"/bs_D_SS"
      printf("U  D bs \n") > temp"/bs_D_U"
      printf("NF E bs \n") > temp"/bs_E_NF"
      printf("TF E bs \n") > temp"/bs_E_TF"
      printf("SS E bs \n") > temp"/bs_E_SS"
      printf("U  E bs \n") > temp"/bs_E_U"
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

   csa1     = cos(pi/180*(azi-40))
   sna1     = sin(pi/180*(azi-40))

   csa2     = cos(pi/180*(azi+40))
   sna2     = sin(pi/180*(azi+40))

   csa3     = cos(pi/180*(azi+90))
   sna3     = sin(pi/180*(azi+90))
   
   csl     = cos(pi/180*azi)
   snl     = sin(pi/180*azi)

 #if(qual!="E") {
   if (typ=="BS") {
       if(qual=="A") { 
         len=lA
         fileout = temp"/bs_A_"
       }
       if(qual=="B") { 
         len=lB
         fileout = temp"/bs_B_"
       }
       if(qual=="C") { 
         len=lC
         fileout = temp"/bs_C_"
       }
       if(qual=="D"){ 
         len=lD
         fileout = temp"/bs_D_"
       } 
       if(qual=="E"){ 
         len=lE
         fileout = temp"/bs_E_"
       } 
       a = len/10
       l = len/2
       
       r1=x+a*csa1
       s1=y+a*sna1
       t1=x-a*csa1
       u1=y-a*sna1

       r2=x+a*csa2
       s2=y+a*sna2
       t2=x-a*csa2
       u2=y-a*sna2
       
       r3=x+a*csa3
       s3=y+a*sna3
       t3=x-a*csa3
       u3=y-a*sna3
       
       v1=x+l*csl
       w1=y+l*snl
       v2=x-l*csl
       w2=y-l*snl
       
       
       
       if (use == "L") {
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r1, s1, t1, u1)               
	       printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r2, s2, t2, u2)
	       printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r3, s3, t3, u3)
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", v1, w1, v2, w2)
       } else {
        
         if(regime=="NF"||regime=="NS") {
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r1, s1, t1, u1) >> fileout"NF"
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r2, s2, t2, u2) >> fileout"NF"
	       printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r3, s3, t3, u3) >> fileout"NF"
	       printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", v1, w1, v2, w2) >> fileout"NF"
         } else if(regime=="TF"||regime=="TS") {
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r1, s1, t1, u1) >> fileout"TF"
	       printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r2, s2, t2, u2) >> fileout"TF"
	       printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r3, s3, t3, u3) >> fileout"TF"
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", v1, w1, v2, w2) >> fileout"TF"
         } else if(regime=="SS") {
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r1, s1, t1, u1) >> fileout"SS"
	       printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r2, s2, t2, u2) >> fileout"SS"
	       printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r3, s3, t3, u3) >> fileout"SS"
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", v1, w1, v2, w2) >> fileout"SS"
         } else if(regime=="U")  {
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r1, s1, t1, u1) >> fileout"U"
	       printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r2, s2, t2, u2) >> fileout"U"
	       printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r3, s3, t3, u3) >> fileout"U"
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", v1, w1, v2, w2) >> fileout"U"
         }

       }
   }
        
 #}
}
