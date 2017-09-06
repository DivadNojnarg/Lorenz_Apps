#  This code shows how to
#  solve the lorenz system
#  for a set of different 
#  initial conditions
#  using apply function

library(deSolve)
library(plotly)
library(parallel)

# initiate parallel computing

no_cores <- detectCores() -1
cl <- makeCluster(no_cores)

# Build the model functions

Lorenz<-function(t, state, parameters) {
  
     with(as.list(c(state, parameters)),{
         # rate of change
         dX<-a*(Y-X)
         dY<-X*(c-Z) - Y
         dZ<- X*Y - b*Z
             # return the rate of change
             list(c(dX, dY, dZ))
     }) # end with(as.list ... +}
  
}

Lorenz_sim<- function(x){
  
     parameters <- c(a = 10,
                     b = 8/3,
                     c = 28)
  
  
     state <- c(X = x[1],
                Y = x[2],
                Z = x[3])
  
     times <- seq(0, 100, by = 0.003)
     
     out <- as.data.frame(ode(y = state, times = times, func = Lorenz, parms = parameters))
     
}

# create a list of random initial conditions by column so dim = 3*10

state <- replicate(100, sample(1:100,size=3), simplify="array") 
names(state) <- NULL

# export all previous variables to each R process belonging to the cluster

clusterExport(cl=cl, varlist=c("Lorenz", "Lorenz_sim", "state","ode"))

# Since states are contained by column, MARGIN is set to 2. It would be 1 by row...

#list_out <- apply(state, 2, Lorenz_sim) # without parallel
list_out <- parApply(cl, state, 2, Lorenz_sim)
out_1 <- list_out[[1]]

# some plots
plot(list_out[[1]], upper.panel = NULL) # results for the first set of initial conditions
plot(list_out[[1]]$time, list_out[[1]]$X) # plot of X vs time
plot3d(list_out[[1]]$X,list_out[[1]]$Y,list_out[[1]]$Z, add=T) # plot3d avec rgl
# Bifurcation diagramm
b <- 8/3
c <- 28
eq0 <- c(0,0,0)
eq1 <- c(sqrt(b*(c-1)),sqrt(b*(c-1)),c-1)
eq2 <- c(-sqrt(b*(c-1)),-sqrt(b*(c-1)),c-1)
points3d(0,0,0)
points3d(sqrt(b*(c-1)),sqrt(b*(c-1)),c-1)
points3d(-sqrt(b*(c-1)),-sqrt(b*(c-1)),c-1)


scatterplot3d(list_out[[1]]$X,list_out[[1]]$X,list_out[[1]]$Z)

# a much more elaborated plot3d with plotly package
plot_ly(list_out[[1]], x = list_out[[1]]$X, y = list_out[[1]]$Y, z = list_out[[1]]$Z, type = 'scatter3d', name = 'Trajectories', mode = 'lines',
        line = list(width = 4), scene='scene1', line = list(color = "#256fc4"))

# Density distribution of initial conditions

d<-parApply(cl,state,1,density) # or d<-apply(state,1,density) without parallel
plot(d[[1]],xlab = "value", ylab="Density", add=T, col = "blue", ylim = c(0, 0.015))
lines(d[[2]],xlab = "value", ylab="Density", col = "red")
lines(d[[3]],xlab = "value", ylab="Density", col = "green")
# abline(v =mean(d[[1]]$x), untf = FALSE, col = "blue")
# abline(v =mean(d[[2]]$x), untf = FALSE, col = "red")
# abline(v =mean(d[[3]]$x), untf = FALSE, col = "green")
legend("topright", legend=c("X","Y","Z"), title = "Variables", col = c("blue","red","green"), horiz=TRUE, lty=1:2)

stopCluster(cl)
