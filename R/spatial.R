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
#' @param ... additional parameters to
#' \code{\link[raster]{rasterFromXYZ}}
#' @param make.360 logical; should trends be in the range [0,360] rather than [-180,180]?
#' @param transpose logical; should the x and y coordinates be swapped?
#' @export
to_raster <- function(x, ...) UseMethod('to_raster')

#' @rdname to_raster
#' @export
to_raster.msatsi_summary_ext <- function(x, transpose=FALSE, make.360=TRUE, ...){
  if (make.360) x %>% dplyr::mutate(TR1 = `TR1`%%360, TR2 = `TR2`%%360, TR3 = `TR3`%%360) -> x
  if (transpose) x %>% dplyr::mutate(tmp=`X`, X=`Y`, Y=`tmp`) %>% dplyr::select(., -`tmp`) -> x
  raster::rasterFromXYZ(dplyr::select(x, -`Z`, -`T`), ...)
}
