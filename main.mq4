#include <stdlib.mqh>

#include "./utils.mq4"
#include "Connection.mqh"
#include "Globals.mqh"
#include "Include/JAson.mqh"
#include "Include/Zmq/Zmq.mqh"

const string GIST_URL = "https://gist.githubusercontent.com/bigboiblue/cb668007714195333fd9a0c79a6946ee/raw/global_config.json";

int OnInit() {
    if (setupGlobals() == -1) return -1;

    return 0;
}

int setupGlobals() {
    Globals *globals = Globals::getInstance();

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

    globals.PUBLISHER_PORT = config["PUBLISHER_PORT"].ToInt();
    globals.API_PORT = config["API_PORT"].ToInt();

    return 0;
}

void sendData();
void OnDeinit(const int reason) {
    Globals::releaseInstance();
}
void handleSocketConnections();
void OnTick() {}
void OnTimer() {}
