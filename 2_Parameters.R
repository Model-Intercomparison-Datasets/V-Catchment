source('Common.R')
go.calib <- function(){
  cfg.calib = shud.calib()
  cfg.calib['ET_ETP']=0
  cfg.calib['GEOL_KSATH']=0
  cfg.calib['GEOL_KSATV']=0
  cfg.calib['GEOL_KMACSATH']=000
  
  cfg.calib$TS_PRCP = 1
  
  cfg.calib['SOIL_KINF']=0
  cfg.calib['SOIL_KMACSATV']=0
  cfg.calib['RIV_KH']=0
  cfg.calib$LC_ROUGH = 1
  cfg.calib$`RIV_DPTH+` = 0
  cfg.calib
  write.config(cfg.calib, file=shud.filein()['md.calib'], backup = F )
}
go.para<- function(){
  cfg.para=readpara(); cfg.para
  cfg.para$ABSTOL = 1e-6
  cfg.para$RELTOL = 1e-6
  dt.model = 1
  dt.out = max(dt.model, 1)
  cfg.para$MAX_SOLVER_STEP = dt.model
  cfg.para$END = .85
  id=which(grepl('DT_', names(cfg.para)))
  cfg.para[id]=dt.out;
  write.config(cfg.para, file=shud.filein()['md.para'], backup = F )
}
go.init<-function(){
  x=readic()
  x$minit$Unsat=1
  x$minit$GW=3.5
  x$rinit = x$rinit *0
  write.ic(x, file = shud.filein()['md.ic'], backup=FALSE)
}
go.riv<-function(){
  x=readriv()
  x@rivertype$Depth = 0.1  
}
shud.env(prjname = prjname, inpath = inpath, outpath = file.path(workdir, 'output', paste0(prjname, '.out')))
go.calib()
go.para()
go.init()