rm(list=ls())
source('Common.R')
#=======
nt.per.dat= 24*60
# nt=nday=1440
nt = 5 * nt.per.dat

xt=1:nt - 1
# P=abs(sin(xt/100)) / 100
# P[P < 0.008]=0
P=xt*0
P[1:(90 * nt.per.dat/1440)+10 * 0] =  Rainfall * 1440 # m/min  -> m/day
P[c(1:5, 85:90)]
sum(P>0)

sum(P[1:100]/24 * 1.5)

tmp=cbind(P, 25, .5, 1000, 1e5) 

nrpt = ceiling(DayForc/ 5)
xdf=NULL
for(i in 1:nrpt){
  xdf = rbind(xdf, tmp)
}
xdf=rbind(xdf[1, ], xdf)


tsd= as.xts(xdf, order.by=as.POSIXct('2001-01-01') + 
              (1:nrow(xdf) - 1) * (86400/nt.per.dat))
colnames(tsd)=c('Prcp','T', 'RH', 'Wind', 'Rad')
dir.create(workdir, showWarnings = F, recursive = T)
write.tsd(tsd, file=file.path(workdir, 'forc.csv'), backup = F)
plot.zoo(tsd[,1])

sum(P/24*1.5)

