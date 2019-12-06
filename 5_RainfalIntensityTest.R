# setwd("/Users/leleshu/Dropbox/workspace/Xcode/PIHM++/Build/Products/Debug")
clib=c('rgdal', 'rgeos', 'raster', 'sp', 'PIHMgisR','xts', 'ggplot2', 'sfsmisc')
x=lapply(clib, library, character.only=T)
rm(list=ls()); library(SHUDtoolbox)
source('Common.R')
source('2_Parameters.R')

prjname='vs'
outpath=file.path('output', paste0(prjname,'.out') )
inpath = file.path('input', prjname)
SHUDtoolbox::shud.env(prjname, inpath, outpath)
# fig.dir='/Users/leleshu/Dropbox/PIHM/Benchmark/vSimple/Figure'
fig.dir='Figure'
dir.create(fig.dir, showWarnings = F, recursive = T)

riv=readriv()
oid=getOutlets()
pp=c(0.5, 1, 10, 25)
nx=length(pp)
tt=1:200
# source('Run_Multiple.R')
xl=readRDS('compare.RDS')
yl <- lapply(xl, function(x) x[, 1]) 
x.p <- do.call("cbind", yl)[tt, ]

yl <- lapply(xl, function(x) x[, 2]) 
x.st <- do.call("cbind", yl)[tt, ]

yl <- lapply(xl, function(x) x[, 3]) 
x.qs <- do.call("cbind", yl)[tt, ]

yl <- lapply(xl, function(x) x[, 4]) 
x.qr <- do.call("cbind", yl)[tt, ]

yl <- lapply(xl, function(x) x[, 5]) 
x.stmax <- do.call("cbind", yl)[tt, ]

cn=paste0('X', pp)
colnames(x.p)=cn
colnames(x.st)=cn
colnames(x.qs)=cn
colnames(x.qr)=cn
colnames(x.stmax)=cn

lty=c(2, 1, 3:nx); col=1

# plot(-x.qs)
xt=t(matrix(tt, nx, ncol=length(tt), nrow=nx))

# plot(cbind(tt, tt), cbind(x.qr[,2]/AA, x.p[, 2])/24)
# stop()

par(mfrow=c(3,1), mar=c(1, 4, 0, 1), oma=c(3,1,1,1))
matplot(xt, coredata(x.stmax), type='l',col=col,  lty=lty, 
     axes=F,
     xlab='Time (min)', ylab='River stage (m)')
axis(side=1, labels = NA); axis(side=2); box(); grid()

matplot(xt, coredata(x.qs) / AA /1440* -1,  type='l',col=1,  lty=lty, 
        axes=F,
     xlab='Time (min)', ylab=bquote('Sideplane Flux (' ~ m/hr~ ')') ) 
axis(side=1, labels = NA); axis(side=2); box(); grid()
legend('right', paste0(cn, ' (', 18 * pp, 'mm/min)'),
       lty=lty, col=col )


matplot(xt, coredata(x.qr) / AA /1440,  type='l',col=1,  lty=lty, 
        xlab='Time (min)', ylab=('River outlet Flux (' ~ m/hr~ ')') ) 
abline(h=pp/1000 * 18, col=1,  lty=lty)
mtext(side=1, 'Time(min)', line=2.5)

apply(x.p, 2, max)/1440*1000

