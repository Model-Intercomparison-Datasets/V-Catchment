library(raster)
library(sp)
library(rgeos)
library(rgdal)
library(SHUDtoolbox)
library(xts)
library(lattice)
# library(rgl)
library(rasterVis)

prj=CRS('+init=EPSG:5070')
backup=FALSE
# size : 800 * 1000
# riv width =20
# Roughness 0.015 on slope, 0.15 in river
# slope = 0.05 on X-dierction slope, 0.02 in Y-direction river.
lx = 800;  ly = 1000
lx1=lx3=lx; lx2=20;
sx=0.05; sy=0.02
Rough.slope =  0.015 / 86400 
Rough.river = 0.15 / 86400 

a.max = 1e6 * .005;
q.min = 33;
nriv=20
riv.start = 9/10 *0.

AA = (lx*2+lx2)*1000

tol.riv=50
tol.wb=50
tol.len = 50
AqDepth = 5
years = 2000:2001

dx = 5; 
datum=1000
ny=length(years)
nday = 1
DayForc = 1
dt.model = 1;
dt.out = max(dt.model, 60)

RivWidth = 20
RivDepth = 2

R0=10.8 #mm/hr
R0*1.5 # Total Precipitation mm in 1.5 hr

Rainfall = R0 /1000 / 60# m/min
Rainfall
Rainfall * 60

TotalRainfall = Rainfall * 90
TotalRainfall



prjname='vs'
workdir = './'
dir.gis = file.path(workdir, 'GISdata')
dir.fig = file.path(workdir, 'Figure')
dir.create(dir.gis, showWarnings = F, recursive = T)
inpath <- file.path(workdir, 'input', prjname)
outpath <- file.path(workdir, 'input', paste0(prjname, '.out'))

fin <- shud.filein(prjname, inpath = inpath, outpath=outpath)
