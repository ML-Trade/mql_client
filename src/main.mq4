#include <stdlib.mqh>

#include "./utils.mq4"
#include "./Connection.mqh"
#include "../Include/JAson.mqh"
#include "../Include/Zmq/Zmq.mqh"

/** GLOBALS **/
const string GIST_URL = "https://gist.githubusercontent.com/bigboiblue/cb668007714195333fd9a0c79a6946ee/raw/global_config.json";
const string SYMBOL = Symbol();  // Just use current symbol for now
const int PERIOD = PERIOD_M1;    // Using 1m period for now
double maxCloseSlippage = 0.01; // 1%
double maxOpenSlippage = 0.001; // 0.1%
Context *context;
Connection *publisher;
Connection *api;

void sendData();

int OnInit() {
    if (setupGlobals() == -1) return -1;
    EventSetMillisecondTimer(1);

    return 0;
}

int setupGlobals() {
    // Send request to get global_config.json from gist
    char reqBody[], response[];
    string headers;

    const int res = WebRequest("GET", GIST_URL, NULL, NULL, 5000, reqBody, 0, response, headers);
    if (res == -1) {
        Print("ERROR GETTING WEBREQUEST. ERROR: " + GetLastError());
        return -1;
    }

    string configString = CharArrayToString(response);
    CJAVal config = CJAVal();
    config.Deserialize(configString);

    const int PUBLISHER_PORT = config["PUBLISHER_PORT"].ToInt();
    const int API_PORT = config["API_PORT"].ToInt();

    context = new Context();
    ConnectionType pubConnectionType = ConnectionType::PUB;
    ConnectionType apiConnectionType = ConnectionType::REP;
    publisher = new Connection(context, pubConnectionType, PUBLISHER_PORT);
    api = new Connection(context, apiConnectionType, API_PORT);


    Print("Setup complete. Publishing on port " + PUBLISHER_PORT + " and listening on api port " + API_PORT);

    EventSetMillisecondTimer(1);

    return 0;
}

void OnDeinit(const int reason) {
    delete api;
    delete publisher;
    delete context;
}
void handleSocketConnections();

/**
 * We can only get new data on a new tick, therefore we send new data on tick
 */
void OnTick() {
    sendData();
    executeRecommendations();
}

void sendData() {
    static datetime lastBarTime = datetime();
    bool isNewBar = lastBarTime != iTime(SYMBOL, PERIOD, 0);
    if (isNewBar) {
        lastBarTime = iTime(SYMBOL, PERIOD, 0);

        CJAVal ohlc;
        ohlc["symbol"] = SYMBOL;
        ohlc["pip_size"] = MarketInfo(SYMBOL, MODE_TICKSIZE);
        ohlc["t"] = (double)iTime(SYMBOL, PERIOD, 1);
        ohlc["o"] = iOpen(SYMBOL, PERIOD, 1);
        ohlc["h"] = iHigh(SYMBOL, PERIOD, 1);
        ohlc["l"] = iLow(SYMBOL, PERIOD, 1);
        ohlc["c"] = iClose(SYMBOL, PERIOD, 1);
        ohlc["v"] = iVolume(SYMBOL, PERIOD, 1);


        publisher.send(ohlc);
        // PrintFormat("Time: %s - Open: %.2f - High: %.2f - Low: %.2f - Close: %.2f - Volume: %i", ohlc["time"].ToStr(), ohlc["open"].ToDbl(), ohlc["high"].ToDbl(), ohlc["low"].ToDbl(), ohlc["close"].ToDbl(), ohlc["volume"].ToInt());
        // Print(StringFormat("Sending OHLC Data from %s", TimeToStr(lastBarTime)));
    }
}

struct Actions {
    static string CONNECT, TRADE, HEALTHCHECK;
};
static string Actions::CONNECT = "CONNECT";
static string Actions::TRADE = "TRADE";
static string Actions::HEALTHCHECK = "HEALTHCHECK";

struct TradeActions {
    static string BUY, SELL, CLOSE;
};
static string TradeActions::BUY = "BUY";
static string TradeActions::SELL = "SELL";
static string TradeActions::CLOSE = "CLOSE";

struct TradeTypes {
    static string LIMIT, MARKET, STOP;
};
static string TradeTypes::LIMIT = "LIMIT";
static string TradeTypes::MARKET = "MARKET";
static string TradeTypes::STOP = "STOP";


/** Check for recommendations from the model over the zmq api connection **/
void executeRecommendations() {
    CJAVal response;
    
    bool noWait = true;
    CJAVal msg = api.receive(noWait);
    bool messageExists = msg["action"].ToBool();
    if (messageExists && msg["action"].ToStr() == Actions::TRADE) {
        PrintFormat("Recieved a message: %s", msg.Serialize());
        response["type"] = "TRADE";
        CJAVal options = msg["options"];
        string action = options["action"].ToStr();

        if (action == TradeActions::CLOSE) {
            int ticketId = options["ticket_id"].ToInt();
            double amount = 0.0;
            OrderSelect(ticketId, SELECT_BY_TICKET);

            if (options["amount"].ToBool()) amount = options["amount"].ToDbl();
            else amount = OrderLots();
            int orderType = OrderType();
            bool wasBuyOrder = orderType == OP_BUY || orderType == OP_BUYLIMIT || orderType == OP_BUYSTOP;
            int mode = (wasBuyOrder ? MODE_BID : MODE_ASK);
            double price = MarketInfo(SYMBOL, mode);
            int slippage = (int)MathRound((price / MarketInfo(SYMBOL, MODE_POINT)) * maxCloseSlippage);
            bool shouldTryTrade = true;
            while (shouldTryTrade) {
                OrderClose(ticketId, amount, price, slippage);
                if (ticketId == -1) shouldTryTrade = true;
                else shouldTryTrade = false;
            }
        } else { // We are opening a trade
            string type = options["type"].ToStr();
            double price = options["price"].ToDbl();
            double amount = options["amount"].ToDbl();
            // For no stop or take profit, these values should be 0
            double stop = options["stop"].ToDbl();
            double takeProfit = options["take_profit"].ToDbl(); 

            
            int operation = getOperationNumber(action, type);
            int mode = (action == TradeActions::BUY ? MODE_BID : MODE_ASK);
            
            if (type == TradeTypes::MARKET) price = MarketInfo(SYMBOL, mode);
            int slippage = (price / MarketInfo(SYMBOL, MODE_POINT)) * maxOpenSlippage; 

            bool shouldTryTrade = true;
            while (shouldTryTrade) {
                int ticketId = OrderSend(SYMBOL, operation, amount, price, slippage, stop, takeProfit);
                response["ticket_id"] = ticketId;
                if (ticketId == -1) shouldTryTrade = false;
                else shouldTryTrade = false;
            }
        }

    }
    if (messageExists) api.send(response);
}

int getOperationNumber(string action, string type) {
    if (action == TradeActions::BUY) {
        if (type == TradeTypes::LIMIT) return OP_BUYLIMIT;
        if (type == TradeTypes::MARKET) return OP_BUY;
        if (type == TradeTypes::STOP) return OP_BUYSTOP;
    } else if (action == TradeActions::SELL) {
        if (type == TradeTypes::LIMIT) return OP_SELLLIMIT;
        if (type == TradeTypes::MARKET) return OP_SELL;
        if (type == TradeTypes::STOP) return OP_SELLSTOP;
    }
    return -1;
}

/** 
 * Since we want to respond fast, we check for messages every millisecond using a timer
*/
void OnTimer() {
    // sendData();
}


// const string SYMBOL = Symbol();  // Just use current symbol for now
// const int PERIOD = PERIOD_M1;    // Using 1m period for now

// Context context();
// Socket publisher(context, ZMQ_PUB);

// int OnInit() {
//     publisher.bind("tcp://*:25000");

//     Print("Initialised publisher");
    
//     return 0;
// }

// void OnTick() {
//     static datetime lastBarTime = datetime();
//     bool isNewBar = lastBarTime != iTime(SYMBOL, PERIOD, 0);
//     if (isNewBar) {
//         lastBarTime = iTime(SYMBOL, PERIOD, 0);
//         string messageString = StringFormat("Message Time: %s", TimeToString(lastBarTime));
//         Print(StringFormat("Sending message %s", messageString));
//         ZmqMsg msg(messageString);
//         publisher.send(msg);
//     }
// }