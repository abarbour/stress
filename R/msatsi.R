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
#' \code{\link{print}},
#' \code{\link[R.matlab]{readMat}}, or
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
read.msatsi_mat <- function(fi, ...){
  #
  #Out.Damping: 1 (If damping is 'off', then = 0, if damping is 'on', then =1)
  #Out.DampingCoeff: 2.8 Final damping coefficient used after calculation.
  #Out.ConfidenceLevel: 95
  #Out.FractionValidFaultPlanes: 0.5000
  #Out.MinEventsNode: 20
  #Out.BootstrapResamplings: 2000
  #Out.Caption: '(example1)'
  #Out.TimeSpaceDampingRatio: 1
  #Out.PTPlot: 0
  #Out.SLBOOT_TENSOR: [54000x8 double] Information and structure equal to 'example1.slboot_tensor'
  #Out.SLBOOT_TRPL: [54000x9 double] Information and structure equal to 'example1.slboot_trpl'
  #Out.BOOTST_EXT: [51289x11 double] Information and structure equal to 'example1.summary_ext'
  #Out.INPUT_TABLE: [1890x5 double] Information and structure equal to 'example1.sat'
  #Out.SUMMARY_TABLE: [27x21 double] Information and structure equal to 'example1.summary'
  #Out.GRID: [[27x3 double] Contains the order of the grid-points in which the inversion results are sorted (for example, in .summary file). If SI is 0D/1D/2D, the columns are [X Y Nevents], where Nevents is the number of focal mechanisms included in each grid point. If SI is 3D/4D, the columns are: [X Y Z T Nevents].
  dat <- R.matlab::readMat(fi, ...)
  #   List of 1
  #   $ OUT:List of 17
  #   ..$ : int [1, 1] 1
  #   ..$ : num [1, 1] 2.2
  #   ..$ : num [1, 1] 95
  #   ..$ : num [1, 1] 0.5
  #   ..$ : num [1, 1] 20
  #   ..$ : num [1, 1] 750
  #   ..$ : chr [1, 1] " (2D_YZ3) "
  #   ..$ : num [1, 1] 1
  #   ..$ : int [1, 1] 0
  #   ..$ : num [1:6750, 1:8] 0 0 0 1 1 1 2 3 3 0 ...
  #   ..$ : num [1:6750, 1:9] 0 0 0 1 1 1 2 3 3 0 ...
  #   ..$ : num [1:6411, 1:11] 0 0 0 0 0 0 0 0 0 0 ...
  #   ..$ : num [1:1701, 1:5] 0 0 0 0 0 0 0 0 0 0 ...
  #   ..$ : num [1:9, 1:21] 0.63 0.66 0.81 0.72 0.8 0.86 0.82 0.94 0.88 0.5 ...
  #   ..$ : num [1:9, 1:3] 0 0 0 1 1 1 2 3 3 0 ...
  #   ..$ : num [1:12, 1:8] 0 0 0 1 1 1 2 2 2 3 ...
  #   ..$ : num [1:12, 1:9] 0 0 0 1 1 1 2 2 2 3 ...
  #   ..- attr(*, "dim")= int [1:3] 17 1 1
  #   ..- attr(*, "dimnames")=List of 3
  #   .. ..$ : chr [1:17] "Damping" "DampingCoeff" "ConfidenceLevel" "FractionValidFaultPlanes" ...
  #   .. ..$ : NULL
  #   .. ..$ : NULL
  #   - attr(*, "header")=List of 3
  #   ..$ description: chr "MATLAB 5.0 MAT-file, Platform: PCWIN64, Created on: Tue Jul 28 10:20:00 2015                                                "
  #   ..$ version    : chr "5"
  #   ..$ endian     : chr "little"
  out <- dat[['OUT']]
  class(out) <- c('msatsi_mat','array')
  return(out)
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
