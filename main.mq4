#include <stdlib.mqh>

// #include "./utils.mq4"
// #include "Connection.mqh"
// #include "Globals.mqh"
// #include "Include/JAson.mqh"
#include "Include/Zmq/Zmq.mqh"

// const string GIST_URL = "https://gist.githubusercontent.com/bigboiblue/cb668007714195333fd9a0c79a6946ee/raw/global_config.json";
// const string SYMBOL = Symbol();  // Just use current symbol for now
// const int PERIOD = PERIOD_M1;    // Using 1m period for now

// void sendData();

// int OnInit() {
//     if (setupGlobals() == -1) return -1;
//     EventSetMillisecondTimer(1);

//     return 0;
// }

// int setupGlobals() {
//     Globals *globals = Globals::getInstance();

//     // Send request to get global_config.json from gist
//     char reqBody[], response[];
//     string headers;

//     const int res = WebRequest("GET", GIST_URL, NULL, NULL, 5000, reqBody, 0, response, headers);
//     if (res == -1) {
//         Print("ERROR GETTING WEBREQUEST. ERROR: " + GetLastError());
//         return -1;
//     }

//     string configString = CharArrayToString(response);
//     CJAVal config = CJAVal();
//     config.Deserialize(configString);

//     globals.PUBLISHER_PORT = config["PUBLISHER_PORT"].ToInt();
//     globals.API_PORT = config["API_PORT"].ToInt();

//     Print("Setup complete. Publishing on port " + globals.PUBLISHER_PORT + " and listening on api port " + globals.API_PORT);

//     EventSetMillisecondTimer(1);

//     return 0;
// }

// void OnDeinit(const int reason) {
//     Globals::releaseInstance();
// }
// void handleSocketConnections();

// /**
//  * We can only get new data on a new tick, therefore we send new data on tick
//  */
// void OnTick() {
//     sendData();
// }

// void sendData() {
//     static datetime lastBarTime = datetime();
//     bool isNewBar = lastBarTime != iTime(SYMBOL, PERIOD, 0);
//     if (isNewBar) {
//         lastBarTime = iTime(SYMBOL, PERIOD, 0);

//         CJAVal ohlc;
//         ohlc["symbol"] = SYMBOL;
//         ohlc["time"] = TimeToString(iTime(SYMBOL, PERIOD, 1));
//         ohlc["open"] = iOpen(SYMBOL, PERIOD, 1);
//         ohlc["high"] = iHigh(SYMBOL, PERIOD, 1);
//         ohlc["low"] = iLow(SYMBOL, PERIOD, 1);
//         ohlc["close"] = iClose(SYMBOL, PERIOD, 1);
//         ohlc["volume"] = iVolume(SYMBOL, PERIOD, 1);

//         PrintFormat("Time: %s - Open: %.2f - High: %.2f - Low: %.2f - Close: %.2f - Volume: %i", ohlc["time"].ToStr(), ohlc["open"].ToDbl(), ohlc["high"].ToDbl(), ohlc["low"].ToDbl(), ohlc["close"].ToDbl(), ohlc["volume"].ToInt());

//         // TODO: Send ohlc over connection
//         ConnectionType connectionType = ConnectionType::PUB;
//         // Connection publisher(connectionType, Globals::getInstance().PUBLISHER_PORT);
//         Socket pub(Globals::getInstance().context, ZMQ_PUB);
//         pub.bind("tcp://*:25000");
//         pub.send(ZmqMsg("RLY BICH"));
//         // publisher.send(ohlc);
//     }
// }

// /** 
//  * Since we want to respond fast, we check for messages every millisecond using a timer
// */
// void OnTimer() {
//     // sendData();
// }


const string SYMBOL = Symbol();  // Just use current symbol for now
const int PERIOD = PERIOD_M1;    // Using 1m period for now

Context context();
Socket publisher(context, ZMQ_PUB);

int OnInit() {
    publisher.bind("tcp://*:25565");

    Print("Initialised publisher");
    
    return 0;
}

void OnTick() {
    static datetime lastBarTime = datetime();
    bool isNewBar = lastBarTime != iTime(SYMBOL, PERIOD, 0);
    if (isNewBar) {
        lastBarTime = iTime(SYMBOL, PERIOD, 0);
        string messageString = StringFormat("Message Time: %s", TimeToString(lastBarTime));
        Print(StringFormat("Sending message %s", messageString));
        ZmqMsg msg(messageString);
        publisher.send(msg);
    }
}