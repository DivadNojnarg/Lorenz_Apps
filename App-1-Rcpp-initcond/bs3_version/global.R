# load packages
library(shiny)
library(plotly)
library(odeintr)
library(ygdashboard)
library(shinyjs)
library(shinycssloaders)
library(shinyFeedback)
library(parallel)
library(RxODE)
library(shinyWidgets)
library(bsplus)
library(stringr)

# Load the template components
source("header.R")
source("sidebar.R")
source("body.R")
source("dashboardControlbar.R")

# Define the model equations with Rcpp
pars = c(a = 10, b = 8/3, c = 28) 
Lorenz.sys = ' dxdt[0] = a * (x[1] - x[0]); 
dxdt[1] = c * x[0] - x[1] - x[0] * x[2]; 
dxdt[2] = -b * x[2] + x[0] * x[1]; 
' # Lorenz.sys C++
#cat(JacobianCpp(Lorenz.sys))
#compile_sys("lorenz", Lorenz.sys, pars, const = TRUE) 
compile_sys("lorenz", Lorenz.sys, pars, const = TRUE) 

# Define the model with RxODE
lorenz_RxODE <- "
  d/dt(x1) = k1 * (x2 - x1);
  d/dt(x2) = k2 * x1 - x2 - x1 * x3;
  d/dt(x3) = k3 * x3 + x1 * x2;
"
mod1 <- RxODE(model = lorenz_RxODE, modName = "lorenz_RxODE", 
              wd = getwd(), do.compile = TRUE)
theta <- c(k1 = 10, k2 = 28, k3 = -8/3)
ev1 <- eventTable()

# Function that extracts all reset inputs.
# Takes input as argument and returns
# a vector of reset buttons
extract_reset_inputs <- function(input) {
  inputs <- names(reactiveValuesToList(input))
  inputs <- unlist(inputs)
  reset_inputs <- lapply(seq_along(inputs), FUN = function(i) {
    if (str_detect(inputs[[i]], "^reset_\\w+") == TRUE)  inputs[[i]]
  })
  # remove NULL elements
  reset_inputs <- unlist(reset_inputs[!unlist(lapply(reset_inputs, is.null))])
  return(reset_inputs)
}
