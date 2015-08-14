#' Return a unit circle
#' @param dtheta numeric; the disretization in degrees.
#' @param origin numeric; where the first point begins, in degrees
#' @export
circle <- function (dtheta = 1, origin = 0) {
  thetas <- seq.int(from = origin, to = (origin+360), by = dtheta) * pi / 180
  return(cbind(x = cos(thetas), y = sin(thetas)))
}

#' Calculate dip direction from strike
#' @param strike.deg numeric; the strike of the nodal plane, in degrees
#' @export
dip_direction <- function(strike = 0){
  strike + 90
}

#' Stress ellipsoid, or shape factor
#' @param S1 numeric; the maximum principal stress
#' @param S2 numeric; the intermediate principal stress
#' @param S3 numeric; the minimum principal stress
#' @export
stress_ellipsoid <- function(S1, S2, S3){
  S <- sort(c(S1,S2,S3))
  (S[2] - S[3])/(S[1] - S[3])
}
