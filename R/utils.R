#' Return a unit circle
#' @param dtheta numeric; the disretization in degrees.
#' @param origin numeric; where the first point begins, in degrees
#' @param n numeric; an optional way to specify the number of points from
#' the origin to the origin + 360; setting this negates \code{dtheta}
#' @param delx,dely numeric; the amount to shift the origin in plotting space
#' @export
circle <- function (dtheta = 1, origin = 0, n, delx=0, dely=0) {
  end <- origin + 360
  thetas <- if (missing(n)){
    seq.int(from = origin, to = end, by = dtheta)
  } else {
    seq.int(from = origin, to = end, length.out = n)
  }
  thetas <- thetas * pi / 180
  return(cbind(x = cos(thetas) + delx, y = sin(thetas) + dely))
}

#' Calculate dip direction from strike
#' @param strike.deg numeric; the strike of the nodal plane, in degrees
#' @export
dip_direction <- function(strike = 0){
  strike + 90
}

#' Principal stress ratio
#' @inheritParams shape_factor
#' @param ... additional parameters to \code{\link{shape_factor}}
#' @seealso \code{\link{shape_factor}}
#' @export
stress_ratio <- function(S1, S2, S3, ...){
  shape_factor(S1, S2, S3, stress.ratio = TRUE, ...)
}

#' Stress ellipsoid, or 'shape factor'
#' @details
#' If \code{S1} > \code{S2} > \code{S3} then:
#' \deqn{
#'  \phi = \frac{S2 - S3}{S1 - S3}
#' }
#' which is the parameter returned by SATSI, for example.
#'
#' Note that the \code{\link{stress_ratio}} is:
#' \deqn{
#'  R = 1 - \phi = \frac{S1 - S2}{S1 - S3}
#' }
#'
#' @param S1 numeric; the maximum principal stress
#' @param S2 numeric; the intermediate principal stress
#' @param S3 numeric; the minimum principal stress
#' @param check.order logical; should the order of the stress be checked?
#' If the check fails the indices which caused it to fail will be returned.
#' Set this to \code{FALSE} if you want to reduce computation time and
#' are confident in the order of \code{S1}, \code{S2}, and \code{S3}.
#' @param stress.ratio logical; should the \code{\link{stress_ratio}}
#' be returned instead?
#' @export
shape_factor <- function(S1, S2, S3, check.order=TRUE, stress.ratio=FALSE){
  S <- cbind(as.vector(S1), as.vector(S2), as.vector(S3))
  if (check.order){
    if (any(is.na(S))) stop('cannot include NA values')
    ok <- apply(S, 1, function(x){x[1] >= x[2] & x[2] >= x[3]})
    if (any(!ok)){
      warning('stresses are not all sorted properly. this assumes  S1 > S2 > S3  always. returning bad indices.')
      return(which(!ok))
    }
  }
  phi <- (S[, 2] - S[, 3]) / (S[, 1] - S[, 3])
  if (stress.ratio){
    1 - phi
  } else {
    phi
  }
}

#' Differential stress from b-values based on Scholz's regression
#'
#' @details
#' Differential stress (S1 - S3) may be inversely proportional to b-value Scholz (2015).
#'
#' @export
#' @param b numeric; earthquakes b-value
#' @examples
#' bvalue_stress() # 1.0 characteristic of So CA: 192 MPa
#' bvalue_stress(c(0.85,0.90,1.0))
bvalue_stress <- function(b=1.0){
  ds <- (1.23 - b) / 0.0012
  attr(ds, 'units') <- 'MPa'
  return(ds)
}
