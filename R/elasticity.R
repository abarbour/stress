#' @title Young's modulus and elastic constants
#'
#' @param kap numeric; the elastic bulk modulus
#' @param mu numeric; the elastic shear modulus
#' @param nu numeric; the Poisson's ratio
#'
#' @name youngs-mod
#' @seealso \code{\link{elastic_compliance_tensor}}
#' 
#' @references \url{https://en.wikipedia.org/wiki/Elastic_modulus} for various inter-relationships
#' 
#' @examples
#' 
#' # Calculate Young's modulus from
#' 
#' # shear modulus
#' sm <- 30e9
#' ym.s <- shear_to_youngs(sm)
#' 
#' # bulk modulus
#' bm <- shear_to_bulk(sm)
#' ym.b <- bulk_to_youngs(bm)
#' 
#' all.equal(ym.s, ym.b)
#' 
#' smi <- bulk_to_shear(bm)
#' all.equal(sm, smi)
#' 

#' @rdname youngs-mod
#' @export
shear_to_youngs <- function(mu, nu=0.25){
  # Shear modulus to Youngs modulus, for a given Poisson's ratio
  # see https://en.wikipedia.org/wiki/Young%27s_modulus
  2 * mu * (1 + nu)
}

#' @rdname youngs-mod
#' @export
shear_to_lambda <- function(mu, nu=0.25){
  # Shear modulus to Lame first constant, for a given Poisson's ratio
  # see {}
  .NotYetImplemented()
}

#' @rdname youngs-mod
#' @export
bulk_to_youngs <- function(kap, nu=0.25){
  # Bulk modulus to Youngs modulus, for a given Poisson's ratio
  # see 
  3 * kap * (1 - 2 * nu)
}

#' @rdname youngs-mod
#' @export
shear_to_bulk <- function(mu, nu=0.25){
  shear_to_youngs(mu, nu) / bulk_to_youngs(1, nu)
}

#' @rdname youngs-mod
#' @export
bulk_to_shear <- function(kap, nu=0.25){
  bulk_to_youngs(kap, nu) / shear_to_youngs(1, nu)
}

#' Calculate elastic properties from a velocity model
#'
#' @param vp numeric; the P-wave speed [m/s]
#' @param vs numeric; the S-wave speed [m/s]
#' @param rho numeric; the density [kg/m^3]
#' @param ... additional parameters (e.g., passing \code{nu})
#'
#' @return bulk modulus, shear modulus, Lame's first constant;
#' in Pa if SI given for inputs
#' @export
#'
#' @examples
#' # inputs in m/s and kg/m^3 give results in Pascal
#' Pa <- seismic_elasticity(7200, 3500, 2650)
#' 
#' # use km/s and g/cm^3 instead to get giga-Pascal
#' GPa <- seismic_elasticity(7.2, 3.5, 2.65)
#' all.equal(Pa/1e9, GPa)
seismic_elasticity <- function(vp, vs, rho){
  vsq <- vs^2
  vpq <- vp^2
  # Shear modulus (Lame's second constant)
  mu <- rho * vsq
  # Bulk modulus
  kap <- rho * (vpq - 4 * vsq / 3)
  # Lame's first constant
  lam <- (3 * kap - 2 * mu) / 3
  lam2 <- rho * (vpq - 2 * vsq)
  stopifnot(all.equal(lam, lam2))
  # Poisson's ratio
  L <- lam / rho
  nu <- L/(L + 2 * vp) # [ ] check this -- seems wrong
  c(nu = nu, lambda = lam, mu = mu, kappa = kap)
}

#' Calculate the isotropic elasticity tensor using Hooke's law of elasticity
#' @details 
#' Hooke's law is relating stress \eqn{\sigma} to strain \eqn{\epsilon} is
#' \deqn{\sigma = \strong{C} \epsilon}
#' or 
#' \deqn{\sigma = 2 \mu \epsilon + \lambda \strong{I} \diag(\epsilon)}
#' where \eqn{\lambda,\mu} are Lame's first and second constants of elasticity.
#' 
#' This function calculates \eqn{C} for 3D elasticity -- a 6x6 tensor with three independent quantities.
#' 
#' @inheritParams youngs-mod
#' @param Youngs numeric; Young's modulus
#'
#' @return A symmetric matrix of elastic constants
#' @export
#' @seealso \code{\link{youngs-mod}}
#' @examples
#' elastic_compliance_tensor()
#' 
elastic_compliance_tensor <- function(nu=0.25, Youngs=75e9){
  # Hooke's law
  # sigma = C epsilon
  # or 
  # sigma = 2 mu epsilon + lambda I diag(epsilon)
  #
  # http://www.colorado.edu/engineering/cas/courses.d/IFEM.d/IFEM.Ch14.d/IFEM.Ch14.pdf
  # http://www.brown.edu/Departments/Engineering/Courses/En221/Notes/Polar_Coords/Polar_Coords.htm
  # sec 2.6
  c11 <- c22 <- c33 <- 1 - nu
  c44 <- c55 <- c66 <- (1 - 2*nu) / 2
  c12 <- c13 <- c23 <- nu
  C <- matrix(c(c11, c12, c13,   0,   0,   0,  
                c12, c22, c23,   0,   0,   0,  
                c13, c23, c33,   0,   0,   0,
                0,   0,   0, c44,   0,   0,
                0,   0,   0,   0, c55,   0,
                0,   0,   0,   0,   0, c66), nrow=6, byrow=TRUE)
  # Final compliance tensor
  # based on Lame's first constant
  l1 <- Youngs / (1 + nu) / (1 - 2*nu)
  l1 * C
}