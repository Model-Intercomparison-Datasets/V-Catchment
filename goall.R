rm(list=ls()); 
source('Common.R')
graphics.off()



#=======Calibration============
cfg.calib = pihmcalib()
#=======Parameters============
cfg.para = pihmpara(nday = nday)

id=which(grepl('dt_', names(cfg.para)))
cfg.para[id]=dt.out;
# cfg.para[c('dt_ye_surf','dt_Qe_surf', 'dt_qe_prcp',
#            'dt_Qr_up', 'dt_Qr_down', 
#            'dt_Qr_surf','dt_Qr_sub','dt_yr_stage')]=1

# write.config(cfg.para, fin['md.para'])
# write.config(cfg.calib, fin['md.calib'])
source('0_vcat.R')
source('1_PIHMgis.R')
source('2_Parameters.R')
