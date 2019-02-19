body <- bs4DashBody(
  useShinyjs(),
  withMathJax(),
  useShinyFeedback(),
  
  # load custom javascript
  includeScript(path = "www/js/find-navigator.js"),
  
  # unleash shinyEffects
  setZoom(class = "info-box", scale = 1.02),
  # unleash shinyWidgets
  chooseSliderSkin(skin = "Flat"),
  
  bs4TabItems(
    bs4TabItem(
      tabName = "main",
      stabilityUi(id = "stability"),
      # plots
      fluidRow(
        bs4TabCard(
          elevation = 4, 
          width = 12,
          side = "right",
          title = tagList(tagList(shiny::icon("area-chart"), "Outputs")),
          bs4TabPanel(
            tabName = "Graph 3D", 
            active = TRUE,
            withSpinner(
              plotlyOutput("plot2", height = 500), 
              size = 2, 
              type = 8, 
              color = "#000000"
            ),
            computeLorenzUi(id = "compute")
          ),
          bs4TabPanel(
            tabName = "Phase Plane", 
            fluidRow(
              column(
                width = 12,
                align = "center",
                withSpinner(
                  plotlyOutput("plot3", height = 400, width = "80%"), 
                  size = 2, type = 8, color = "#000000"
                )
              )
            ),
            tagAppendAttributes(
              fluidRow(
                column(
                  width = 6,
                  align = "center",
                  prettyRadioButtons(
                    shape = "square",
                    inputId = "xvar",
                    animation = "pulse",
                    choices = c("X", "Y", "Z"),
                    selected = "X",
                    status = "primary",
                    label = "X axis variable",
                    inline = TRUE
                  ) 
                ),
                column(
                  width = 6,
                  align = "center",
                  prettyRadioButtons(
                    shape = "square",
                    inputId = "yvar",
                    animation = "pulse",
                    choices = c("X", "Y", "Z"),
                    selected = "Y",
                    status = "primary",
                    label = "Y axis variable",
                    inline = TRUE
                  ) 
                )
              ),
              id = "phase_plot"
            )
          ),
          bs4TabPanel(
            tabName = "Time Series",
            withSpinner(
              plotlyOutput("plot1", height = 400), 
              size = 2, 
              type = 8, 
              color = "#000000"
            )
          )
        )
      )
    ),
    bs4TabItem(
      tabName = "datas",
      dataTableUi(id = "datatable")
    ),
    bs4TabItem(
      tabName = "analysis",
      bs4TabCard(
        elevation = 4, 
        width = 12,
        side = "right",
        title = tagList(shiny::icon("info"), "Infos"),
        bs4TabPanel(
          tabName = "About", 
          active = TRUE,
          
          bs4Accordion(
            id = "info_accordion",
            bs4AccordionItem(
              id = "app_tour",
              title = "App Tour", 
              status = "primary",
              p("In this app you can:"),
              tags$ol(
                tags$li("Change parameter values"), 
                tags$li("Choose initial conditions"),
                tags$li("Change solver options"),
                tags$li("Display phase plane projections (X vs Y, X vs Z or Y vs Z)")
              )
            ),
            bs4AccordionItem(
              id = "equations",
              title = "Lorenz Equations", 
              status = "primary",
              p("These are the equations behind the Lorenz model"),
              p(withMathJax("$$\\left\\{
                      \\begin{align}
                      \\frac{dX}{dt} & = a(Y-X),\\\\
                      \\frac{dY}{dt} & = X(c-Z) - Y,\\\\
                      \\frac{dZ}{dt} & = XY - bZ,
                      \\end{align}
                      \\right.$$")),
              
              
              p("where \\(a\\) is the Prandtl number. See my previous App for further", 
                a("explanations.", href = "http://130.60.24.205/Lorenz_init/"))
            ),
            bs4AccordionItem(
              id = "steady_state",
              title = "Steady State Conditions", 
              status = "primary",
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
          )
        ),
        bs4TabPanel(
          tabName = "Stability", 
          active = FALSE,
          h3(shiny::icon("superscript"), "Stability"),
          br(),
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
          p("The characteristic equation is:"),
          p("$$
            \\begin{align}
            \\lambda^3 + \\lambda^2(1+a+b) + \\lambda(a+ab+b-ac+X^2+aZ) + ab(1-c+Z) + aX(X+Y) = 0 
            \\end{align}.$$"),
          p("Applying the Routh-Hurwitz criterion in \\(R^3\\), we see that 
            \\(\\Big(0,0,0\\Big)\\) is stable if and only if \\(c \\leq 1\\)."),
          elevation = 4
        ),
        bs4TabPanel(
          tabName = "Bifurcations", 
          active = FALSE,
          h3(shiny::icon("superscript"), "Bifurcations"),
          br(),
          bifurcationsUi(id = "bifurc"),
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