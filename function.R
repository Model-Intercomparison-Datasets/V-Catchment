
go.mt <- function(wb){
  twb=time(wb); tid=twb
  # tid = which(twb <= as.POSIXct('2000-01-01') + 60 * 250 & twb >= as.POSIXct('2000-01-01') + 60 * 0  )
  p1=autoplot(wb[tid, ], facets = NULL) + labs(x='Time', y='Flux (mm/hr)')+ labs(color = "") 
  # print(p1)
  ggsave(filename = file.path(fig.dir, 'Q_hs.png'), 
         plot = p1, width = 5, height=4, dpi=300)
  
  cwb = cumsum(wb/60)
  p2=autoplot(cwb, facets = NULL)+labs(x='Time', y='Accumulation (mm)')+ labs(color = "") 
  # + scale_color_manual(labels = c("q", "a",'c'), values=brewer.pal(3,"Set2"))
  # print(p2)
  ggsave(filename = file.path(fig.dir, 'Q_hs_cumsum.png'), plot = p2, 
         width = 5, height=4, dpi=300)
  gA <- ggplotGrob(p1); gB <- ggplotGrob(p2)
  grid::grid.newpage()
  gg=gridExtra::gtable_rbind(gA, gB)
  # grid::grid.draw(gg)
  ggsave(filename = file.path(fig.dir, 'Q_hs_vs.png'), plot = gg, 
         width = 5, height=4, dpi=300)
  wb
}

# stop()
go.m3t <- function(enlarge=1, tt=1:200){
  wb=cbind( P=prcp/86400*AA, 
            Qs=-rowSums(xl$rivqsurf)/ 86400 ,  # to m3/s
            # Qg=-rowSums(xl$rivqsub)/AA, 
            Qr=xl$rivqdown[,oid]/ 86400 ) [tt,]
  index(wb) = time(wb);
  twb=time(wb); 
  size=1.5
  xx=fun.t2min(wb)
  
  # tid = which(twb <= as.POSIXct('2000-01-01') + 60 * 250 & twb >= as.POSIXct('2000-01-01') + 60 * 0  )
  xdf=reshape2::melt(xx, id=1)
  p1=ggplot(data=xdf, aes(x=Time, y=value, color=variable))+
    geom_line(size=size) 
  p1=p1+xlab('') + ylab(bquote('Flux (' ~ m^3~s^{-1}~ ')') ) + labs(colour = "Discharge")+
    theme(legend.position = "none")
  # print(p1)
  # ggsave(filename = file.path(fig.dir, 'vcat_vs.png'), 
  #        plot = p1, width = 5, height=4, dpi=300)
  xdf=reshape2::melt(fun.t2min(cumsum(wb[tt, ])*60), id=1)
  xcum<-function(x){
    # x=ob.slope
    nx=nrow(x)
    y=x
    for(i in 2:nx){
      y[i, 2] = integrate.xy(x=x[1:i, 1], fx=x[1:i, 2])
    }
    y
  }        
  vprcp=AA*sum(prcp/1440)
  p2=ggplot()+
    geom_line(data=xdf, aes(x=Time, y=value, color=variable), size=size)
  if(pobs){
    x1=ob.river; x1[,2]=x1[,2]*60
    x2=ob.slope; x2[,2]=x2[,2]*60
    
    p2=p2+
      geom_point(data=xcum(x1), aes(x=T_min, y=Q_m3s), color='lightblue')+
      geom_point(data=xcum(x2), aes(x=T_min, y=Q_m3s), color='lightgreen')
  }
  p2=p2+ xlab('Time (min)') + ylab(bquote('Cumulated flux (' ~ m^3 ~ ')') ) + labs(colour = "Discharge")+
    theme(legend.position =c(.7, .2),
          legend.direction = 'horizontal',
          legend.title = element_blank())
  # print(p2)
  # ggsave(filename = file.path(fig.dir, 'vcat_vs_cum.png'), 
  #        plot = p2, width = 5, height=4, dpi=300)
  
  gA <- ggplotGrob(p1); gB <- ggplotGrob(p2)
  grid::grid.newpage()
  # gg=gridExtra::marrangeGrob(list(gA, gB), nrow=1, ncol=2)
  gg=gridExtra::gtable_rbind(gA, gB)
  grid::grid.draw(gg)
  ggsave(filename = file.path(fig.dir, 'vcat_vs_vs.png'),
         plot = gg, width = 5, height=6, dpi=300)
  gg
}

# stop()
go.compareSHEN <- function(enlarge=1, tt=1:200, pobs=TRUE){
  ob.slope$Q_m3s =  ob.slope$Q_m3s * enlarge
  wb=cbind( P=prcp/86400*AA, 
            Qs=-rowSums(xl$rivqsurf)/ 86400 ,  # to m3/s
            # Qg=-rowSums(xl$rivqsub)/AA, 
            Qr=xl$rivqdown[,oid]/ 86400 ) [tt,]
  index(wb) = time(wb);
  twb=time(wb); 
  size=1.5
  xx=fun.t2min(wb)
  
  yr=approx(x = xx$Time, y=xx$Qr, xout=ob.river$T_min)$y
  ys=approx(x = xx$Time, y=xx$Qs, xout=ob.slope$T_min)$y
  gx =cbind( hydroGOF::gof(sim=yr, obs=ob.river$Q_m3s),
             hydroGOF::gof(sim=ys, obs=ob.slope$Q_m3s))
  
  xcum<-function(x){
    # x=ob.slope
    nx=nrow(x)
    y=x
    for(i in 2:nx){
      y[i, 2] = integrate.xy(x=x[1:i, 1], fx=x[1:i, 2])
    }
    y
  }        
  # tid = which(twb <= as.POSIXct('2000-01-01') + 60 * 250 & twb >= as.POSIXct('2000-01-01') + 60 * 0  )
  myplot <-function(xdf, XS, XO,    col=colorspace::rainbow_hcl(3, c=90)){
    os=data.frame(group='Ref', Time=XS[,1], variable='Side-plane flow', value=XS[,2])
    or=data.frame(group='Ref', Time=XO[,1], variable='Outlet flow', value=XO[,2])
    ox=rbind(os,or)
   pcol = 'darkblue'; alpha=.5
    ggplot() +
      geom_line(data=xdf, aes(x=Time, y=value, colour = variable), size=1.2) +
      geom_point(data=os, aes(x=Time, y=value, shape = variable),
                 size=2.5, color=pcol, alpha=alpha) +
      geom_point(data=or, aes(x=Time, y=value, shape = variable),
                 size=2.5, color=pcol, alpha=alpha) +
      labs(shape="Shen et al.(2010)", colour="Simulations")+
      scale_color_manual(values = col, 
                         labels=c('Precipitation', 'Side-plane flow', 'Outlet flow'))+
      scale_shape_manual(values=16:17)
    # +
    #   scale_shape_manual(values=c(0, 2))
    
  }
  
  #===============p1=====================
  xdf=reshape2::melt(xx, id=1)
  p1=myplot(xdf, XS=ob.slope, XO=ob.river)+ xlab('') +
    ylab(bquote('Flux (' ~ m^3~s^{-1}~ ')') ) +
    theme(legend.position = c(.85, .6),plot.title = element_text(hjust = 0.5)) +
    ggtitle('(a)')
  # p1
  #==============p2======================
  xdf=reshape2::melt(fun.t2min(cumsum(wb[tt, ])*60), id=1)
  x1=ob.slope; x1[,2]=x1[,2]*60
  x2=ob.river; x2[,2]=x2[,2]*60
  p2=myplot(xdf, XS=xcum(x1), XO=xcum(x2)) +xlab('Time (min)') +
    ylab(bquote('Accumulation (' ~ m^3~ ')') )+
    theme(legend.position = "none",plot.title = element_text(hjust = 0.5))+
    ggtitle('(b)')
  # p2
  gA <- ggplotGrob(p1); gB <- ggplotGrob(p2)
  grid::grid.newpage()
  # gg=gridExtra::marrangeGrob(list(gA, gB), nrow=1, ncol=2)
  gg=gridExtra::gtable_rbind(gA, gB)
  grid::grid.draw(gg)
  ggsave(filename = file.path(fig.dir, 'vcat_vs_vs.png'),
         plot = gg, width = 5.5, height=7, dpi=300)
  gx
}
# gg=go.compareSHEN(enlarge = 20, tt=1:200)


fun.t2min <- function(x){
  return( data.frame('Time'=1:nrow(x), coredata(x) ) )
}
go.wb<-function(){
  wb=cbind(P=prcp, 
           Qs=-rowSums(xl$rivqsurf)/AA, 
           # Qg=-rowSums(xl$rivqsub)/AA, 
           Qd=xl$rivqdown[,oid]/AA) * 1000/24/60
  index(wb) = time(wb);
  wb
}
