
cb=readcalib()
mat.cb=NULL
for(i in 1:nx){
  mat.cb =rbind(mat.cb, cb)
}
mat.cb$TS_PRCP=pp
flag=file.copy(from = '/Users/leleshu/Dropbox/SHUD/github/SHUD/Build/Products/Debug/shud',
               to='shud', overwrite = TRUE)
if(!flag){
  stop('Check the MODEL exe.')
}
xl=list()
for(i in 1:nx){
  cfg.calib=mat.cb[i, ]
  write.config(x=cfg.calib, file = shud.filein()['md.calib'])
  system('./shud vs', wait = TRUE, ignore.stdout = F)
  x.p=readout('elevprcp')[,1]
  x.stage=readout('rivystage')
  x.qs=rowSums(readout('rivqsurf') )
  x.qr=readout('rivqdown')[,oid]
  x.st=x.stage[,oid]
  x.stmax=apply(x.stage, 1, max, na.rm=TRUE)
  xx=cbind('prc0'=x.p, 'Stage'=x.st, 'Qs'=x.qs, 'Qr'=x.qr, 'STMAX'=x.stmax)
  xl[[i]]=xx
}
saveRDS(xl, 'compare.RDS')

