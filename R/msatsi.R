#' MSATSI output readers
#'
#' MSATSI has a standardized set of output files.  These functions
#' can be used to read-in certain files and create associated
#' objects.
#'
#' @name read_msatsi
NULL

#' @rdname read_msatsi
#' @param fi character; the filename
#' @param x object
#' @param ... additional parameters, usually passed to
#' \code{\link{read.table}} or
#' \code{\link{print}}
#' @export
read.slboot_trpl <- function(fi, ...){
  # 0D-2D: X Y Phi Tr1 Pl1 Tr2 Pl2 Tr3 Pl3
  # 3D-4D: X Y Z T Phi Tr1 Pl1 Tr2 Pl2 Tr3 Pl3
  dat <- read.table(fi, header=TRUE, ...)
  class(dat) <- c('slboot_trpl','data.frame')
  attr(dat, 'is.3D') <- ncol(dat) > 9
  return(dat)
}

#' @rdname read_msatsi
#' @export
print.slboot_trpl <- function(x, ...){
  message("slboot trpl output:\n3D/4D: ", attr(x, 'is.3D'))
  print(dplyr::tbl_df(x), ...)
}

#' @rdname read_msatsi
#' @export
read.slboot_tensor <- function(fi, ...){
  # 0D-2D: X Y See Sen Seu Snn Snu Suu
  # 3D-4D: X Y Z T See Sen Seu Snn Snu Suu
  dat <- read.table(fi, header=TRUE, ...)
  class(dat) <- c('slboot_tensor','data.frame')
  attr(dat, 'is.3D') <- ncol(dat) > 8
  return(dat)
}

#' @rdname read_msatsi
#' @export
print.slboot_tensor <- function(x, ...){
  message("slboot tensor output:\n3D/4D: ", attr(x, 'is.3D'))
  print(dplyr::tbl_df(x), ...)
}

.deviatoric_tensor <- function(s, ...) {
  #See       Sen       Seu       Snn       Snu       Suu
  s <- as.vector(s)
  #       e     n     u
  e <- c(s[1], s[2], s[3]) # e
  n <- c(s[2], s[4], s[5]) # n
  u <- c(s[3], s[5], s[6]) # u
  D <- rbind(e,n,u)
}

#' Return the relative stress magnitudes and directions
#' @export
#' @seealso \code{\link{read_msatsi}}
relative_stress <- function(x, ...) UseMethod('relative_stress')

#' @rdname relative_stress
#' @export
relative_stress.slboot_tensor <- function(x, ...){
  .local <- function(s, ...){
    eigS <- eigen(.deviatoric_tensor(s, ...), symmetric=TRUE)
    c(eigS[['values']], as.vector(eigS[['vectors']]))
  }
  XY <- dplyr::select(x, -starts_with('S'))
  s_ <- dplyr::select(x, starts_with('S'))
  t(apply(X=s_, MARGIN = 1, FUN = .local)) %>% as.data.frame %>% dplyr::tbl_df -> S
  cbind(XY, S)
}
