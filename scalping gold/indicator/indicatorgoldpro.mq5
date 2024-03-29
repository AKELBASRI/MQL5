//+------------------------------------------------------------------+
//|                                             indicatorgoldpro.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 2
#property indicator_label1 "resistance"
#property indicator_color1 clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_type1 DRAW_ARROW

#property indicator_label2 "supports"
#property indicator_color2 clrBlue
#property indicator_style2 STYLE_SOLID
#property indicator_type2 DRAW_ARROW


double LOW[],HIGH[],CLOSE[],OPEN[];
double resistance[];
double supports[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
// Function to get the arrays and their sizes
int GetMaBuffer(double& resistanceBuffer[], double& supportsBuffer[], int& bufferSize) {
    // Copy the arrays to the provided buffers
    ArrayCopy(resistanceBuffer, resistance);
    ArrayCopy(supportsBuffer, supports);
    // Return the size of the arrays
    bufferSize = ArraySize(resistance);
    return bufferSize;
}
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,resistance,INDICATOR_CALCULATIONS);
   SetIndexBuffer(1,supports,INDICATOR_CALCULATIONS);
   
   SetIndexBuffer(2,LOW);
   SetIndexBuffer(3,HIGH);
   SetIndexBuffer(4,CLOSE);
   SetIndexBuffer(5,OPEN);
   ArraySetAsSeries(resistance,true);
   ArraySetAsSeries(supports,true);
   ArrayResize(supports, Bars(Symbol(),PERIOD_H1) - PERIOD_H1);
   ArrayResize(resistance, Bars(Symbol(),PERIOD_H1) - PERIOD_H1);
//---
   return(INIT_SUCCEEDED);
  }
void OnDeinit(int raison){
   ObjectsDeleteAll(0,"resistance1H");
   ObjectsDeleteAll(0,"support1H");
}
string LondonTimeStart="08:00";
string LondonTimeEnd="18:00";

bool onetime=false;
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

double maxHigh,minLow;
bool NewBar1H()
  {
  bool boolNewBarFlag=false;
  static datetime dtBarCurrent=WRONG_VALUE;
         datetime dtBarPrevious=dtBarCurrent;
                  dtBarCurrent=(datetime)SeriesInfoInteger(_Symbol,PERIOD_H1,SERIES_LASTBAR_DATE);
         
   return  (dtBarCurrent!=dtBarPrevious);              
 
  }
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
 // ArrayFree(resistance);
 // ArrayFree(supports);
//---
   //ObjectsDeleteAll(0,"resistance");
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(HIGH,true);
   ArraySetAsSeries(LOW,true);   
   ArraySetAsSeries(CLOSE,true);
   ArraySetAsSeries(OPEN,true);
   ArraySetAsSeries(resistance,true);
   ArraySetAsSeries(supports,true);
   MqlDateTime today;
   TimeCurrent(today);
   if(NewBar1H()){
   int limit = rates_total - prev_calculated;
   int j=0;
   int k=0;
   double highprice,lowprice;
   
   
   //ArrayResize(resistance,100);
   double maxHprice=0,minLprice=DBL_MAX;
   for (int i =500; i>=0;i--)
   {
   datetime time0=iTime(Symbol(),PERIOD_H1,i);
   datetime time1=iTime(Symbol(),PERIOD_H1,i+1);
   string sstartdatetime=TimeToString (time0, TIME_DATE)+" "+LondonTimeStart;
   datetime dstartdatetime=StringToTime(sstartdatetime);
   string senddatetime=TimeToString (time0, TIME_DATE)+" "+LondonTimeEnd;
   datetime denddatetime=StringToTime(senddatetime);
   
   int indiceprice1=iBarShift(Symbol(),PERIOD_H1,sstartdatetime);
   double p1=iClose(Symbol(),PERIOD_H1,indiceprice1);
   int indiceprice2=iBarShift(Symbol(),PERIOD_H1,denddatetime);
   double p2=iClose(Symbol(),PERIOD_H1,indiceprice2);
   
  
   
   if(denddatetime<=time0&&!onetime) {
      
      maxHprice=0; 
      minLprice=DBL_MAX;
    //  Print("minprice"+minLow + " "+sstartdatetime+ " "+ denddatetime);
     // Print("maxHprice"+maxHigh + " "+sstartdatetime+ " "+ denddatetime);
      
      //checkresistanceanddeleteit(resistance,minLow,supports,maxHigh);
     
      onetime=true;
      
   }
     if(denddatetime==time0){
      
      maxHigh=maxHprice;
      minLow=minLprice;
      
      onetime=false;
      //
    }
   if(dstartdatetime<time0&& denddatetime>=time0 ){
      if(k>0 || j>0){
       
         for(int i=0;i<ArraySize(resistance);i++){
         
         if(resistance[i]<p1&&p1>0){
            ObjectDelete(0,"resistance1H"+IntegerToString(i));
            ArrayRemove(resistance,i,1);
            //RemoveElementAtIndex(resistance,i);
         }      
       
      }
       for(int l=0;l<ArraySize(supports);l++){
           if(supports[l]>p1 && p1>0){
            ObjectDelete(0,"support1H"+IntegerToString(l));
            //RemoveElementAtIndex(supports,l);
            ArrayRemove(supports,l,1);
         }  
         
       
      }
     
      //int resistancedata=CopyRates(Symbol(),PERIOD_H1,0,j,resistance);
      //int supportsdata=CopyRates(Symbol(),PERIOD_H1,0,k,supports);
      }
      CopyHigh(Symbol(),PERIOD_H1,0,i,HIGH);
      CopyLow(Symbol(),PERIOD_H1,0,i,LOW);
      CopyClose(Symbol(),PERIOD_H1,0,i,CLOSE);
      CopyOpen(Symbol(),PERIOD_H1,0,i,OPEN);
     // Print( "open i+1 "+OPEN[i+1]+ " "+sstartdatetime+ " "+ denddatetime);
      //Print( "close i+1 "+CLOSE[i+1]+ " "+sstartdatetime+ " "+ denddatetime);
   
      if(maxHprice<HIGH[i+1]) {maxHprice=HIGH[i+1];}
    
      if(minLprice>LOW[i+1]){ minLprice=LOW[i+1];}
       //Print(lowprice);
          //Print(highprice);
         ObjectCreate(_Symbol,"LondonRect"+dstartdatetime,OBJ_RECTANGLE,0,dstartdatetime,maxHprice
         ,denddatetime,minLprice);
         ObjectSetInteger(0,"LondonRect"+dstartdatetime,OBJPROP_COLOR,clrBeige);
         ObjectSetInteger(0,"LondonRect"+dstartdatetime,OBJPROP_FILL,clrBeige);
        
       if( OPEN[i+1]>CLOSE[i+1] &&  OPEN[i+2]<CLOSE[i+2]){
         
            // resistance
            double level =OPEN[i+1];
            
            if(ArrayIsUnique(resistance,level)){
               //ArrayResize(resistance,j+1);
               resistance[j]=level;
               
               datetime currentBarTime = SymbolInfoInteger(_Symbol, SYMBOL_TIME);
             
               DrawLine("resistance1H"+IntegerToString(j),clrRed,time1,level,time0+PERIOD_H1*500,level);
              
               j++;
               
         }
       }
       if( OPEN[i+1]<CLOSE[i+1] &&  OPEN[i+2]>CLOSE[i+2]){
         
            // resistance
            double level =OPEN[i+1];
            
            if(ArrayIsUnique(supports,level)){
              // ArrayResize(supports,k+1);
               supports[k]=level;
               datetime currentBarTime = SymbolInfoInteger(_Symbol, SYMBOL_TIME);
             
               DrawLine("support1H"+IntegerToString(k),clrBlue,time1,level,time0+PERIOD_H1*500,level);
              
               k++;
            
         }
       }
   }
   //if(resistance[0]>0 || supports[0]>0)
     // checkresistanceanddeleteit(resistance,p1,supports);
    
   }
 
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
    void DrawSuppRes(int i,double &resistance[],int &j,double &supports[],int &k,datetime t1,
    datetime t2,double p1,double p2){
  
  
  }
  void RemoveElementAtIndex(double& array[], const int index)
{
    if (index >= 0 && index < ArraySize(array))
    {
        for (int i = index; i < ArraySize(array) - 1; ++i)
        {
            array[i] = array[i + 1];
        }

        ArrayResize(array, ArraySize(array) - 1);
    }
}
  void checkresistanceanddeleteit(double &resistance[],double &price1,double &supports[]){
      
      for(int i=0;i<resistance.Size();i++){
         
         if(resistance[i]<price1){
            ObjectDelete(0,"resistance1H"+IntegerToString(i));
            RemoveElementAtIndex(resistance,i);
         }      
       
      }
       for(int j=0;j<supports.Size();j++){
           if(supports[j]>price1){
            ObjectDelete(0,"support1H"+IntegerToString(j));
            RemoveElementAtIndex(supports,j);
         }  
       
      }

  }

//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="HLine",      // line name
                 const int             sub_window=0,      // subwindow index
                 double                price=0,           // line price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0)         // priority for mouse click
  {
//--- if the price is not set, set it at the current Bid price level
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- create a horizontal line
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
  }
  
  // Function to check if an array has a unique value at a specific index
bool ArrayIsUnique(const double& array[], double element)
{
   bool check=true;
    
    // Iterate through the array
    for (int i = 0; i < ArraySize(array);i++)
    {
        // Check if the element matches
        if (array[i]==element)
        {
            // Duplicate value found
            check=false;
        }
    }
   
   return check;
}
//+------------------------------------------------------------------+
//|                   Draw the Trend Line                            |
//+------------------------------------------------------------------+
void DrawLine(string name, color Clr, datetime t1, double p1, datetime t2, double p2)
   {
      //--- Searching if the object (Line in this case) is already created in the chart, if not, create it
      if((ObjectFind(0, name) < 0))
         ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2);
      //--- Set the properties of the said object(line).
      ObjectSetInteger(0, name, OBJPROP_COLOR, Clr);
      ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);   
   }