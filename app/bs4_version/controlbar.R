#-------------------------------------------------------------------------
#  This code contains the controlsidebar of shinydashboard. It is the
#  sidebar available on the left. Parameters are put in this sidebar.
#  Sliders are handled via a conditionalPanel, but this can be disable
#
#  David Granjon, the Interface Group, Zurich
#  December 4th, 2017
#-------------------------------------------------------------------------
controlbar <- bs4DashControlbar(
  skin = "light",
  title = "Solver Settings",
  solverInputUi(id = "solver_inputs")
)

# add an id arg to reset the controlbar input with shinyjs
# we act on the second element since the first contains
# javascript code
controlbar[[2]] <- tagAppendAttributes(controlbar[[2]], id = "controlbar")
