# setwd("/Users/leleshu/Dropbox/workspace/Xcode/PIHM++/Build/Products/Debug")
clib=c('rgdal', 'rgeos', 'raster', 'sp','xts', 'ggplot2', 'sfsmisc')
x=lapply(clib, library, character.only=T)
rm(list=ls()); library(SHUDtoolbox)
source('Common.R')
source('3_RunIT.R')
prjname='vs'
outpath=file.path('output', paste0(prjname,'.out') )
inpath = file.path('input', prjname)
SHUDtoolbox::shud.env(prjname, inpath, outpath)
# fig.dir='/Users/leleshu/Dropbox/PIHM/Benchmark/vSimple/Figure'
fig.dir='Figure'
dir.create(fig.dir, showWarnings = F, recursive = T)
# ob.slope=read.csv('/Users/leleshu/Dropbox/PIHM/Benchmark/vcat/Ref/Q_Slope.csv')
# ob.river=read.csv('/Users/leleshu/Dropbox/PIHM/Benchmark/vcat/Ref/Q_River_RKFV.csv')
# saveRDS(list(slope=ob.slope, river=ob.river), 'SHEN2010.RDS')
obs=readRDS('SHEN2010.RDS')
ob.slope=obs$slope
ob.river=obs$river
# ob.s = as.xts(ob.slope[, 2],order.by = as.POSIXct('2000-01-01')+ob.slope[, 1] * 60); colnames(ob.s)='Y'
# ob.r = as.xts(ob.river[, 2],order.by = as.POSIXct('2000-01-01')+ob.river[, 1] * 60); colnames(ob.r)='Y'
fx <-function(ob.slope){
  noo=nrow(ob.slope)
  sum(diff(ob.slope[, 1]) * (diff(ob.slope[, 2])/2 + ob.slope[2:noo-1, 2]) )
}
fx(ob.slope)

fx.ds <- function(x){ dx = as.numeric(x[nrow(x),]) - as.numeric(x[1,]) }
pngout = file.path(outpath, 'figure')
dir.create(pngout, recursive = T, showWarnings = F)
pr=readriv()
oid=getOutlets(pr)
pm = readmesh()
ia=getArea()
AA=sum(ia)
seg=readchannel()
cfg.para=readpara()
dt=as.numeric(cfg.para['DT_QR_DOWN'])
minfo = c(Ncell = length(ia), Nriv=nrow(pr@river), Nseg =nrow(seg),
          AreaMean = mean(ia))
xinit= readic()
vns=c(paste0('eley',c( 'surf', 'gw', 'unsat' ) ), 'elevexfil',
      paste0('elev',c('prcp') ),
      # 'elevinfil', 'elevrech', 'eleqsurf',
      'eleyunsat', 'eleygw',paste0('rivy','stage'), paste0('rivq',c('down', 'sub', 'surf')) ) 
att=readatt()
geol=readgeol(); soil=readsoil()
porosity = geol[att[, 'GEOL'], 4]- geol[att[, 'GEOL'], 5]
xl = BasicPlot(varname=vns, plot = F, imap = F, return = T, iRDS = F)

# smax = apply(xl$eleysurf, 2, max)
# spm=sp.mesh2Shape(dbf = smax)
pin = readforc.csv()[[1]]
prcp = xl$elevprcp[, 1]
apply.daily(prcp, FUN=mean)
apply.daily(pin[, 1], FUN=mean)[1,]
# 
# integrate.xy(x=ob.slope[, 1], fx=ob.slope[, 2])
# integrate.xy(x=ob.river[, 1], fx=ob.river[, 2])
# id=1:180
# integrate.xy(x=id, fx=wb[id, 1])
# integrate.xy(x=id, fx=wb[id, 2])
# integrate.xy(x=id, fx=wb[id, 3])
# 
# range(ob.slope[, 1])
# range(ob.river[, 1])

source('function.R')
wb=go.wb()
# go.mt()
gg=go.compareSHEN(enlarge = 20, tt=1:200)

# stop()
# undebug(wb.DS)
dsf= sum(DeltaS(xl$eleysurf, xinit$minit[,4]) * ia/AA) * 1000
dus= sum(DeltaS(xl$eleyunsat, xinit$minit[,5]) * ia/AA* porosity ) * 1000
dgw= sum(DeltaS(xl$eleygw, xinit$minit[,6]) * ia/AA* porosity) * 1000
c(dsf, dus, dgw)
rivArea = pr@rivertype[, 'Width'] * pr@river[,'Length']
dst= sum(DeltaS(xl$rivystage, xinit$rinit[,2])* rivArea) /AA
# dst=sum( (as.numeric(last(xl$rivystage)) - xinit$rinit[,2]) * rivArea ) /AA
ss=c(apply(wb, 2,sum), dsf=dsf, dus=dus, dgw=dgw, dst=dst)
ss
P = ss[1]; Q = ss['Qd']; DS = sum(ss[c('dsf', 'dus', 'dgw', 'dst')])
Snet = P-Q-DS
MB = Snet/P
minfo
summary(ia)

message('Balance: ');print(ss)
message('P=', round(P, 3), '\tQ=', round(Q, 3),
        '\tP-Q=',  round(P - Q, 3), '\tDS=', round(DS, 3))
message('Mass-Balance Error = ', 
        formatC(Snet, format = "e", digits = 1), 'mm\t',
        round(MB*100, 3), '%')

print(t(gg))
# plot(xl$rivystage[1:120,], col=rev(terrain.colors(ncol(xl$rivystage))))

