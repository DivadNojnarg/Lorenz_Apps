# load packages
library(shiny)
library(plotly)
library(Rcpp)
library(odeintr)
library(ygdashboard)
library(shinythemes)
library(shinyBS)
library(shinyjs)
library(shinycssloaders)
library(flexdashboard)

# Load the template components
source("header.R")
source("sidebar.R")
source("body.R")
source("dashboardControlbar.R")

# Define the model equations with Rcpp
pars = c(a = 10, b = 3, c = 28) 
Lorenz.sys = ' dxdt[0] = a * (x[1] - x[0]); 
dxdt[1] = c * x[0] - x[1] - x[0] * x[2]; 
dxdt[2] = -b * x[2] + x[0] * x[1]; 
' # Lorenz.sys C++
#cat(JacobianCpp(Lorenz.sys))
#compile_sys("lorenz", Lorenz.sys, pars, const = TRUE) 
compile_sys("lorenz", Lorenz.sys, pars, const = TRUE) 