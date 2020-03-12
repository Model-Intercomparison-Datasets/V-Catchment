source('Common.R')
iplot=FALSE
graphics.off()

dir.create(workdir, showWarnings = F, recursive = T)


wbd=readOGR( file.path(dir.gis, paste0(prjname, '_wbd.shp')) )
riv=readOGR( file.path(dir.gis, paste0(prjname, '_riv.shp')) )
dem=raster( file.path(dir.gis, paste0(prjname, '_dem.tif')) )
forc.fns=c('forc.csv' )
r0=dem * 0 +1


wbbuf = rgeos::gBuffer(wbd, width = 1000)
dem = raster::crop(dem, wbbuf)
if(iplot){
png(file = file.path(dir.png, 'data_0.png'), height=11, width=11, res=100, unit='in')
plot(dem); plot(wbd, add=T, border=2, lwd=2); plot(riv, add=T, lwd=2, col=4)
dev.off()
}

riv.s1 = rgeos::gSimplify(riv, tol=tol.riv, topologyPreserve = T)
riv.s2 = sp.simplifyLen(riv, tol.len)
if(iplot){
  plot(riv.s1); plot(riv.s2, add=T, col=3)
}

wb.dis = rgeos::gUnionCascaded(wbd)
wb.s1 = rgeos::gSimplify(wb.dis, tol=tol.wb, topologyPreserve = T)
wb.s2 = sp.simplifyLen(wb.s1, tol.len)
if(iplot){
png(file = file.path(dir.png, 'data_1.png'), height=11, width=11, res=100, unit='in')
plot(dem); plot(wb.s2, add=T, border=2, lwd=2); 
plot(riv.s2, add=T, lwd=2, col=4)
dev.off()
}


wb.simp = wb.s2
riv.simp = riv.s2

tri = shud.triangle(wb=wb.simp,q=q.min, a=a.max)
if(iplot){
  plot(tri, asp=1, type='n')
}

# generate  .mesh 
pm=shud.mesh(tri,dem=dem, AqDepth = AqDepth)

spm = sp.mesh2Shape(pm, crs = crs(riv))
writeshape(spm, crs(wbd), file=file.path(inpath, 'gis', 'domain'))

# generate  .att
# debug(pihmAtt)
pa=shud.att(tri )
# forc.fns = paste0(sp.forc@data[, 'NLDAS_ID'], '.csv')
# forc.fns
write.forc(forc.fns, path=workdir,
          file=fin['md.forc'])

# generate PIHM .riv
# undebug(pihmRiver)
pr=shud.river(riv.simp, dem)
pr@rivertype[,'Manning'] = Rough.river
pr@rivertype[,'Width'] = RivWidth
pr@rivertype[,'Depth'] = RivDepth

# Correct river slope to avoid negative slope
# pr = correctRiverSlope(pr)

# PIHMriver to Shapefile
# spr = sp.riv2shp(pr)
spr = riv
writeshape(spr, crs(wbd), file=file.path(inpath, 'gis', 'river'))

# Cut the rivers with triangles
# sp.seg = sp.RiverSeg(pm, pr)
sp.seg=sp.RiverSeg(spm, spr)
writeshape(sp.seg, crs(wbd), file=file.path(inpath, 'gis', 'seg'))

# Generate the River segments table
prs = shud.rivseg(sp.seg)

# Generate initial condition
pic = shud.ic(nrow(pm@mesh), nrow(pr@river))


message('Mesh Shapefile')
# Generate shapefile of mesh domain
sp.dm = sp.mesh2Shape(pm)
if(iplot){
png(file = file.path(dir.png, 'data_2.png'), height=11, width=11, res=100, unit='in')
zz = sp.dm@data[,'Zsurf']
ord=order(zz)
col=terrain.colors(length(sp.dm))
plot(sp.dm[ord, ], col = col)
plot(spr, add=T, lwd=3)
dev.off()
}
zz = sp.dm@data[,'Zsurf']
ord=order(zz)
col=terrain.colors(length(sp.dm))
plot(sp.dm[ord, ], col = col)
plot(spr, add=T, lwd=3, col=1:length(spr))
cxy=coordinates(sp.dm)
if(nrow(cxy)<100){
  text(cxy, paste(round(zz) ) )
}
# model configuration, parameter
cfg.para = shud.para()

# calibration
cfg.calib = shud.calib()

#soil/geol/landcover
lc = 42
para.lc = PTF.lc(lc=lc)
para.soil = PTF.soil()
para.geol = PTF.geol()
para.lc[,'ROUGH'] = Rough.slope

para.lc[,'IMPAF']=1
# stop()
# 43-mixed forest in NLCD classification
# 23-developed, medium           
# 81-crop land
# 11-water

message('LAI TS data')
lr=fun.lairl(lc, years=years)
# png(file = file.path(dir.png, 'data_lairl.png'), height=11, width=11, res=100, unit='in')
# par(mfrow=c(2,1))
# col=1:length(lc)
# plot(lr$LAI, col=col, main='LAI'); 
# legend('top', paste0(lc), col=col, lwd=1)
# plot(lr$RL, col=col, main='Roughness Length'); 
# legend('top', paste0(lc), col=col, lwd=1)
# dev.off()
write.tsd(lr$LAI, file = fin['md.lai'], backup = backup)
write.tsd(lr$RL, file = fin['md.rl'], backup = backup)

message('LAI TS data')
#MeltFactor
mf = MeltFactor(years = years)
write.tsd(mf, file=fin['md.mf'], backup = backup)

# write PIHM input files.
write.mesh(backup=backup, pm, file = fin['md.mesh'])
write.riv(backup=backup, pr, file=fin['md.riv'])
write.ic(backup=backup, pic, file=fin['md.ic'])

write.df(backup=backup, pa, file=fin['md.att'])
write.df(backup=backup, prs, file=fin['md.rivseg'])
write.df(backup=backup, para.lc, file=fin['md.lc'])
write.df(backup=backup, para.soil, file=fin['md.soil'])
write.df(backup=backup, para.geol, file=fin['md.geol'])

write.config(backup=backup, cfg.para, fin['md.para'])
write.config(backup=backup, cfg.calib, fin['md.calib'])
print(nrow(pm@mesh))




ModelInfo()

go.map.mesh <- function(){
  spm=sp.mesh2Shape(pm)
  spr=readOGR('input/vs/gis/river.shp')
  z=spm@data$Zmax; nz=length(z)
  col=(colorspace::diverge_hcl(length(z)))
  graphics.off()
  png.control(fn='vc_mesh.png', path = 'Figure', wd=8, ht=6)
  par(mar=c(2,2,4,1))
  plot(spm[order(z), ], col=col, axes=T)
  plot(add=T, spr, lwd=3, col=rgb(.7, .7, .7, .5))
  plot(spr, add=T, col='darkgreen')
  rz=MeshData2Raster(x=z)
  yloc=c(0.0, 0.03)+0.92; xloc=c(0.0, 0.6)+.2
  plot(rz-1000, legend.only=TRUE, col=col,
       smallplot=c(xloc, yloc),
       legend.width=5, legend.shrink=1, cex=5, horizontal=T,
       axis.args=list(col.axis='blue', lwd = 0,
                      font.axis=4, cex.axis=1.5,tck = 0, 
                      line=-.95, cex.axis=1),
       legend.args=list(text='Elevation (m)',col=4, side=3, font=2, cex=1) )
  dev.off()
}
go.map.mesh()
