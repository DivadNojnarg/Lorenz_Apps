# Simple implementation but very fast ##
#
#
########################################


library(Rcpp)
library(odeintr)
pars = c(sigma = 10, R = 28, b = 8/3) 
Lorenz.sys = ' dxdt[0] = sigma * (x[1] - x[0]); 
dxdt[1] = R * x[0] - x[1] - x[0] * x[2]; 
dxdt[2] = -b * x[2] + x[0] * x[1]; 
' # Lorenz.sys 
cat(JacobianCpp(Lorenz.sys)) 
compile_implicit("lorenz", Lorenz.sys, pars, TRUE)
# compile_sys("lorenz", Lorenz.sys, pars, TRUE, method = "rk4") # use the rk4 method instead
x = lorenz(rep(1, 3), 100, 0.003) # rep(1,3) is the vector of initial conditions (1,1,1)
plot(x[, c(2, 4)], type = 'l', col = "steelblue") 
Sys.sleep(0.5)

#pairs(x, upper.panel = NULL)



## Let's try several 100  
#  different initial conditions
#  with apply function 
#########################################


library(Rcpp)
library(odeintr)
library(rgl)

pars = c(sigma = 10, R = 28, b = 8/3) 
Lorenz.sys = ' dxdt[0] = sigma * (x[1] - x[0]); 
dxdt[1] = R * x[0] - x[1] - x[0] * x[2]; 
dxdt[2] = -b * x[2] + x[0] * x[1]; 
' # Lorenz.sys 
cat(JacobianCpp(Lorenz.sys)) 
compile_implicit("lorenz", Lorenz.sys, pars, TRUE)

Lorenz_sim<- function(x0){
  
  state <- c(x0[1],
             x0[2],
             x0[3])
  
  out = as.data.frame(lorenz(state, 100, 0.003))
  
}

state <- t(replicate(5, sample(1:100,size=3), simplify="array")) # initial conditions are now in line
n_init <- seq(1,dim(state)[1], by = 1)
rownames(state) <- paste(n_init) # give an index to initial condition for each line

list_out <- apply(state, 1, Lorenz_sim)
data_out <- do.call(rbind, lapply(names(list_out), 
                                function(x) data.frame(list_out[[x]], x, stringsAsFactors = FALSE)))
data_out[,5] <- as.numeric(data_out[,5])

out_1 <-list_out[[1]]

plot(out_1, upper.panel = NULL)
plot3d(out_1$X1, out_1$X2, out_1$X3)


## Let's try several 100  
#  different initial conditions
#  with apply function with parallel
#########################################

library(deSolve)
library(plotly)
library(parallel)
library(Rcpp)
library(odeintr)
library(lorenzcompiler)

# initiate parallel computing

no_cores <- detectCores() -1
cl <- makeCluster(no_cores)


# pars = c(sigma = 10, R = 28, b = 8/3) 
# Lorenz.sys = ' dxdt[0] = sigma * (x[1] - x[0]); 
# dxdt[1] = R * x[0] - x[1] - x[0] * x[2]; 
# dxdt[2] = -b * x[2] + x[0] * x[1]; 
# ' # Lorenz.sys 
# cat(JacobianCpp(Lorenz.sys)) 
# compile_implicit("lorenz", Lorenz.sys, pars, TRUE)

lorenzcompile() # a shortcut for the above code

Lorenz_sim<- function(x0){

  state <- c(x0[1],
             x0[2],
             x0[3])

  out = as.data.frame(lorenz(state, 100, 0.003))

}

state <- replicate(100, sample(1:100,size=3), simplify="array") 
names(state) <- NULL

# export all previous variables to each R process belonging to the cluster

clusterEvalQ(cl, library(lorenzcompiler))
clusterEvalQ(cl, library(parallel))
clusterEvalQ(cl, lorenzcompile())
clusterExport(cl, varlist=c("lorenz"))

list_out <- parApply(cl, state, 2, Lorenz_sim)
out_1 <-list_out[[1]]

stopCluster(cl)
