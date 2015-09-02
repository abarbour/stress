#' Stereonet representation of trend and plunge
#'
#' @description  Uses the equal-area (lower) hemispherical, or \emph{Schmidt}, projection.
#'  From [1]:  The main advantage of this projection
#'  method is that it does not suffer from the areal distortion of the equal angle
#'  projection. This means, for example, that an area such as that enclosed by a circle
#'  of constant radius on the projection, represents the same amount of area on the
#'  reference sphere regardless of its position. The circle will not however represent a
#'  geometrically similar circle on the sphere unless it is positioned at the centre of the
#'  projection. In other words, areal relationships are preserved in this method while
#'  geometrical relationships are distorted; the opposite is true of the equal angle
#'  projection.
#'
#' @details Uses \code{\link{complex}}, which recycles input vectors as needed
#'
#' @references
#' [1] Diederichs, Mark S (1990),
#' Dips: An Interactive and Graphical Approach to the Analysis of Orientation Based Data,
#' \url{https://www.rocscience.com/documents/pdfs/uploads/7672.pdf}
#'
#' @export
#' @param ang.trend numeric; trend or azimuth
#' @param ang.plunge numeric; plunch or dip
#' @param r numeric; the radius of the stereonet
#' @param add logical; should the points be added to the current device?
#' @param pch numeric; the symbol type of the points
#' @param ... additional arguments to \code{\link{points}}
#' @examples
#'
#' TP(runif(20, min = 0, max = 90),c(45,55))
#' TP(runif(20, min = 180, max = 270),c(45,55), pch=1, add=TRUE)
#'
TP <- function(ang.trend, ang.plunge, r=NULL, add=FALSE, pch=16, ...){
  #
  to_rad <- pi/180
  if (is.null(r)) r <- 1
  #
  trend <- pi/2 - ang.trend*to_rad
  plunge <- ang.plunge*to_rad
  #
  #x <- -1 * r * sin(trend) * tan(plunge/2)
  #y <- -1 * r * cos(trend) * tan(plunge/2)
  XYc <- complex(argument = trend, modulus = r * sqrt(2) * cos(pi/4 + plunge/2))
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
  points(XYc, cex=0.8, pch=pch, ...)
}
