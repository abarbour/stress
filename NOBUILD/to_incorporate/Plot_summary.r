#!/usr/bin/Rscript --no-save
#
#	plot_summary.R
#	/Users/abarbour/survey.processing/projects.github/StressInversion/src/SATSI_140818
#	Created by 
#		/Users/abarbour/bin/ropen
#	on 
#		2015:065
#

fi <- if (!interactive()){
        cargs <- commandArgs(TRUE)
        n.args <- length(cargs)
        if (n.args == 0 | n.args > 3){
                message("\ninputs:\t 1  '.summary' file to process\n\nSome options in ./:\n")
                dl <- list.files('.summary', path=".")
                print(dl[grep('.summary$', dl, perl=TRUE)])
                message("")
                q(status=1)
        }
        cargs[1]
} else {
        "Test2.summary"
}


#library(reshape2)
#library(plyr)
#library(dplyr) # load after plyr
#library(tidyr)
#library(magrittr)

# local libs
suppressMessages(library(kook, quietly=TRUE))

dat <- read.table(fi, header=FALSE, skip=1, col.names=c('damping','misfit','model.size'))
Pal <- brewerRamp('Spectral',nrow(dat))

pfi <- paste0(fi,'.pdf')
message("generating pdf:\t", pfi)
pdf(file=pfi, height=4, width=8)
try({
	layout(matrix(1:3,1))
	par(cex=0.75, las=1, mar=c(5.1,4.1,4.1,0.4))

	plot(misfit ~ damping, dat, 
		type='b', pch=22, bg=Pal, cex=1.5, xlab="Damping", ylab="Misfit",
		lwd=ifelse(damping==1.4,2,1),
		col=ifelse(damping==1.4,'black','grey'))
	grid()

	plot(log10(model.size) ~ damping, dat, 
		type='b', pch=22, bg=Pal, cex=1.5, yaxt='n', xlab="Damping", ylab="Model size",
		lwd=ifelse(damping==1.4,2,1),
		col=ifelse(damping==1.4,'black','grey'))
	logticks(2, major.ticks=-7:2)
	grid()

	plot(log10(model.size) ~ misfit, dat, 
		type='b', pch=22, bg=Pal, cex=1.5, yaxt='n', xlab="Misfit", ylab="Model size",
		lwd=ifelse(damping==1.4,2,1),
		col=ifelse(damping==1.4,'black','grey'))
	logticks(2, major.ticks=-7:2)
	grid()

	title(paste("Summary of 2D Stress Inversion:", fi), outer=TRUE, line=-2)
})
invisible(dev.off())