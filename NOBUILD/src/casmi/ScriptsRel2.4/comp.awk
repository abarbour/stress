# small comperator. returns true if expression a op b is true.

{ 
a = $1
b = $3
op = $2

if (op == ">" ) {
  if (a > b)
    { print "true"}
  else 
    { print "false"}
} else if (op == "<" ) {
  if (a < b) 
    { print "true" }
  else 
    { print "false"}
} else if (op == "absequ" ) {
  if (a == b || ((-1)*a) == b) 
    { print "true" }
  else 
    { print "false"}
} else if (op == "absless" ) {
  if (a == b || ((-1)*a) == b) 
    { print "true" }
  else 
    { print "false"}
} else if (op == "stringequal" ) {
  if (a == b) 
    { print "true" }
  else 
    { print "false"}
}
}
