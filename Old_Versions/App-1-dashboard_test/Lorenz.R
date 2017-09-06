# Define the model equations

Lorenz<-function(t, state, parameters) {
  with(as.list(c(state, parameters)),{
    # rate of change
    dX<-a*(Y-X)
    dY<-X*(c-Z) - Y
    dZ<- X*Y - b*Z
    # return the rate of change
    list(c(dX, dY, dZ))
  })
}