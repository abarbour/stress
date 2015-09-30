#
#   AWK script to calculate circle, used as clippath for globe view with topo
#
BEGIN{
   pi=4*atan2(1,1)
      
   # lon of center:               x=siz/2
   # lat of center:               y=siz/2     
   # size of circle in inches:  siz    

   radius = siz/2  
   x = siz/2
   y = siz/2
   
   # generate circle
   for (i=0; i<=180; i++)  {

        ang=pi/180*(i*2)
        cs = cos(ang)
        sn = sin(ang)
        r[i]=x+radius*cs
        s[i]=y+radius*sn
        printf("%9.3f %9.3f\n", r[i], s[i]) 
   }
}
