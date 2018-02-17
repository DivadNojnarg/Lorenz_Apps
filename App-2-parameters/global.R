# load useful packages
library(shiny)
library(plotly)
library(deSolve)
library(RxODE)
library(ygdashboard)
library(bsplus)
library(shinyjs)
library(shinycssloaders)
library(shinyWidgets)
library(shinyFeedback)

# Load the template components
source("header.R")
source("sidebar.R")
source("body.R")
source("helpers.R")
source("dashboardControlbar.R")

# Define the model equations
Lorenz <- function(t, state, parameters) {
  with(as.list(c(state, parameters)),{
    dX <- a * (Y - X)
    dY <- X * (c - Z) - Y
    dZ <- X * Y - b * Z
    list(c(dX, dY, dZ))
  })
}

# compilation if needed with RxODE
lorenz_RxODE <- "
   d/dt(X) = a * (Y - X);
   d/dt(Y) = X * (c - Z) - Y;
   d/dt(Z) = X * Y - b * Z;
"
mod1 <- RxODE(model = lorenz_RxODE, modName = "lorenz_RxODE", 
              wd = getwd(), do.compile = TRUE)
ev1 <- eventTable()