#' Calculation of the direction of maximum horizontal stress using a 3D relative stress tensor
#' @export
#' @author Copyright (C) 1998-2007 Bjorn Lund
#' @param n1 numeric; the unit vector of the maximum principal stress, S1 (North,East,Up); if
#' either \code{n2} or \code{n3} are \code{NULL} then this may be a three-column matrix
#' @param n2 numeric; unit vector of the intermediate principal stress, S2
#' @param n3 numeric; unit vector of the minimum principal stress, S3
#' @param R numeric; the principal stress ratio; defined as (S1 - S2)/(S1 - S3)
#' @references Equations 10 and 11 from Lund and Townend, (2007): Calculating horizontal stress orientations
#' @return numeric; the azimuth of SHmax (c.w. from North) in radians
#' with full or partial knowledge of the tectonic stress tensor,
#' Geophys. J. Int., 170, 1328-1335, doi: 10.1111/j.1365-246X.2007.03468.x
#' @examples
#' # Dummy examples
#' Sf <- matrix(1:9, 3)
#' Sf[lower.tri(Sf)] = t(Sf)[lower.tri(Sf)]
#'
#' S <- eigen(Sf)
#' principal_stresses <- S[['values']]
#' orientations <- S[['vectors']]
#'
#' SH(0.5, orientations[,1], orientations[,2], orientations[,3])
#' SH(0.5, orientations)
#'
#' Rseq <- seq(0, 1, length.out=21)
#' Azims <- sapply(Rseq, SH, n1=orientations)
#' plot(Rseq, Azims*180/pi, type='b')
#'
SH <- function(R, n1, n2=NULL, n3=NULL){
  #
  if (is.null(n2) | is.null(n3)){
    N <- as.matrix(n1)
    stopifnot(ncol(N)==3)
    n1 <- N[,1]
    n2 <- N[,2]
    n3 <- N[,3]
  }

  EPS <- .Machine$double.neg.eps

  n1prod <- n1[1]*n1[2]
  n2prod <- n2[1]*n2[2]

  # Calculate the direction of maximum horizontal stress using Eq. 11 in
  # Lund and Townend (2007)
  Y <- 2 * (n1prod + (1 - R)*n2prod)
  X <- n1[1]^2 - n1[2]^2 + (1 - R)*(n2[1]^2 - n2[2]^2)

  # Is the denominator (X here) from Eq. 11 in Lund and Townend (2007) zero?
  alpha <- if (abs(X) < EPS){
    # If so, the first term in Eq. 10 is zero and we are left with the
    # second term, which must equal zero for a stationary point.
    # The second term is zero either if
    # s1Ns1E + (1-R)*s2Ns2E = 0   (A)
    # or if
    # cos(2*alpha) = 0            (B)
    # If (A) holds, the direction of SH is undefined since Eq. 10 is zero
    # irrespective of the value of alpha. We therefore check for (A) first.
    # If (A) holds, R = 1 + s1Ns1E/s2Ns2E unless s2Ns2E = 0, in which case
    # s1Ns1E also has to be zero for (A) to hold.
    #
    if (abs(n2prod) < EPS){
      # s2Ns2E = 0
      if (abs(n1prod) < EPS){
        NA
      } else {
        pi / 4
      }
    } else {
      if (abs(R - (1 + n1prod/n2prod)) < EPS){
        NA
      } else {
        pi / 4
      }
    }
  # The denominator is non-zero
  } else {
    atan(Y/X) / 2
  }

  # Have we found a minimum or maximum? Use 2nd derivative to find out.
  # A negative 2nd derivative indicates a maximum, which is what we want.
  dev2 <- -2*(X*cos(2*alpha) + Y*sin(2*alpha))
  if (dev2 > 0){
    # We found a minimum. Add 90 degrees to get the maximum.
    alpha <- alpha + pi/2
  }

  # The resulting direction of SH is given as [0,180] degrees.
  if (alpha < 0){
    alpha <- alpha + pi
  }

  #if alpha > pi or abs(alpha - pi) < EPS
  if ((alpha > pi) | (abs(alpha - pi) < EPS)){
    alpha <- alpha - pi
  }

  return(alpha)
}

