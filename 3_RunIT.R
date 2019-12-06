clib=c('rgdal', 'rgeos', 'raster', 'sp', 'SHUDtoolbox','xts', 'ggplot2')
x=lapply(clib, library, character.only=T)
rm(list=ls()); 
prjname='vs'
outpath=file.path('output', paste0(prjname,'.out') )
inpath = file.path('input', prjname)
shud.env(prjname, inpath, outpath)
source('2_Parameters.R')

flag=file.copy(from = '/Users/leleshu/Dropbox/SHUD/github/SHUD/Build/Products/Debug/shud',
          to='shud', overwrite = TRUE)
if(!flag){
  stop('Check the MODEL exe.')
}
system('./shud vs', wait = TRUE, ignore.stdout = F)