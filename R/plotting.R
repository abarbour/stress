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
#' @param pt.pch,pt.col,pt.cex numeric; the symbol type(s) of the points,
#' the color(s) of the points, and the \code{cex}(s) of the points
#' @param relpos numeric; a vector giving the relative shift to apply to the TP projection
#' @param dressing logical; include projection markings?
#' @param markers logical; should markings for the projection be included? (irrelevant if \code{!dressing})
#' @param ... additional arguments to \code{\link{points}}
#' @examples
#'
#' par(mar=rep(0,4), oma=rep(0.2,4))
#' TP(runif(20, min = 0, max = 90),c(45,55), xlim=c(-2,2), ylim=c(-2,2))
#' TP(runif(20, min = 180, max = 270),c(45,55), pt.pch=1, add=TRUE)
#' TP(runif(20, min = 180, max = 270),c(45,55), pt.col='red', add=TRUE, relpos=c(2,0.5), markers=FALSE)
#'
TP <- function(ang.trend, ang.plunge, r=NULL, add=FALSE, pt.pch=16, pt.col='black', pt.cex=0.8, relpos = c(0,0), dressing=TRUE, markers=TRUE, ...){
  #
  to_rad <- pi/180
  if (is.null(r)) r <- 1
  #
  trend <- pi/2 - ang.trend*to_rad
  plunge <- ang.plunge*to_rad
  #
  XYc <- complex(argument = trend, modulus = r * sqrt(2) * cos(pi/4 + plunge/2))
  relpos <- as.vector(relpos)
  rel.x <- relpos[1]
  rel.y <- ifelse(length(relpos) < 2, rel.x, relpos[2])
  shift <- complex(real = rel.x, imaginary = rel.y)
  circ <- r * stress::circle()
  re <- 1.06
  if (!add) plot(circ*re+c(rel.x, rel.y), asp=1, type='l', col=NA, lwd=1.5,	axes=FALSE, xlab="", ylab="", ...)
  if (dressing){
    lines(circ[,1]+rel.x, circ[,2]+rel.y, col='grey', lwd=1.5)
    segments(c(-r,0)+rel.x, c(0,-r)+rel.y, c(r,0)+rel.x, c(0,r)+rel.y, col='grey', lty=3)
    if (markers){
      points(rel.x, rel.y, pch=3, col='grey', lwd=2)
      text(c(-r*re,0,r*re,0)+rel.x, c(0,-r*re,0,r*re)+rel.y, c('W','S','E','N'), col='grey50')
    }
  }
  points(XYc+shift, cex=pt.cex, pch=pt.pch, col=pt.col)
}
