source('Common.R')

makeZ <- function(lx, ly, dx=1, sx,sy,datum=1000){
  xx=seq(0, lx, by=dx)
  yy=seq(0, ly, by=dx)
  nx=length(xx)
  ny=length(yy)
  xxyy = expand.grid(xx,yy)
  mx = matrix(xxyy[,1], nrow=nx, ncol = ny)
  my = matrix(xxyy[,2], nrow=nx, ncol = ny)
  mz = mx*sx+my*sy
  mz1 = abs(min(mz)) + mz + datum
  # return(list(x=mx,y=my,z=mz1) )
  return(mz1 )
}
z1=makeZ(lx=lx1, ly=ly, dx=dx, sx=-sx , sy=sy, datum = datum)
z2=makeZ(lx=lx2, ly=ly, dx=dx, sx=sx*0, sy=sy, datum = datum)
z3=makeZ(lx=lx3, ly=ly, dx=dx, sx=sx*1, sy=sy, datum = datum)

nr.z2=nrow(z2)
mz=rbind(z1,z2[-1*c(1, nr.z2),], z3)

xx=dx * (1:nrow(mz) - 1)
yy=dx * (1:ncol(mz) - 1)
nx=length(xx)
ny=length(yy)
r=raster(res=dx, xmn=min(xx)-dx/2, xmx=max(xx)+dx/2, ymn=min(yy)-dx/2, ymx=max(yy)+dx/2,
         crs=prj)

r[]= as.numeric(mz[,ny:1]); plot(r)
# plot3D(r)

writeRaster(r, file.path(dir.gis, paste0(prjname, '_dem.tif')), overwrite=TRUE)
#========

rx=mean(xx)
ry = ly * (1- riv.start) / nriv * nriv:0
rxy=cbind(rx,ry)
for(i in 1:nriv){
  r.str=paste("LINESTRING(", paste(paste(rxy[0:1+i, 1],rxy[0:1+i, 2]), collapse=','),')')
  rsl = readWKT(r.str)
  if(i==1){
    r.sl=rsl
  }else{
    r.sl=rbind(r.sl, rsl)
  }
}

# r.str=paste("LINESTRING(",
#              paste(paste(rx,ry), collapse=','),
#              ')')
# r.str
# r.sl=readWKT(r.str)
r.sl=SpatialLinesDataFrame(r.sl, data=data.frame(1:nriv), match.ID = F)
crs(r.sl)=prj
plot(r);plot(r.sl, add=T, lwd=2, col=1:nriv)
writeshape(r.sl, file=file.path(dir.gis, paste0(prjname,'_riv')) )

#============
# undebug(fishnet)
wbd=fishnet(c(0,lx1+lx2+lx3, 0,ly), crs=prj, dx=lx1+lx2+lx3, dy = ly)
plot(r);plot(r.sl, add=T, lwd=2, col=1:nriv);plot(wbd, add=T)
writeshape(wbd, file=file.path(dir.gis, paste0(prjname,'_wbd')) )

plot(r);plot(r.sl, add=T, lwd=2, col=1:nriv);plot(wbd, add=T)

#=======
nt.per.dat= 1440
# nt=nday=1440
nt=nday * 2 * nt.per.dat

xt=1:nt - 1
# P=abs(sin(xt/100)) / 100
# P[P < 0.008]=0
P=xt*0
P[1:90] =  Rainfall * 1440 # m/min  -> m/day

xdf=cbind(P, 25, .5, 1000, 1e5)
tsd= as.xts(xdf, order.by=as.POSIXct('2001-01-01') + xt * (86400/nt.per.dat))
colnames(tsd)=c('Prcp','T', 'RH', 'Wind', 'Rad')
dir.create(workdir, showWarnings = F, recursive = T)
write.tsd(tsd, file=file.path(workdir, 'forc.csv'), backup = F)
plot.zoo(tsd[,1])
