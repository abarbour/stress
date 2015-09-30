# add a line with a seperater every addline-th line.
BEGIN{
  line = 0
  origlat = latinc
}
{
  line++
  if (line%addline == 0) {
     origlat=origlat+latinc
     print $0
     print ">  " origlat
  } else {
     print $0
  }
}
