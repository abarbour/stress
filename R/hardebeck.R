#' Rotations in S1
#'
#' This calculates the
#' change in orientation of the maximum principal stress relative to
#' the fault prior to the earthquake (theta)
#' for a given stress drop (dTau) relative to pre-mainshock levels (Tau).
#'
#' @references Hardebeck and Hauksson (2001): \url{https://doi.org/10.1029/2001JB000292}
#' @export
#'
#' @param theta.deg numeric;
#' @param dTau numeric;
#' @param Tau numeric;
#'
#' @examples
#' thet.=seq(-90,90,by=2)
#' rats <- seq(-1,1,by=0.2)
#' All.dthet <- plyr::ldply(rats, function(r) dTheta(thet., dTau=r))
#' matplot(x=thet., t(All.dthet), type='l', col=c(5:1,NA,1:5), lty=c(1:5,1,5:1))
dTheta <- function(theta.deg=30, dTau=1, Tau=1){
  #
  # The change in orientation of S1 relative to
  # the fault prior to the earthquake (theta)
  # for a given stress drop relative to pre-mainshock
  # levels
  #
  theta.rad <- theta.deg * pi/180
  twotheta <- theta.rad * 2
  Rat <- dTau/Tau
  y <- 1 - Rat*sin(twotheta) - sqrt(Rat^2 + 1 - 2*Rat*sin(twotheta))
  x <- Rat * cos(twotheta)
  #atan2(y, x) == atan(y/x)
  atan(y/x) * 180/pi
}
