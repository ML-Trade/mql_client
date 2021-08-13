#include <stdlib.mqh>

#include "./utils.mq4"
#include "Connection.mqh"
#include "Include/JAson.mqh"
#include "Include/Zmq/Zmq.mqh"

const string GIST_URL = "https://gist.githubusercontent.com/bigboiblue/cb668007714195333fd9a0c79a6946ee/raw/global_config.json";

Context context;
int OnInit() {
    char reqBody[], response[];
    string headers;

    const int res = WebRequest("GET", GIST_URL, NULL, NULL, 5000, reqBody, 0, response, headers);
    if (res == -1) {
        Print("ERROR GETTING WEBREQUEST. ERROR: " + GetLastError());
        return -1;
    }

    string configString = CharArrayToString(response);
    CJAVal config = CJAVal();
    Print(configString);
    config.Deserialize(configString);

    Print("PUBLISHER_PORT: " + config["PUBLISHER_PORT"].ToStr());
    Print("API_PORT: " + config["API_PORT"].ToStr());

    return (INIT_SUCCEEDED);
}

void sendData();
void OnDeinit(const int reason) {}
void handleSocketConnections();
void OnTick() {}
void OnTimer() {}
