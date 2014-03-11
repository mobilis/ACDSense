ACDSense Sensor Client for iOS
========

**This version of the SensorClient is still capable of communicating with the ACDSenseService.
Checkout the master-branch if you want a client application only communicating to MUC rooms directly.**

## Dependencies ##
### Core-Plot ###
*Core-Plot* is a library used in the iOS application to display sensor values in a chart.
In order to use this library execute the following steps sequentially:  
1. Download the source code from [Google Code](https://code.google.com/p/core-plot/).  
2. Add the **CorePLot-CocoaTouch.xcodeproj** to your workspace  
3. Add **libCorePlot-CocoaTouch.a** as a required library in your ACDSense application dependencies.  
4. Add the *QuartzCoreFramework* as well to your ACDSence application depencies.  
5. You need to adjust the *Header Search Path* in your application's build settings.  
5.1 In Xcode > Open Settings > Locations > Source Trees  
5.2 Add a new environment variable and set the *Setting Name* to **CORE_PLOT**.  
5.3 Set the path to: core_plot_proj_root/Source/framework  
6. Select the target of the ACDSense application and go to the *Build Settings*  
7. For the *Header Search Path* add a new search path and enter **"$(CORE_PLOT)"**, set the search path as *recursive*. IMPORTANT: The quotation marks are intentional, do not omit them!  
8. Now you can import the *CorePlot-CocoaTouch.h* header file whereever you need it.