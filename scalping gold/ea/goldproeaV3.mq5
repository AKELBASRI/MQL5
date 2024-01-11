#property strict
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
CPositionInfo  m_position;                   // object of CPositionInfo class
CTrade   Trade;  
CSymbolInfo m_symbol;
#include <Trade\DealInfo.mqh>
//---
CDealInfo      m_deal;   
bool dayTrading[] = {true,true,true,true,true,false,true};
input bool     InpPrintLog ;
// Declare global variables for the arrays
double resistance[];
double supports[];
int handler;
string LondonTimeStart="08:00";
string LondonTimeEnd="18:00";
input double risk=0.5;
string nameindicator = "indicatorgoldpro";
bool RefreshRates()
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      if(InpPrintLog)
         Print(__FILE__," ",__FUNCTION__,", ERROR: ","RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
     {
      if(InpPrintLog)
         Print(__FILE__," ",__FUNCTION__,", ERROR: ","Ask == 0.0 OR Bid == 0.0");
      return(false);
     }
//---
   return(true);
  }
double calcLots(double riskPercent,double slDistance)
  {
  double ticksize=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
  double tickvalue=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
  double lotstep=SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   if(ticksize==0 || tickvalue==0 || lotstep==0){
      Print(__FUNCTION__,"< Lotsize cannot ve calculated...");
      return 0;
   }
    double riskMoney=AccountInfoDouble(ACCOUNT_BALANCE)*riskPercent/100;
    double moneyLotstep=(slDistance/ticksize)*tickvalue*lotstep;
    if(moneyLotstep==0){  
       Print(__FUNCTION__,"> Lotsize cannot be calculated ...");return 0;}
       double lots =MathFloor(riskMoney/moneyLotstep)*lotstep;
       return lots;
    
   }
// Expert initialization function
int OnInit()
{
   RefreshRates();
   //Trade.SetExpertMagicNumber(magicnumber);
   Trade.SetMarginMode();
   Trade.SetTypeFillingBySymbol(m_symbol.Name());
   ArraySetAsSeries(supports,false);
   ArraySetAsSeries(resistance,false);
 
   handler = iCustom(Symbol(), PERIOD_CURRENT, nameindicator);
   
 
   return(INIT_SUCCEEDED);
}
 double Ask()
  {
   return (SymbolInfoDouble(Symbol(), SYMBOL_ASK));
  }
 double Bid(){
   return (SymbolInfoDouble(Symbol(),SYMBOL_BID));
  }

double savebuylevel;
double saveselllevel;
bool sellstate=false;
bool buystate=false;
static datetime timeday=0;

// Expert tick function
void sell(double &suppres,double &savedsupres,bool &sellstat,int &i){
    if (suppres > 0 && iClose(Symbol(),PERIOD_M5,2)<suppres
    && iOpen(Symbol(),PERIOD_M5,2)>suppres
     
      && iClose(Symbol(),PERIOD_M5,2)<iOpen(Symbol(),PERIOD_M5,2) &&
     iOpen(Symbol(),PERIOD_M5,2)-iHigh(Symbol(),PERIOD_M5,2)>0
      && !sellstat
    ){
      // close below set sell bool to true;
      // save support
      sellstat=true;
      savedsupres=suppres;
    }
     if (sellstat&&savedsupres > 0 && (iClose(Symbol(),PERIOD_M5,2)>savedsupres
   // && iHigh(Symbol(),PERIOD_M5,2)>savedsupres
     ||
     iOpen(Symbol(),PERIOD_M5,2)-iHigh(Symbol(),PERIOD_M5,2)<=0)

    ){
      // close above set sell bool to false;
      sellstat=false;
      savedsupres=0;
    }
    if(sellstat&&  iClose(Symbol(),PERIOD_M5,1)<savedsupres
   &&savedsupres>0
     &&!onetime
    && iHigh(Symbol(),PERIOD_M5,1)>=savedsupres){
    
    double entrysell=Bid();
    double slSell=iHigh(Symbol(),PERIOD_M5,1)+(Ask()-Bid());
    double sldistance=slSell-entrysell;
    Print(sldistance);
    if(sldistance<=1.92){
       double TpSell=entrysell-2.0*(slSell-entrysell);
       //if(slhit) TpSell=entrysell-3.0*(slSell-entrysell);
       if(Trade.Sell(calcLots(risk,slSell-entrysell),Symbol(),entrysell,slSell,NormalizeDouble(TpSell+(Ask()-Bid()),Digits()))){
                  Print("sell");
                  Print("supports["+i+"]: ", savedsupres);
                  savedsupres=0;
                  sellstat=false;
                
         }   
        
         
       }
      }
}
bool slhit=false;
void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
  {
//--- get transaction type as enumeration value
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      if(HistoryDealSelect(trans.deal))
         m_deal.Ticket(trans.deal);
      else
        {
         Print(__FILE__," ",__FUNCTION__,", ERROR: HistoryDealSelect(",trans.deal,")");
         return;
        }
      //---
      long reason=-1;
      if(!m_deal.InfoInteger(DEAL_REASON,reason))
        {
         Print(__FILE__," ",__FUNCTION__,", ERROR: InfoInteger(DEAL_REASON,reason)");
         return;
        }
      if((ENUM_DEAL_REASON)reason==DEAL_REASON_SL){
         slhit=true;
         onetime=false;
         }
      else{
         if((ENUM_DEAL_REASON)reason==DEAL_REASON_TP){
             slhit=false;
             onetime=true;
         }
      }     
     }
  }
void buy(double &suppres,double &savedsupres,bool &buystat,int &i){

    if (suppres > 0 
    &&iClose(Symbol(),PERIOD_M5,2)>suppres
    && iOpen(Symbol(),PERIOD_M5,2)<suppres
     && iClose(Symbol(),PERIOD_M5,2)>iOpen(Symbol(),PERIOD_M5,2)
    &&
     iOpen(Symbol(),PERIOD_M5,2)-iLow(Symbol(),PERIOD_M5,2)>0
      && !buystat
    ){
     
      buystat=true;
      savedsupres=suppres;
    }
     if (buystat&&savedsupres > 0 && (
     iClose(Symbol(),PERIOD_M5,2)<savedsupres
    
     ||
      iOpen(Symbol(),PERIOD_M5,2)-iLow(Symbol(),PERIOD_M5,2)<=0)
    ){
      // close above set sell bool to false;
      buystat=false;
      savedsupres=0;
    }
    if(buystat&& 
    savedsupres>0
     
    && iLow(Symbol(),PERIOD_M5,1)<=savedsupres
    && iClose(Symbol(),PERIOD_M5,1)>savedsupres
      &&!onetime
    ){
   double entrybuy=Ask();
   double slBuy=iLow(Symbol(),PERIOD_M5,1)-(Ask()-Bid());
   
   double sldistance=entrybuy-slBuy;
   Print(sldistance);
   if(sldistance<=1.92){
      double TpBuy=entrybuy+2.0*(entrybuy-slBuy)+(Ask()-Bid());
      //if(slhit) TpBuy=entrybuy+3.0*(entrybuy-slBuy)+(Ask()-Bid());
     if(Trade.Buy(calcLots(risk,entrybuy-slBuy),Symbol(),entrybuy,NormalizeDouble(slBuy,Digits()),NormalizeDouble(TpBuy-(Ask()-Bid()),Digits())))
      
      {
         Print("buy");
        
         savedsupres=0;
         buystat=false;
         
      }
        
        } 
    }

}
bool onetime;
void OnTick()
{
   if(PositionsTotal()>=1) return;
   ArrayFree(resistance);
   ArrayFree(supports);
   if (timeday!=iTime(_Symbol,PERIOD_D1,0))
   {
      onetime=false;
      timeday=iTime(_Symbol,PERIOD_D1,0);
   }
   datetime time0=iTime(Symbol(),PERIOD_H1,0);
  
   string sstartdatetime=TimeToString (time0, TIME_DATE)+" "+LondonTimeStart;
   datetime dstartdatetime=StringToTime(sstartdatetime);
   string senddatetime=TimeToString (time0, TIME_DATE)+" "+LondonTimeEnd;
   datetime denddatetime=StringToTime(senddatetime);
   
   CopyBuffer(handler,1, 0,1000, supports);
   CopyBuffer(handler, 0, 0,1000,resistance);
   if(dstartdatetime<time0&& denddatetime>=time0 ){
   for(int i=0;i<1000;i++){
         
      sell(supports[i],saveselllevel,sellstate,i);
      
      buy(resistance[i],savebuylevel,buystate,i);
    
     
    }  
         
      
//---  
      }
}
