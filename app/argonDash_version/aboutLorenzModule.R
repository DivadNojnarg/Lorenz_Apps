aboutLorenzUi <- function(id) {
  
  tagList(
    shiny::h1(shiny::icon("info"), "Infos"),
    
    argonTabSet(
      id = "tabInfo",
      card_wrapper = TRUE,
      horizontal = TRUE,
      circle = FALSE,
      size = "sm",
      width = 12,
      argonTab(
        tabName = "Equations", 
        active = TRUE,

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
        
        br(),
        
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
      argonTab(
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
      argonTab(
        tabName = "Bifurcations", 
        active = FALSE,
        h3(shiny::icon("superscript"), "Bifurcations"),
        br(),
        br(),
        p("A super-critical pitchfork bifurcation occurs depending on the value of c. 
            If \\(0<c\\leq 1\\), there is only \\(\\Big(0,0,0\\Big)\\) which is stable. 
            If \\(c >1\\), there are 3 equilibrium points as shown in the second box. The two
            symetric points are then stable. Furthermore, a Hopf-bifurcation is expected 
            when \\(c = a\\frac{a+b+3}{a-b-1}\\) and chaotic behavior happens when 
            \\(c > a\\frac{a+b+3}{a-b-1}\\). See more", 
          em(a("here.", href = "http://www.emba.uvm.edu/~jxyang/teaching/Math266notes13.pdf")))
      )
    ),
    
    br(),
    
    # Edward Lorenz Profile
    
    shiny::h1(shiny::icon("info"), "About the author"),
    
    argonProfile(
      title = "Edward Norton Lorenz",
      subtitle = "United States",
      src = "https://upload.wikimedia.org/wikipedia/en/thumb/d/dc/Edward_lorenz.jpg/180px-Edward_lorenz.svg",
      url = "https://www.google.com",
      url_1 = "https://en.wikipedia.org/wiki/Edward_Norton_Lorenz",
      stats = argonProfileStats(
        argonProfileStat(
          value = 22,
          description = "Friends"
        ),
        argonProfileStat(
          value = 10,
          description = "Photos"
        ),
        argonProfileStat(
          value = 89,
          description = "Comments"
        )
      ),
      "An artist of considerable range, Ryan — 
          the name taken by Melbourne-raised, 
          Brooklyn-based Nick Murphy — writes, 
          performs and records all of his own music, 
          giving it a warm, intimate feel with a solid 
          groove structure. An artist of considerable 
          range."
    )
    
  )
}



aboutLorenz <- function(input, output, session) {}