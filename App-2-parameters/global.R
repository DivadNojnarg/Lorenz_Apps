# load useful packages
library(shiny)
library(plotly)
library(deSolve)
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