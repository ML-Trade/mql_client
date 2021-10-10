#include "./Connection.mqh"
#include "./utils.mq4"

int supportedTypes[] = {
    ConnectionType::PUB, ConnectionType::SUB,
    ConnectionType::REP, ConnectionType::REQ
};

int serverConnectionTypes[] = {
    ConnectionType::PUB,
    ConnectionType::REP,
};

Connection::Connection(Context &context, ConnectionType connectionType, int port)
    : connectionType(connectionType),
      context(&context),
      socket(context, connectionType),
      port(port)
{
    if (!IsInArray(supportedTypes, (int)connectionType)) {
        Print("ERROR::Only PUB, SUB, REP, and REQ are supported connection types as of now, not type: " + connectionType);
        ExpertRemove();
    }

    if (IsInArray(serverConnectionTypes, (int)connectionType)) {
        address = "tcp://*:" + port;
        socket.bind(address);
        Print(StringFormat("%i bound to %s", connectionType, address));
    } else {
        address = "tcp://localhost:" + port;
        socket.connect(address);
        Print(StringFormat("%i connected to %s", connectionType, address));
    }    
}

void Connection::send(CJAVal &message)
{
    bool noWait = true; // If no other ports connected, don't wait
    string msgString = message.Serialize();
    ZmqMsg msg(msgString);
    socket.send(msg, noWait);
}

CJAVal* Connection::receive(bool noWait = true)
{
    ZmqMsg msg;
    bool isSuccess = socket.recv(msg, noWait);
    CJAVal ret;
    if (isSuccess) {
        ret.Deserialize(msg.getData());
    }
    return &ret;
}

void Connection::receiveAll(CJAVal &messages[])
{
    Print("NOT YET IMPLEMENTED");
}

int Connection::getPort()
{
    return port;
}

ConnectionType Connection::getConnectionType()
{
    return connectionType;
}

Connection::~Connection() {
    socket.disconnect(address);
    socket.unbind(address);
}