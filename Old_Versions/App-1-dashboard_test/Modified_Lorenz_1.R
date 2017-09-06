Modified_Lorenz_1<-function(t, state, parameters) {
  with(as.list(c(state, parameters)),{
    # rate of change
    dX<-a*(Y-X)
    dY<-X*(c-Y) - Z
    dZ<- X*Z - b*Z
    # return the rate of change
    list(c(dX, dY, dZ))
  })
}

state <- c(X = 1,
           Y = 1,
           Z = 1)

times <- seq(0,100, by = 0.01)