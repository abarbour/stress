#!/usr/bin/Rscript --no-save
#
#	Plot_smooth.r.R
#	/Users/abarbour/survey.processing/projects.github/StressInversion/src/SATSI_140818
#	Created by 
#		/Users/abarbour/bin/ropen
#	on 
#		2015:065
#

fi <- if (!interactive()){
        cargs <- commandArgs(TRUE)
        n.args <- length(cargs)
        if (n.args == 0 | n.args > 2){
                message("\ninputs:\t 1  '.smooth' file to process\n\n\ninputs:\t[2]  data file used\n\nSome options in ./:\n")
                dl <- list.files('.smooth', path=".")
                print(dl[grep('.smooth$', dl, perl=TRUE)])
                message("")
                q(status=1)
        }
        datfi <- ifelse(n.args==2, cargs[2], NA)
        cargs[1]
} else {
	datfi <- "Test2.txt"
        "Test2_tp.smooth"
}

has.datfi <- !is.na(datfi)

library(utils, quietly=TRUE)
library(graphics, quietly=TRUE)
library(raster, quietly=TRUE)
library(rasterVis, quietly=TRUE)
library(plyr, quietly=TRUE)
library(dplyr, quietly=TRUE, warn.conflicts = FALSE)
library(TeachingDemos, quietly=TRUE)

#library(reshape2)
#library(tidyr)
#library(magrittr)

# local libs
library(kook)

Set1 <- RColorBrewer::brewer.pal(8,'Set1')
Pal <- c(brewerRamp("Blues",8,reverse=TRUE),brewerRamp("Reds",8))
#Pal <- brewerRamp("BrBG",15,minus.one=FALSE)
#Pal[8] <- "grey"
Pal <- brewerRamp("Reds",9)
twoPal <- brewerRamp("RdYlBu",11)


# where "1 1", etc, are the indices that show which grid element this result is for.
# phi is the shape of the stress ellipsoid = (S2-S3)/(S1-S3) where S1, S2, and S3 are the principal stress magnitudes from most to least compressive.
# tr1, pl1 are the trend and plunge of the most compressive stress axis
# tr2, pl2 are the trend and plunge of the intermediate stress axis
# tr3, pl3 are the trend and plunge of the most extensional stress axis
# each parameter is followed by three values: the best result, and the limits of the 95% confidence range

dat <- select(read.table(fi, header=FALSE,
	col.names=c(
		'x','y',
		'phi', 'phi.best','phi.05','phi.95',
		'tr1', 'tr1.best','tr1.05','tr1.95',
		'pl1', 'pl1.best','pl1.05','pl1.95',
		'tr2', 'tr2.best','tr2.05','tr2.95',
		'pl2', 'pl2.best','pl2.05','pl2.95',
		'tr3', 'tr3.best','tr3.05','tr3.95',
		'pl3', 'pl3.best','pl3.05','pl3.95'
	)
), # drop a few useless variables
	-phi,
	-tr1,-pl1,
	-tr2,-pl2,
	-tr3,-pl3
)
	
#summary(dat)
#coordinates(dat) <- ~ x + y
#xy <- coordinates(dat)

asp <- 1/2
xl <- c(0, 30)
yl <- c(0, 60)
zl <- c(0.5,1)

SHMax <- function(Dd, ctr=TRUE){
	with(Dd, {
	
		#if (ctr) points(x, y, pch=21, cex=0.7, col='yellow', bg=ifelse(phi.best>0.75,'red','blue'))
		my.symbols(x, y, ms.arrows, 
			#symb.plots=TRUE,
			angle=-tr1.best*pi/180, r=1/(phi.95 - phi.05)/3, length=0.05, adj=1,
			col=ifelse(phi.best>0.75,'red','blue'))
		my.symbols(x, y, ms.arrows,
			#symb.plots=TRUE,
			angle=-tr1.best*pi/180 + pi, r=1/(phi.95 - phi.05)/3, length=0.05, adj=1,
			col=ifelse(phi.best>0.75,'red','blue'))
	})
}

#
# Stress Ratio
#
Dat0 <- dat[,c('x','y','phi.best')]
Rd <- rasterFromXYZ(Dat0)
eDat0 <- dat[,c('x','y','phi.95','phi.05')]
Rd.err <- rasterFromXYZ(transmute(mutate(eDat0, phi.stderr = ((phi.95 - phi.05)/2)/2), x, y, phi.stderr))

All.r <- rasterVis::levelplot(stack(list(R=Rd, std.error=Rd.err)),  
	main="Principal-Stress Ratio",
	par.settings=rasterTheme(region = brewer.pal(10, "PuOr")))

#
# Trend S1 axis
#
Dat1 <- dat[,c('x','y','tr1.best')]
Rtr1 <- rasterFromXYZ(Dat1)
eDat1 <- dat[,c('x','y','tr1.95','tr1.05')]
Rtr1.err <- rasterFromXYZ(transmute(mutate(eDat1, Stderr = abs((tr1.95%%360 - tr1.05%%360)/2)/2), x, y, Stderr))

#rasterVis::levelplot(stack(list(S1=Rtr1, std.error=Rtr1.err)), main="Trend", par.settings=rasterTheme(region = brewer.pal(10, "RdBu")))


#
# Trend S2 axis
#
Dat2 <- dat[,c('x','y','tr2.best')]
Rtr2 <- rasterFromXYZ(Dat2)
eDat2 <- dat[,c('x','y','tr2.95','tr2.05')]
Rtr2.err <- rasterFromXYZ(transmute(mutate(eDat2, Stderr = abs((tr2.95%%360 - tr2.05%%360)/2)/2), x, y, Stderr))

#rasterVis::levelplot(stack(list(S2=Rtr2, std.error=Rtr2.err)), main="Trend", par.settings=rasterTheme(region = brewer.pal(10, "RdBu")))
	

#
# Trend S3 axis
#
Dat3 <- dat[,c('x','y','tr3.best')]
Rtr3 <- rasterFromXYZ(Dat3)
eDat3 <- dat[,c('x','y','tr3.95','tr3.05')]
Rtr3.err <- rasterFromXYZ(transmute(mutate(eDat3, Stderr = abs((tr3.95%%360 - tr3.05%%360)/2)/2), x, y, Stderr))

#rasterVis::levelplot(stack(list(S3=Rtr3, std.error=Rtr3.err)), main="Trend", par.settings=rasterTheme(region = brewer.pal(10, "RdBu")))

#
# Plunge S1 axis
#
Dat1p <- dat[,c('x','y','pl1.best')]
Pl1 <- rasterFromXYZ(Dat1p)
eDat1p <- dat[,c('x','y','pl1.95','pl1.05')]
Pl1.err <- rasterFromXYZ(transmute(mutate(eDat1p, Stderr = abs((pl1.95 - pl1.05)/2)/2), x, y, Stderr))

#rasterVis::levelplot(stack(list(S1 = Pl1, std.error=Pl1.err)), main="Plunge", par.settings=rasterTheme(region = brewer.pal(9, "Greens")))

#
# Plunge S2 axis
#
Dat2p <- dat[,c('x','y','pl2.best')]
Pl2 <- rasterFromXYZ(Dat2p)
eDat2p <- dat[,c('x','y','pl2.95','pl2.05')]
Pl2.err <- rasterFromXYZ(transmute(mutate(eDat2p, Stderr = abs((pl2.95 - pl2.05)/2)/2), x, y, Stderr))

#rasterVis::levelplot(stack(list(S2 = Pl2, std.error=Pl2.err)), main="Plunge", par.settings=rasterTheme(region = brewer.pal(9, "Greens")))

#
# Plunge S3 axis
#
Dat3p <- dat[,c('x','y','pl3.best')]
Pl3 <- rasterFromXYZ(Dat3p)
eDat3p <- dat[,c('x','y','pl3.95','pl3.05')]
Pl3.err <- rasterFromXYZ(transmute(mutate(eDat3p, Stderr = abs((pl3.95 - pl3.05)/2)/2), x, y, Stderr))

#rasterVis::levelplot(stack(list(S3 = Pl3, std.error=Pl3.err)), main="Plunge", par.settings=rasterTheme(region = brewer.pal(9, "Greens")))

tpal <- c(brewer.pal(10, "RdBu")) #,"yellow")
#tpal <- tpal[c(5:1,11:11,10:6)]

All.trend <- rasterVis::levelplot(stack(
	list(
		S1=Rtr1,
		S2=Rtr2,
		S3=Rtr3,
		std.error=Rtr1.err, 
		std.error=Rtr2.err,
		std.error=Rtr3.err
	)),  
	main="Trend",
	layout=c(3, 2),
	par.settings=rasterTheme(region = tpal)) #c("white",tpal,"white")))


All.plunge <- rasterVis::levelplot(stack(
	list(
		S1=Pl1,
		S2=Pl2, 
		S3=Pl3,
		std.error=Pl1.err, 
		std.error=Pl2.err,
		std.error=Pl3.err
	)),  
	main="Plunge",
	layout=c(3, 2),
	par.settings=rasterTheme(region = brewer.pal(9, "Greens")))


TP <- function(ang.t, ang.p, r=NULL, add=FALSE, ...){
	#
	XYc <- complex(argument=pi/2-ang.t*pi/180, modulus=90*cos(ang.p*pi/180))
	if (!add){
		circ <- strain::circle()
		plot(circ*95, asp=1, type='l', col=NA, lwd=1.5,	axes=FALSE, xlab="", ylab="")
		lines(circ*90, col='grey', lwd=1.5)
		segments(c(-90,0),c(0,-90),c(90,0),c(0,90), col='grey', lty=3)
		points(0,0,pch=3,col='grey',lwd=2)
		text(c(-95,0,95,0),c(0,-95,0,95),c('W','S','E','N'), col='grey50')
		#
	}
	points(XYc, cex=0.8, pch=16, ...)
}

PLT_TP <- function(){
	opar <- par(no.readonly = TRUE)
	par(mar=rep(1.1,4), oma=rep(0.1,4))
	TP(Dat1$tr1.best, Dat1p$pl1.best, col=Set1[1])
	TP(Dat2$tr2.best, Dat2p$pl2.best, col=Set1[3], add=TRUE)
	TP(Dat3$tr3.best, Dat3p$pl3.best, col=Set1[2], add=TRUE)
	mtext(c('S1','S2','S3'), side=3, cex=0.8, col=Set1[c(1,3,2)], font=4, line=-3, 
		adj=1-c(0.97,0.90,0.83)-0.03)
	mtext(sprintf("%s\ntrend-plunge axes",fi), adj=0, font=4, line=-1.5, cex=1.0)

	r=Dat0$phi.best #NULL
	if (!is.null(r)){
		u <- par("usr")
		v <- c(
		  grconvertX(u[1:2], "user", "ndc"),
		  grconvertY(u[3:4], "user", "ndc")
		)
		v <- c((v[1]+v[2])/1.33, v[2], (v[3]+v[4])/1.15, v[4] )
		v[1:2] <- v[1:2]+0.04
		v[3:4] <- v[3:4]+0.00
		#print(v)
		#rect(u[2], u[4], (u[1]+u[2])/4, (u[3]+u[4])/4)
		par(fig=pmin(v,1), new=TRUE, mar=c(0,0,0,0), mgp=c(2,0.1,0), tcl=-0.2)
		#plot(d0_inset, axes=FALSE, xlab="", ylab="")
		hist(r, yaxt="n", main="", col="light grey", cex.axis=0.6, xlim=c(0,1.1))
		#mtext("Stress ratio",adj=0.5,side=1,line=1,cex=0.7)
		mtext(expression(over(S[2]-S[3],S[1]-S[3])),adj=0.5,side=1,line=2.1,cex=0.7)
		par(u)
	}
	par(opar)
}

All.trend

#PLT_TP()

#stop()

niceEPS("TP_stereonet", toPDF=TRUE, h=5, w=5)
try(PLT_TP())
niceEPS()

niceEPS("Stress_ratios", toPDF=TRUE, h=7, w=6)
try(print(All.r))
niceEPS()

niceEPS("Trend_axes", toPDF=TRUE, h=7, w=6)
try(print(All.trend))
niceEPS()

niceEPS("Plunge_axes", toPDF=TRUE, h=7, w=6)
try(print(All.plunge))
niceEPS()


stop()

#
#
#Dat <- cbind(rc) #, tr1=Dat0[,c('tr1.best')])
#coordinates(Dat) ~ xr + yr

#Rt1p <- rasterize(coordinates(Dat), Rd, Dat0[,c('tr1.best')], fun=mean) #rasterFromXYZ(Dat) #, crs=CRS('+proj=longlat +ellps=WGS84'))
#rasterVis::levelplot(Rt1p)

# http://www.remotesensing.org/geotiff/proj_list/hotine_oblique_mercator.html
#ncrs <- CRS('+proj=omerc +lat_0=33.1 +lonc=-115.6 +alpha=35')
#              +k_0=Scale factor on initial line 
#              +x_0=False Easting
#              +y_0=False Northing
#Rt1 <- projectRaster(Rt1p, crs=ncrs)
#rasterVis::levelplot(Rt1)

PuOr <- brewer.pal(9, "PuOr")
PuOr[5] <- 'yellow'
plot(Rd, col=PuOr)

if (has.datfi){
	message(datfi)
	layout(matrix(1:3,1))
	odat <- read.table(datfi, header=FALSE, skip=1, col.names=c('x','y',"S.","D.","R."))
	
	plot(jitter(y,2) ~ jitter(x,2), odat, pch=16, cex=0.2, asp=asp, xlim=xl, ylim=yl)
	#SHMax(dat, ctr=FALSE)
	
	pe <- extent(par('usr'))
	#plot(pe, xlab='', ylab='', col=NA)
	#plot(Rt1, col=twoPal, zlim=c(-180,180), add=TRUE)
	levelplot(Rt1, par.settings=PuOrTheme(), FUN.margin=median, cuts=9)
	
	plot(pe, xlab='', ylab='', col=NA)
	plot(Rd, col=Pal, zlim=zl, add=TRUE)
} else {
	plot(Rd, col=Pal, zlim=zl, asp=asp)
}
SHMax(dat, TRUE)
