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
    Connection(ConnectionType connectionType);

    void send(CJAVal& message);
    CJAVal receive();
    /** Fills the passed CJAVal array with all the messages */
    void receiveAll(CJAVal& messages[]);

    int getNumMessages();
    ConnectionType getConnectionType();
    void init();

   private:
    int numMessages;
    ConnectionType connectionType;
    Socket socket;
};

#endif