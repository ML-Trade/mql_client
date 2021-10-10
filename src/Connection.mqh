#include "../Include/JAson.mqh"
#include "../Include/Zmq/Zmq.mqh"

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
    Connection(Context &context, ConnectionType connectionType, int port);

    void send(CJAVal& message);
    CJAVal* receive(bool noWait = true);
    /** Fills the passed CJAVal array with all the messages */
    void receiveAll(CJAVal& messages[]);

    int getPort();
    ConnectionType getConnectionType();
    void init();
    ~Connection();

   private:
    Context *context;
    int port;
    ConnectionType connectionType;
    Socket socket;
    string address;

};

#include "Connection.mq4"
#endif