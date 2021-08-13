#include "./Globals.mqh"
#include "./Include/JAson.mqh"
#include "./Include/Zmq/Zmq.mqh"

#ifndef CONNECTION_MQH
#define CONNECTION_MQH

enum ConnectionType {
    PAIR,
    PUB,
    SUB,
    REQ,
    REP,
    DEALER,
    ROUTER,
    PULL,
    PUSH,
    XPUB,
    XSUB,
    STREAM,
};

class Connection {
   public:
    Connection(ConnectionType connectionType, int port);

    void send(CJAVal& message);
    CJAVal receive();
    /** Fills the passed CJAVal array with all the messages */
    void receiveAll(CJAVal& messages[]);

    int getNumMessages();
    int getPort();
    ConnectionType getConnectionType();
    void init();

   private:
    Globals* globals;
    int numMessages;
    int port;
    ConnectionType connectionType;
    Socket socket;
};

#include "Connection.mq4"
#endif