#-------------------------------------------------------------------------
#  This code contains the controlsidebar of shinydashboard. It is the
#  sidebar available on the left. Parameters are put in this sidebar.
#  Sliders are handled via a conditionalPanel, but this can be disable
#
#  David Granjon, the Interface Group, Zurich
#  December 4th, 2017
#-------------------------------------------------------------------------
dashboardControlbar <- function(ctrlHTML = NULL) {
  
  if ( is.null(ctrlHTML) ) {
    
    HTML(paste0(
      '<!-- Control Sidebar -->
      <aside class="control-sidebar control-sidebar-dark">
      <!-- Create the tabs -->
      <ul class="nav nav-tabs nav-justified control-sidebar-tabs">
      <li class="active"><a href="#control-sidebar-home-tab" data-toggle="tab"><i class="fa fa-sliders"></i></a></li>
      <li><a href="#control-sidebar-parms-tab" data-toggle="tab"><i class="fa fa-desktop"></i></a></li>
      <li><a href="#control-sidebar-settings-tab" data-toggle="tab"><i class="fa fa-paint-brush"></i></a></li>
      </ul>
      
      <!-- Tab panes -->
      <div class="tab-content">
      <!-- Home tab content -->
      <div class="tab-pane active" id="control-sidebar-home-tab">
      <h3 class="control-sidebar-heading">Sliders</h3>
      
      <div class="form-group shiny-input-container">
        <label class="control-label" for="a">Value of a:</label>
      <input class="js-range-slider" id="a" data-min="0" data-max="20" data-from="10" data-step="1" data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-keyboard="true" data-keyboard-step="5" data-data-type="number"/>
      </div>
      
      <div class="form-group shiny-input-container">
      <label class="control-label" for="b">Value of b:</label>
      <input class="js-range-slider" id="b" data-min="0" data-max="10" data-from="3" data-step="1" data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-keyboard="true" data-keyboard-step="10" data-data-type="number"/>
      </div>
      
      <div class="form-group shiny-input-container">
      <label class="control-label" for="c">Value of c:</label>
      <input class="js-range-slider" id="c" data-min="0" data-max="100" data-from="28" data-step="1" data-grid="true" data-grid-num="10" data-grid-snap="false" data-prettify-separator="," data-prettify-enabled="true" data-keyboard="true" data-keyboard-step="1" data-data-type="number"/>
      </div>
      
      <!-- /.control-sidebar-menu -->
      </div>
      <!-- /.tab-pane -->
      
      <!-- Phase Plane options -->
      <div class="tab-pane" id="control-sidebar-stats-tab">Stats Tab Content</div>
      <!-- /.tab-pane -->
      <!-- Settings tab content -->
      <div class="tab-pane" id="control-sidebar-parms-tab">
      <h3 class="control-sidebar-heading">Phase Plan options</h3> 
      
      <div class="form-group shiny-input-container">
        <label class="control-label" for="xvar">X axis variable:</label>
      <div>
      <select id="xvar"><option value="X" selected>X</option>
      <option value="Y">Y</option>
      <option value="Z">Z</option></select>
      <script type="application/json" data-for="xvar" data-nonempty="">{}</script>
      </div>
      </div>
      
      <div class="form-group shiny-input-container">
      <label class="control-label" for="yvar">Y axis variable:</label>
      <div>
      <select id="yvar"><option value="Y" selected>Y</option>
      <option value="X">X</option>
      <option value="Z">Z</option></select>
      <script type="application/json" data-for="yvar" data-nonempty="">{}</script>
      </div>
      </div>
      </div>
      <!-- /.Phase Plane options -->
      
      
     <!-- Interface customization -->
      <div class="tab-pane" id="control-sidebar-stats-tab">Stats Tab Content</div>
      <!-- /.tab-pane -->
      <!-- Settings tab content -->
      <div class="tab-pane" id="control-sidebar-settings-tab">
      <h3 class="control-sidebar-heading">Other Options</h3>
      
      <!-- Select input -->
      <div data-step="7" data-intro="Here you can change the global &lt;b&gt;theme&lt;/b&gt; &#10;of the dashboard" data-position="left">
      <div data-step="7" data-intro="Here you can change the global &lt;b&gt;theme&lt;/b&gt; &#10;of the dashboard" data-position="left">
      <div class="form-group shiny-input-container">
      <label class="control-label" for="skin">Select a skin:</label>
      <div>
      <select id="skin"><option value="blue">blue</option>
      <option value="black" selected>black</option>
      <option value="purple">purple</option>
      <option value="green">green</option>
      <option value="red">red</option>
      <option value="yellow">yellow</option>
      </select>
      <script type="application/json" data-for="skin" data-nonempty="">{}</script>
      </div>
      </div>
      </div>
      
      
      
      </div>
      <!-- /.interface customization -->
      </div>
      </aside>
      <!-- /.control-sidebar -->
      <!-- Add the sidebar"s background. This div must be placed
      immediately after the control sidebar -->
      <div class="control-sidebar-bg"></div>
      '))
    
  } else {
    
    ctrlHTML
    
  }
}
