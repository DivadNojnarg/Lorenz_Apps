Modified_Lorenz_2<-function(t, state, parameters) {
  with(as.list(c(state, parameters)),{
    # rate of change
    dX<-a*(Z-X)
    dY<-Z*(c-Y) - X
    dZ<- Y*Z - b*X
    # return the rate of change
    list(c(dX, dY, dZ))
  })
}

state <- c(X = 1,
           Y = 1,
           Z = 1)

times <- seq(0,100, by = 0.01)