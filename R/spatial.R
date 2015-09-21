# Dat0 <- dat[,c('x','y','phi.best')]
# Rd <- rasterFromXYZ(Dat0)
# eDat0 <- dat[,c('x','y','phi.95','phi.05')]
# Rd.err <- rasterFromXYZ(transmute(mutate(eDat0, phi.stderr = ((phi.95 - phi.05)/2)/2), x, y, phi.stderr))
#
# All.r <- rasterVis::levelplot(stack(list(R=Rd, std.error=Rd.err)),
#                               main="Principal-Stress Ratio",
#                               par.settings=rasterTheme(region = brewer.pal(10, "PuOr")))

#' Convert objects to raster objects
#' @param x object
#' @param make.360 logical; should trends be in the range [0,360] rather than [-180,180]?
#' @param transpose logical; should the x and y coordinates be swapped?
#' @param ... additional parameters to \code{\link[raster]{rasterFromXYZ}}
#'
#' @return A \code{RasterBrick} object
#'
#' @export
#' @seealso \code{\link{read.msatsi_summary_ext}}, \code{\link[raster]{brick}}
#'
#' @references \url{https://cran.r-project.org/web/packages/raster/vignettes/Raster.pdf}
#'
#' @examples
#' require(raster)
#' require(viridis)
#'
#' # dummy example
#' n <- 20
#' .x <- seq_len(n)
#' .sc <- 5
#' .asp <- 1/.sc
#' .y <- .sc*.x
#' xy <- expand.grid(x=.x, y=.y)
#' .t <- seq_len(nrow(xy))
#' z <- cos(.t*pi/90 + pi/6)**2
#' D <- data.frame(X=xy$x, Y=xy$y, Z=z, T=0, TR1=10, TR2=20, TR3=40)
#' class(D) <- c("msatsi_summary_ext", 'data.frame')
#'
#' # Create the rasters (RasterBrick to be specific):
#' print(RB <- to_raster(D))
#'
#' # extract certain layers
#' r.z <- raster::raster(RB, 'Z')
#' all.equal(r.z, raster::raster(RB, layer=1))
#'
#' plot(r.z, col=viridis(n), zlim=c(0,1))
#'
to_raster <- function(x, ...) UseMethod('to_raster')

#' @rdname to_raster
#' @export
to_raster.msatsi_summary_ext <- function(x, make.360=TRUE, transpose=FALSE, no.zt=FALSE, ...){
  if (make.360){
    # use modulo division to restrict range
    dplyr::mutate(x, "TR1" = `TR1`%%360, "TR2" = `TR2`%%360, "TR3" = `TR3`%%360) -> x
  }
  if (transpose){
    # flip X and Y without clobbering (do not use mutate!)
    # while preserving order (do not use select/rename!)
    base::transform(x, "X"=`Y`, "Y"=`X`) -> x
  }
  if (no.zt){
    dplyr::select(x, -`Z`, -`T`) -> x
  }
  raster::rasterFromXYZ(x, ...)
}
