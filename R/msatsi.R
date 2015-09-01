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
#' @param x,object an object
#' @param ... additional parameters, usually passed to
#' \code{\link{read.table}},
#' \code{\link{print}}, or
#' \code{\link{plot}}
#' @export
read.msatsi_slboot_trpl <- function(fi, ...){
  # 0D-2D: X Y Phi Tr1 Pl1 Tr2 Pl2 Tr3 Pl3
  # 3D-4D: X Y Z T Phi Tr1 Pl1 Tr2 Pl2 Tr3 Pl3
  dat <- read.table(fi, header=TRUE, ...)
  class(dat) <- c('msatsi_slboot_trpl','data.frame')
  attr(dat, 'is.3D') <- ncol(dat) > 9
  return(dat)
}

#' @rdname read_msatsi
#' @export
print.msatsi_slboot_trpl <- function(x, ...){
  message("msatsi slboot trpl output:\n3D/4D: ", attr(x, 'is.3D'))
  print(dplyr::tbl_df(x), ...)
}

#' @rdname read_msatsi
#' @export
read.msatsi_slboot_tensor <- function(fi, ...){
  # 0D-2D: X Y See Sen Seu Snn Snu Suu
  # 3D-4D: X Y Z T See Sen Seu Snn Snu Suu
  dat <- read.table(fi, header=TRUE, ...)
  class(dat) <- c('msatsi_slboot_tensor','data.frame')
  attr(dat, 'is.3D') <- ncol(dat) > 8
  return(dat)
}

#' @rdname read_msatsi
#' @export
print.msatsi_slboot_tensor <- function(x, ...){
  message("msatsi slboot tensor output:\n3D/4D: ", attr(x, 'is.3D'))
  print(dplyr::tbl_df(x), ...)
}

#' @rdname read_msatsi
#' @export
read.msatsi_summary <- function(fi, ...){
  # PhiBest PhiMin PhiMax
  # Tr1Best Tr1Min Tr1Max
  # Pl1Best Pl1Min Pl1Max
  # Tr2Best Tr2Min Tr2Max
  # Pl2Best Pl2Min Pl2Max
  # Tr3Best Tr3Min Tr3Max
  # Pl3Best Pl3Min Pl3Max
  dat <- read.table(fi, header=TRUE, ...)
  class(dat) <- c('msatsi_summary','data.frame')
  attr(dat, 'is.3D') <- NA
  return(dat)
}

#' @rdname read_msatsi
#' @export
print.msatsi_summary <- function(x, ...){
  message("msatsi summary output:")
  print(dplyr::tbl_df(x), ...)
}

#' @rdname read_msatsi
#' @export
read.msatsi_summary_ext <- function(fi, ...){
  # X Y Z T PHI TR1 PL1 TR2 PL2 TR3 PL3
  dat <- read.table(fi, header=TRUE, ...)
  class(dat) <- c('msatsi_summary_ext','data.frame')
  attr(dat, 'is.3D') <- NA
  return(dat)
}

#' @rdname read_msatsi
#' @export
print.msatsi_summary_ext <- function(x, ...){
  message("msatsi summary (ext) output:")
  print(dplyr::tbl_df(x), ...)
}

## Input file

#' @rdname read_msatsi
#' @export
read.msatsi_sat <- function(fi, ...){
  # 0D-2D: X Y DIP_DIR DIP_ANGLE RAKE
  # 3D-4D: X Y Z T DIP_DIR DIP_ANGLE RAKE
  dat <- read.table(fi, header=FALSE, ...)
  nc <- ncol(dat)
  three.d <- if (nc == 5){
    names(dat) <- c('X','Y','Dipdir','Dip','Rake')
    FALSE
  } else if (nc == 7){
    names(dat) <- c('X','Y','Z','T','Dipdir','Dip','Rake')
    TRUE
  } else {
    stop('invalid .sat file')
  }
  class(dat) <- c('msatsi_input','data.frame')
  attr(dat, 'is.3D') <- three.d
  return(dat)
}

#' @rdname read_msatsi
#' @export
print.msatsi_input <- function(x, ...){
  message("msatsi input file:\n3D/4D: ", attr(x, 'is.3D'))
  print(dplyr::tbl_df(x), ...)
}

#' @rdname read_msatsi
#' @export
summary.msatsi_input <- function(object, ...){
  three.d <- attr(object, 'is.3D')
  summ <- list(
       sat_name = deparse(substitute(object)),
       is.3D = three.d,
       X.t = table(object$X),
       Y.t = table(object$Y),
       XY.t = table(object$X, object$Y),
       Z.t = if (three.d){ table(object$Z) } else { NA },
       T.t = if (three.d){ table(object$`T`) } else { NA },
       ZT.t = if (three.d){ table(object$Z, object$`T`) } else { NA }
  )
  class(summ) <- c('msatsi_input.summary','list')
  return(summ)
}

#' @rdname read_msatsi
#' @export
print.msatsi_input.summary <- function(x, ...){
  message("msatsi input summary:\n3D/4D: ", x[['is.3D']])
  print(x[['XY.t']], ...)
}

#' @rdname read_msatsi
#' @export
plot.msatsi_input.summary <- function(x, ...){
  three.d <- x[['is.3D']]
  sat_name <- x[['sat_name']]
  names <- names(x)
  ret <- lapply(names, function(ni, lbl = sat_name, ...){
    ti <- x[[ni]]
    if (inherits(ti, 'table')){
      plot(ti, main=ni, ...)
      mtext(lbl)
    }
  }, ...)
}

## Various utilities

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
