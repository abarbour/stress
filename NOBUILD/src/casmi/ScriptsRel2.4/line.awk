#
#   AWK script to create psxy input file for linear symbols.
#      lA lB lC lD and lE are defined externally
#
BEGIN{pi=4*atan2(1,1)
  if (keep != "yes") {
      printf("All A NF line \n") > temp"/line_A_NF"
      printf("All A TF line \n") > temp"/line_A_TF"
      printf("All A SS line \n") > temp"/line_A_SS"
      printf("All A U  line \n") > temp"/line_A_U"
      printf("All B NF line \n") > temp"/line_B_NF"
      printf("All B TF line \n") > temp"/line_B_TF"
      printf("All B SS line \n") > temp"/line_B_SS"
      printf("All B U  line \n") > temp"/line_B_U"
      printf("All C NF line \n") > temp"/line_C_NF"
      printf("All C TF line \n") > temp"/line_C_TF"
      printf("All C SS line \n") > temp"/line_C_SS"
      printf("All C U  line \n") > temp"/line_C_U"
      printf("All D NF line \n") > temp"/line_D_NF"
      printf("All D TF line \n") > temp"/line_D_TF"
      printf("All D SS line \n") > temp"/line_D_SS"
      printf("All D U  line \n") > temp"/line_D_U"
  }
}
{  x      = $1
   y      = $2
   azi    = pi*$3/180
   typ    = $7
   qual   = $8
   regime = $9
   cs     = cos(azi)
   sn     = sin(azi)
   if(qual=="A") len=lA
   if(qual=="B") len=lB
   if(qual=="C") len=lC
   if(qual=="D") len=lD
   if(qual=="E") len=lE
   a = len/2
   r=x+a*cs
   s=y+a*sn
   u=x-a*cs
   v=y-a*sn

   if(regime=="NF"||regime=="NS") {
      if (qual=="A") {
         printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_A_NF"
      } if (qual=="B") {
         printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_B_NF"
      } if (qual=="C") {
         printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_C_NF"
      } if (qual=="D") {
         printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_D_NF"
      } if (qual=="E") {
         printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_E_NF"
      }
   }   
   if(regime=="TF"||regime=="TS") {
      if (qual=="A") {
         printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_A_TF"
      } if (qual=="B") {
         printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_B_TF"
      } if (qual=="C") {
         printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_C_TF"
      } if (qual=="D") {
           printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_D_TF"
      } if (qual=="E") {
           printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_E_TF"
      }
   }
   if(regime=="SS") {
      if (qual=="A") {
         printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_A_SS"
      } if (qual=="B") {
         printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_B_SS"
      } if (qual=="C") {
         printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_C_SS"
      } if (qual=="D") {
         printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_D_SS"
      } if (qual=="E") {
         printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_E_SS"
      }
   }
   if(regime=="U") {
      if (qual=="A") {
         printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_A_U"
      } if (qual=="B") {
         printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_B_U"
      } if (qual=="C") {
         printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_C_U"
      } if (qual=="D") {
         printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_D_U"
      } if (qual=="E") {
         printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) >> temp"/line_E_U"
      }
   }
# For legend write to stdout:
   if(regime=="L") {
      printf("> \n %9.3f %9.3f\n %9.3f %9.3f\n", r, s, u, v) 
   }
}
