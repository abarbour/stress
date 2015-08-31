#' @export
TP <- function(ang.trend, ang.plunge, r=NULL, add=FALSE, ...){
  #
  to_rad <- pi/180
  if (is.null(r)) r <- 90
  #
  XYc <- complex(argument = pi/2 - ang.trend*to_rad, modulus = r*cos(ang.plunge*to_rad))
  if (!add){
    circ <- r * stress::circle()
    re <- 1.06
    plot(circ*re, asp=1, type='l', col=NA, lwd=1.5,	axes=FALSE, xlab="", ylab="")
    lines(circ, col='grey', lwd=1.5)
    segments(c(-r,0), c(0,-r), c(r,0), c(0,r), col='grey', lty=3)
    points(0, 0, pch=3, col='grey', lwd=2)
    text(c(-r*re,0,r*re,0), c(0,-r*re,0,r*re), c('W','S','E','N'), col='grey50')
    #
  }
  points(XYc, cex=0.8, pch=16, ...)
}
