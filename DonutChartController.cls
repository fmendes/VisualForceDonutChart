public class DonutChartController {
    public List<Integer> indexList { get; set; }
    public List<String> colorList { get; set; }
    public List<Decimal> valueList { get; set; }
    public List<Decimal> percentList { get; set; }
    public List<Decimal> offsetList { get; set; }
    public List<String> labelList { get; set; }
    public List<Decimal> labelXList { get; set; }
    public List<Decimal> labelYList { get; set; }
    
    public DonutChartController() {
        indexList = new List<Integer>();
        List<String> colorPaletteList = new List<String> {
            'grey'
            , 'blue', 'red', 'orange'
            , 'yellow', 'yellowgreen', 'green'
            , 'cyan', 'lightblue', 'purple'
            , 'magenta','saddlebrown', 'pink'
            , 'peachpuff', 'beige', 'palegreen'
            , 'lavender', 'tan', 'olive'
            , 'teal' };
                
        colorList = new List<String>();
        valueList = new List<Decimal>();
        percentList = new List<Decimal>();
        offsetList = new List<Decimal>();
        labelList = new List<String>();
        labelXList = new List<Decimal>();
        labelYList = new List<Decimal>();
        
        // collect and separate list of labels and values
        String valuesParam = ApexPages.currentPage().getParameters().get( 'values' );
        String[] values = valuesParam.split( ',' );
        String labelsParam = ApexPages.currentPage().getParameters().get( 'labels' );
        labelList = new String[]{};
        if( labelsParam != null ) {
            labelList = labelsParam.split( ',' );
        }
        
        // assign labels, values (in place of percentages to be calculated)
        // and colors to each section
        // sum all values
        Decimal total = 0;
        Integer i = 1;
        for( String aValue : values ) {
            indexList.add( i );
            valueList.add( Decimal.valueOf( aValue ) );
            
            Integer colorIndex = Math.mod( i, 20 ) + Integer.valueOf( i / 20 );
            colorList.add( colorPaletteList[ colorIndex ] );
            
            percentList.add( Decimal.valueOf( aValue ) );
            
            String aLabel = aValue;
            if( i + 1 > labelList.size() ) {
                labelList.add( aLabel );
            }
            
            total = total + Decimal.valueOf( aValue );
            
            i++;
        }
        
        // calculate percentages and offsets
        Decimal runningTotalOffset = 0;
        Decimal runningAngle = 0;
        Decimal fullCircle = 2 * math.PI;
        for( Integer key = 1; key <= percentList.size(); key++ ) {
            Decimal value = percentList[ key -1 ];
            value = 100 * value / total;
            Decimal percent = value.setScale( 2 );
            percentList[ key -1 ] = value;
           
            Decimal offset = 100 - runningTotalOffset + 25;
            if( key == 1 ) {
                offset = 25;
            }
            offsetList.add( offset );
            
            // calculate position of label according to the section
            runningAngle = runningAngle + percent;
            Decimal angle = fullCircle * ( runningAngle - percent / 2 ) / 100;
            system.debug( labelList[ key ] + ' ' + angle );
            
            // reposition label further to the left if on the left side
            Decimal labelXposition = 21 + 20 * math.sin( angle );
            if( labelXposition < 21 ) {
                labelXposition = labelXposition - 5;
            }
            //else  {
            //    labelXposition = labelXposition + 5;
            //}
            
            labelXList.add( labelXposition );
            labelYList.add( 21 - 20 * math.cos( angle ) );
            
            runningTotalOffset = runningTotalOffset + percent;
        }
    }
}