# load useful packages
library(shiny)
library(plotly)
library(deSolve)
library(rootSolve)
library(bs4Dash)
library(bsplus)
library(shinyjs)
library(shinycssloaders)
library(shinyWidgets)
library(shinyFeedback)
library(stringr)
library(shinyEffects)
library(rintrojs)

# source modules
source("solverInputsModule.R")
source("computeLorenzModule.R")
source("bifurcationsModule.R")
source("stabilityModule.R")
source("dataTableModule.R")

# Load the template components
source("navbar.R")
source("sidebar.R")
source("body.R")
source("controlbar.R")

# Define the model equations
Lorenz <- function(t, state, parameters) {
  with(as.list(c(state, parameters)),{
    dX <- a * (Y - X)
    dY <- X * (c - Z) - Y
    dZ <- X * Y - b * Z
    list(c(dX, dY, dZ))
  })
}

# Compile model
system("R CMD SHLIB Lorenz.c")
dyn.load(paste0("Lorenz", .Platform$dynlib.ext))