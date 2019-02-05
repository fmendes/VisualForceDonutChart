# VisualForceDonutChart
Using VisualForce to create a SVG image containing a donut chart
VisualForce is used to generate HTML pages but it can also create other kinds of data. One common alternative is to render VisualForce as PDF. 

This article proposes a third type of data that can be generated via VisualForce:  images.

Scalable Vector Graphics is a graphics format that uses a markup language to describe the images. It is text-like just like HTML. While in HTML you can tell the browser to draw an input element or a paragraph and specify the border, colors, margins, in SVG you can tell the browser to draw rectangles, circles, polygons and other shapes.

In the example below, I've used a VisualForce page rendered as SVG to draw a donut chart:



The donut chart is an IMAGE formula field in the Property custom object. 

Usually the IMAGE function is used to display static images, such as red flags, say when an approval status is rejected:  IMAGE ( "/img/samples/flag_red.gif", "Red" ) 

This pushes the envelope a little further by invoking a VisualForce page with parameters to generate a image.

Here is how the formula for the donut chart is defined:

    IMAGE( '/apex/DonutChart?labels=Living Room,Dining Room,Master BR' 
     + ',Bedroom %232,Bedroom %233,Others&values='

     + TEXT( Living_Room__c ) + ',' + TEXT( Dining_Room__c ) 
     + ',' + TEXT( Master_Bedroom__c ) + ',' 
     + TEXT( Bedroom_2__c ) + ',' + TEXT( Bedroom_3__c ) + ',' 
     + TEXT( Square_Feet__c - Living_Room__c - Dining_Room__c 
            - Master_Bedroom__c - Bedroom_2__c - Bedroom_3__c )

     + '&number=' + TEXT( Square_Feet__c ) 

     + '&label=Square Feet' 

     , 'chart', 250, 250 )
The formula is invoking the VisualForce page named "DonutChart" and passing the following parameters:

* a comma-separated list of labels (Living Room, Dining Room, ...) to be printed at the perimeter of the donut and in the legend.
* a comma-separated list of values (Living_Room__c, Dining_Room__c, ...) in the same order as the corresponding labels. The values come from the fields of the Property__c object - the last value is a subtraction to obtain the remaining square footage.
* the number to be printed in the middle of the donut to indicate the total square feet of the property.
* the label to be printed in the middle of the donut just saying "Square Feet".
* and lastly, the normal parameters of the IMAGE function to indicate default size and alternative text.

It is relatively simple to use and you can add that donut chart field virtually anywhere:  below is the same field in a list and in a report detail.



Before going into the gobbledygook code here is a list with a few other ideas of how this mechanism could be used:

* print barcodes and QR codes
* expose charts to community users (as an alternative to the apex:chart tag)
* create custom mini-related lists to fit your page layout
* create custom map pins with any color or shape (otherwise you would have to create the  images for each combination - maybe hundreds - of pin colors and shapes and upload them as static resource)
* display a mini-map where each state has a different color according to the data
* display an organizational chart or a tree view of data
* create custom charts that are not available out of the box
* represent data in some non-conventional way using text, colors or shapes

Here is a summary of how the page was created:  

    <apex:page sidebar="false" showHeader="false" 
     controller="DonutChartController"
     applyHtmlTag="false" applyBodyTag="false" standardStylesheets="false" 
     ContentType="image/svg+xml" >
The header tells that the content type is in the SVG format. That tells the browser to follow the markup instructions contained in the VF page and display an image.

    <svg id="layer_1" xmlns="http://www.w3.org/2000/svg" 
       xmlns:xlink="http://www.w3.org/1999/xlink" 
       width="{! IF( $CurrentPage.parameters.chartWidth != null, $CurrentPage.parameters.chartWidth, '' )}" 
       height="100%" viewBox="-4 0 68 43" >

The SVG tag specifies the viewBox, which tells the coordinates of the image it should display and some other parameters such as "width" for convenience.

    <circle class="donut-hole" cx="21" cy="21" r="15.91549430918954" 
              fill="white" />
    <circle class="donut-ring" cx="21" cy="21" r="15.91549430918954" 
              fill="transparent" stroke="lightgray" stroke-width="7" />
              
The CIRCLE tags define the center, the radius and that the inside of the donut will be white and the contour thickness will be light gray by default (other colors will be added soon after).

    <apex:repeat var="i" value="{!indexList}">
      <circle id="segment{!i}" cx="21" cy="21" r="15.91549430918954" 
              fill="transparent" stroke-width="7" 
              stroke="{!colorList[ i -1 ]}"
              stroke-dasharray="{!percentList[ i -1 ]} {! 100 - percentList[ i -1 ] }" 
              stroke-dashoffset="{!offsetList[ i -1 ]}">
      </circle>
      <text class="chart-legend" color="white"
              x="{!labelXList[ i -1 ]}" y="{!labelYList[ i -1 ]}" >
            <tspan>{! IF( $CurrentPage.parameters.displayLabels != 'false', labelList[ i -1 ], '' )}</tspan>
            <tspan dy="1em"
                   dx="{! IF( $CurrentPage.parameters.displayLabels != 'false', '-2', '1.5' )}em" >{! IF( $CurrentPage.parameters.displayValues != 'false', valueList[ i -1 ], '' )}</tspan>
      </text>
    </apex:repeat>
    
The apex:repeat tag will generate colored circle segments for each of the label-value pairs specified as parameters of the VF page. I've followed the tricks from Mark Caron's article to implement the positioning of the segments according to the percentage of each value.

The apex:repeat tag will also print the labels near their respective segment (interestingly, there some trigonometry in the page controller for that).

    <apex:repeat var="i" value="{!indexList}">
        <g class="chart-text chart-legend chart-legend-box" >
            <rect x="44" y="{! i * 3 }" width="2" height="2" 
                  stroke="black" stroke-width="0.125" 
                  fill="{!colorList[ i -1 ]}" />
            <text x="46.5" y="{! 1.5 + i * 3 }" 
                   >{!labelList[ i -1 ]}</text>
        </g>
    </apex:repeat>
    
This second apex:repeat tag will cycle through the labels and create colored rectangles to display a legend.

    <g class="chart-main-text">
    <text x="21" y="21" class="chart-main-number">
      {! $CurrentPage.parameters.number }
    </text>
    <text x="21" y="23" class="chart-main-label">
      {! $CurrentPage.parameters.label }
    </text>
    </g>
    
This last tag is grouping the text to display at the center of the donut chart.

