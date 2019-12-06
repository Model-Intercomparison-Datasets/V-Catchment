
library(deSolve)
par(mfrow=c(1,1))
nt.per.dat= 1440
# nt=nday=1440
nt=nday * nt.per.dat

xt=1:nt - 1
# P=abs(sin(xt/100)) / 100
# P[P < 0.008]=0
P=xt*0
P[1:90] =  Rainfall * 1440 # m/min  -> m/day

f.manning <- function(y,n, w=ly, s=sx){
  A = y * w;
  r = A / (2 * y + w)
  Q = A /n * sqrt(s) * r ^ (2/3)
}

logist <- function(t, x, parms) {
  with(as.list(parms), {
    Q = f.manning(y=x, n=n, w=w, s=s)
    dq = Q/A
    dx = p - dq
    list(dx+x)
  })
}
parms = list(A=1000*800, n=Rough.slope, w=ly, s=sx, p=Rainfall/60)
# 

time  <- 0:100
N0    <- 0.1; r <- 0.5; K <- 100
x <- c(N = N0)
# 
# logist <- function(t, x, parms) {
#   with(as.list(parms), {
#     dx <- r * x[1] * (1 - x[1]/K)
#     list(dx)
#   })
# }
# parms <- c(r = r, K = K)

## analytical solution
# plot(time, K/(1 + (K/N0-1) * exp(-r*time)), ylim = c(0, 120),
#      type = "l", col = "red", lwd = 2)

## reasonable numerical solution with rk4
time <- seq(0, 1200, 1)

out <- as.data.frame(rk4(x, time, logist, parms))
plot(out$time, out$N, pch = 16, col = "blue", cex = 0.5)

# points(out$time, out$N, pch = 16, col = "blue", cex = 0.5)
