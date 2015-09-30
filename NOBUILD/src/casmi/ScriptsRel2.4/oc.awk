#
#   AWK script to create psxy input file for over-coring methods
#
BEGIN{pi=4*atan2(1,1)
  if (keep != "yes") {
      printf("NF A oc \n") > temp"/oc_A_NF"
      printf("TF A oc \n") > temp"/oc_A_TF"
      printf("SS A oc \n") > temp"/oc_A_SS"
      printf("U  A oc \n") > temp"/oc_A_U"
      printf("NF B oc \n") > temp"/oc_B_NF"
      printf("TF B oc \n") > temp"/oc_B_TF"
      printf("SS B oc \n") > temp"/oc_B_SS"
      printf("U  B oc \n") > temp"/oc_B_U"
      printf("NF C oc \n") > temp"/oc_C_NF"
      printf("TF C oc \n") > temp"/oc_C_TF"
      printf("SS C oc \n") > temp"/oc_C_SS"
      printf("U  C oc \n") > temp"/oc_C_U"
      printf("NF D oc \n") > temp"/oc_D_NF"
      printf("TF D oc \n") > temp"/oc_D_TF"
      printf("SS D oc \n") > temp"/oc_D_SS"
      printf("U  D oc \n") > temp"/oc_D_U"
      printf("NF E oc \n") > temp"/oc_E_NF"
      printf("TF E oc \n") > temp"/oc_E_TF"
      printf("SS E oc \n") > temp"/oc_E_SS"
      printf("U  E oc \n") > temp"/oc_E_U"
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

   csa     = cos(pi/180*(azi+90))
   sna     = sin(pi/180*(azi+90))

   csl     = cos(pi/180*azi)
   snl     = sin(pi/180*azi)

 #if(qual!="E") {
   if (typ=="OC") {
       if(qual=="A") { 
         len=lA
         fileout = temp"/oc_A_"
       }
       if(qual=="B") { 
         len=lB
         fileout = temp"/oc_B_"
       }
       if(qual=="C") { 
         len=lC
         fileout = temp"/oc_C_"
       }
       if(qual=="D"){ 
         len=lD
         fileout = temp"/oc_D_"
       } 
       if(qual=="E"){ 
         len=lE
         fileout = temp"/oc_E_"
       } 
       a = len/10
       l = len/2
       
       r=x+a*csa
       s=y+a*sna
       t=x-a*csa
       u=y-a*sna
       
       v1=x+l*csl
       w1=y+l*snl
       v2=x-l*csl
       w2=y-l*snl
       
       
       
       if (use == "L") {
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r, s, t, u)
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", v1, w1, v2, w2)
       } else {
        
         if(regime=="NF"||regime=="NS") {
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r, s, t, u) >> fileout"NF"
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", v1, w1, v2, w2) >> fileout"NF"
         } else if(regime=="TF"||regime=="TS") {
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r, s, t, u) >> fileout"TF"
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", v1, w1, v2, w2) >> fileout"TF"
         } else if(regime=="SS") {
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r, s, t, u) >> fileout"SS"
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", v1, w1, v2, w2) >> fileout"SS"
         } else if(regime=="U")  {
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", r, s, t, u) >> fileout"U"
               printf(">\n%9.3f %9.3f\n%9.3f %9.3f\n", v1, w1, v2, w2) >> fileout"U"
         }

       }
   }
        
 #}
}
