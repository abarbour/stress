#
# read in pairs of points and compute azimuth of
#   second point relative to first point
#   Note: atan2 returns angle relative to horizontal axis (= x-axis)!
# return coordinates of second point and azimuth
#
BEGIN{pi=4*atan2(1,1)}
{
    x2 = $1
    y2 = $2 
    x1 = $3
    y1 = $4
    dx = x2-x1
    dy = y2-y1
    azi = 180*atan2(dy,dx)/pi
    printf("%9.3f %9.3f %8.1f\n",x1,y1,azi) 
}
