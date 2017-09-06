library(shiny)
library(shinydashboard)
library(shinythemes)
library(plotly)
library(shinyBS)
library(shinyjs)
library(shinycssloaders)
library(flexdashboard)

# Load the template components

source("header.R")
source("sidebar.R")
source("body.R")
source("helpers.R")

# JS code for closing shiny app with a button

jscode <- "shinyjs.closeWindow = function() { window.close(); }"

# Define UI 
shinyUI(fluidPage(
  
  useShinyjs(),
  extendShinyjs(text = jscode, functions = c("closeWindow")),
  
  # Application theme
  theme = shinytheme("yeti"),
  #theme = "bootswatch-journal.css",
  #shinythemes::themeSelector(),
  
  # include a dashboard
  dashboardPage(skin = "black", header, sidebar, body)
  
))