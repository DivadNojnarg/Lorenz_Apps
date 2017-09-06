body <- dashboardBody(
  fluidRow(
    tabBox(
      id = "boxinfo", title = tagList(shiny::icon("calendar"), "Infos"), width = 6,
      
      tabPanel(title = tagList(shiny::icon("info"), "About this App"),
        p("In this app you can:"),
        tags$ol(tags$li("Change parameter values"), 
           tags$li("Choose initial conditions"),
           tags$li("Change solver options"),
           tags$li("Display phase plane projections (X vs Y, X vs Z or Y vs Z)"),
           tags$li("More features will come soon!"))
      ),
      tabPanel(title = tagList(shiny::icon("superscript"), "Equations"), 
               p("These are the equations behind the Lorenz model"),
               p(withMathJax("$$\\left\\{
                             \\begin{align}
                             \\frac{dX}{dt} & = a(Y-X),\\\\
                             \\frac{dY}{dt} & = X(c-Z) - Y,\\\\
                             \\frac{dZ}{dt} & = XY - bZ,
                             \\end{align}
                             \\right.$$")),
               
               
               p("where \\(a\\) is the Prandtl number. See my previous App for further", 
                 a("explanations.", href = "https://dgranjon.shinyapps.io/lorenz_1_initialcond"))
      ),
      tabPanel(title = tagList(shiny::icon("superscript"), "Steady States"),
               p("At steady-state we know that:"),
               p("$$\\left\\{
                 \\begin{align}
                 \\frac{dX}{dt} & = 0,\\\\
                 \\frac{dY}{dt} & = 0,\\\\
                 \\frac{dZ}{dt} & = 0.
                 \\end{align}
                 \\right.$$"),
               p("This leads to 3 equilibrium points: \\(\\Big(0,0,0\\Big)\\), 
                 \\(\\Big(\\sqrt{b(c-1)},\\sqrt{b(c-1)}, c-1\\Big)\\) and 
                 \\(\\Big(-\\sqrt{b(c-1)},-\\sqrt{b(c-1)}, c-1\\Big)\\).")
      ),
      tabPanel(title = tagList(shiny::icon("superscript"), "Stability"),
               p("The jacobian matrix of the system is:"),
               p("$$
                 \\begin{align}
                 J^{\\ast} = 
                 \\begin{pmatrix}
                 -a & a & 0 \\\\
                 c-Z & -1 & -X \\\\
                 Y & X & -b
                 \\end{pmatrix}
                 \\end{align}$$"),
               p("Besides, to find the characteristic equation, we let:"),
               p("$$
                 \\begin{align}
                 det(J^{\\ast}- \\lambda I) = 0 \\Longleftrightarrow
                 \\begin{vmatrix}
                 -a-\\lambda & a & 0 \\\\
                 c-Z & -1-\\lambda & -X \\\\
                 Y & X & -b-\\lambda
                 \\end{vmatrix}
                 \\end{align} = 0.$$"),
               p("In \\(\\Big(0,0,0\\Big)\\) this gives:"),
               p("$$
                 \\begin{align}
                 \\lambda^3 + \\lambda^2(1+a+b) + \\lambda(a+ab+b-ac) + ab(1-c) = 0 
                 \\end{align}.$$"),
               p("Applying the Routh-Hurwitz criterion in \\(R^3\\), we see that 
                 \\(\\Big(0,0,0\\Big)\\) is stable if and only if \\(c \\leq 1\\).")
      ),
      tabPanel(title = tagList(shiny::icon("superscript"), "Bifurcations"),
               infoBoxOutput("hopf", width = 6),
               infoBoxOutput("pitchfork", width = 6),
               p("A super-critical pitchfork bifurcation occurs depending on the value of c. 
                  If \\(0<c\\leq 1\\), there is only \\(\\Big(0,0,0\\Big)\\) which is stable. 
                  If \\(c >1\\), there are 3 equilibrium points as shown in the second box. The two
                  symetric points are then stable. Furthermore, a Hopf-bifurcation is expected 
                  when \\(c = a\\frac{a+b+3}{a-b-1}\\) and chaotic behavior happens when 
                  \\(c > a\\frac{a+b+3}{a-b-1}\\). See more", 
                 em(a("here.", href = "http://www.emba.uvm.edu/~jxyang/teaching/Math266notes13.pdf")))
               
      )
      
    ),
    tabBox(
      title = tagList(shiny::icon("microchip"), "Results"), id = "tabset1", width = 6,
      
      tabPanel(title = tagList(shiny::icon("table"), "Table"), style="overflow-x: scroll;",
               downloadButton(outputId="downloadData", 
                              label=" Download Table"),
               withSpinner(dataTableOutput("table"), size = 2, type = 6, color = "#000000")
      ),
      tabPanel(title = tagList(shiny::icon("area-chart"), "Graph 3D"),
               withSpinner(plotlyOutput("plot2", height = 400), size = 2, type = 6, color = "#000000")
      ),
      tabPanel(title = tagList(shiny::icon("area-chart"), "Phase Plan"),
               withSpinner(plotlyOutput("plot3", height = 400), size = 2, type = 6, color = "#000000")
      ),
      tabPanel(title = tagList(shiny::icon("line-chart"), "Time Series"),
               withSpinner(plotlyOutput("plot1", height = 400), size = 2, type = 6, color = "#000000")
      )
    )
  ),
  fluidRow(
    box(
      id = "boxinput", # values to be reset if needed
      title = tagList(shiny::icon("gear"), "Control Center"), width = 12, collapsible = T, solidHeader = TRUE,
      style="height: 40vh; overflow-y: scroll; max-height: 400px;",
      
      column(3, align="center",
             h3(shiny::icon("eyedropper"), "Parameters"),
             br(),
             
             sliderInput("a",
                         "Value of a:",
                         min = 0,
                         max = 20,
                         value = 10),
             sliderInput("b",
                         "Value of b:",
                         min = 0,
                         max = 10,
                         value = 3),
             sliderInput("c",
                         "Value of c:",
                         min = 0,
                         max = 100,
                         value = 28)
             
      ),
      column(3, align="center",
             h3(shiny::icon("flask"), "Initial Conditions"),
             br(),
             numericInput("X0","Initial value of X0:", 1, min = 0, max = 100),
             numericInput("Y0","Initial value of Y0:", 1, min = 0, max = 100),
             numericInput("Z0","Initial value of Z0:", 1, min = 0, max = 100)
             
      ),
      column(3, align="center",
             h3(shiny::icon("cogs"), "Solver Options"),
             br(),
             numericInput("tmax","Value of tmax:", 100, min = 0, max = NA),
             numericInput("dt","Step of integration:", 0.01, min = 0, max = NA),
             selectInput("solver", "Choose a solver:", 
                         choices=c("lsoda", "lsode", "lsodes", "lsodar", "vode", "daspk",
                                   "euler", "rk4", "ode23", "ode45", "radau", 
                                   "bdf", "bdf_d", "adams", "impAdams", "impAdams_d")),
             sliderInput("rtol", label = "Relative tolerance", min = 1e-10, 
                         max = 1e-02, value = 1e-06),
             sliderInput("atol", label = "Absolute tolerance", min = 1e-10, 
                         max = 1e-02, value = 1e-06)
             
      ),
      
      column(3, align="center",
             h3(shiny::icon("desktop"), "Phase Plane Settings"),
             br(),
             selectInput("xvar", "X axis variable:", 
                         choices=c("X", "Y", "Z")),
             selectInput("yvar", "Y axis variable:", 
                         choices=c("X", "Y", "Z"))
             
      )
    )
  ),
  fluidRow(
    infoBoxOutput("sourceBox", width = 4),
    infoBoxOutput("progressBox", width = 4), 
    infoBoxOutput("nameBox", width = 4)
  )
  
)