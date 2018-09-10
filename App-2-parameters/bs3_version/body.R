body <- dashboardBody(
  useShinyjs(),
  withMathJax(),
  useShinyFeedback(),
  
  tabItems(
    tabItem(
      tabName = "datas",
      fluidRow(
        box(
          title = tagList(shiny::icon("table"), "Table"), 
          width = 12,
          collapsible = T, 
          solidHeader = TRUE, 
          downloadButton(
            outputId = "downloadData", 
            label = " Download Table"
          ),
          withSpinner(
            dataTableOutput("table"), 
            size = 2, 
            type = 8, 
            color = "#000000"
          )
        )
      )
    ),
    tabItem(
      tabName = "main",
      
      fluidRow(
        box(
          title = tagList(shiny::icon("area-chart"), "Graph 3D"), 
          width = 6, 
          collapsible = T, 
          solidHeader = TRUE, 
          withSpinner(
            plotlyOutput("plot2", height = 400), 
            size = 2, 
            type = 8, 
            color = "#000000"
          )
        ),
        box(
          title = tagList(shiny::icon("area-chart"), "Phase Plane"),
          width = 6, 
          collapsible = T, 
          solidHeader = TRUE,
          withSpinner(
            plotlyOutput("plot3", height = 400), 
            size = 2, type = 8, color = "#000000"
          )
        )
      ),
      fluidRow(
        box(
          title = tagList(shiny::icon("line-chart"), "Time Series"), 
          width = 6, 
          collapsible = T, 
          solidHeader = TRUE,
          withSpinner(
            plotlyOutput("plot1", height = 400), 
            size = 2, type = 8, color = "#000000"
          )
        )
      )
    ),
    tabItem(
      tabName = "info",
      box(
        title = tagList(shiny::icon("info"), "Infos"), 
        width = 12, 
        collapsible = T, 
        solidHeader = TRUE,
        p("In this app you can:"),
        tags$ol(
          tags$li("Change parameter values"), 
          tags$li("Choose initial conditions"),
          tags$li("Change solver options"),
          tags$li("Display phase plane projections (X vs Y, X vs Z or Y vs Z)"),
          tags$li("More features will come soon!")
        ),
        
        p("These are the equations behind the Lorenz model"),
        p(withMathJax("$$\\left\\{
                      \\begin{align}
                      \\frac{dX}{dt} & = a(Y-X),\\\\
                      \\frac{dY}{dt} & = X(c-Z) - Y,\\\\
                      \\frac{dZ}{dt} & = XY - bZ,
                      \\end{align}
                      \\right.$$")),
        
        
        p("where \\(a\\) is the Prandtl number. See my previous App for further", 
          a("explanations.", href = "http://130.60.24.205/Lorenz_init/")),
        
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
        
      )
    ),
    tabItem(
      tabName = "analysis",
      fluidRow(
        box(
          title = tagList(shiny::icon("superscript"), "Stability"), 
          width = 6, 
          collapsible = T, 
          solidHeader = TRUE,
          
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
        box(
          title = tagList(shiny::icon("superscript"), "Bifurcations"), 
          width = 6, 
          collapsible = T, 
          solidHeader = TRUE,
          infoBoxOutput("hopf", width = 6),
          infoBoxOutput("pitchfork", width = 6),
          br(),
          p("A super-critical pitchfork bifurcation occurs depending on the value of c. 
            If \\(0<c\\leq 1\\), there is only \\(\\Big(0,0,0\\Big)\\) which is stable. 
            If \\(c >1\\), there are 3 equilibrium points as shown in the second box. The two
            symetric points are then stable. Furthermore, a Hopf-bifurcation is expected 
            when \\(c = a\\frac{a+b+3}{a-b-1}\\) and chaotic behavior happens when 
            \\(c > a\\frac{a+b+3}{a-b-1}\\). See more", 
            em(a("here.", href = "http://www.emba.uvm.edu/~jxyang/teaching/Math266notes13.pdf")))
        )
      )
    )
  )
)