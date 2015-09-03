# Dat0 <- dat[,c('x','y','phi.best')]
# Rd <- rasterFromXYZ(Dat0)
# eDat0 <- dat[,c('x','y','phi.95','phi.05')]
# Rd.err <- rasterFromXYZ(transmute(mutate(eDat0, phi.stderr = ((phi.95 - phi.05)/2)/2), x, y, phi.stderr))
#
# All.r <- rasterVis::levelplot(stack(list(R=Rd, std.error=Rd.err)),
#                               main="Principal-Stress Ratio",
#                               par.settings=rasterTheme(region = brewer.pal(10, "PuOr")))

#' Convert objects to raster objects
#' @export
to_raster <- function(x, ...) UseMethod('to_raster')

#' @rdname to_raster
#' @export
to_raster.msatsi_summary_ext <- function(x, ...){
  dplyr::select(x, -`Z`, -`T`) -> xr
  raster::rasterFromXYZ(xr, ...)
}
