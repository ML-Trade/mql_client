#include "Connection.mqh"

Connection::Connection(ConnectionType connectionType, int port)
    : numMessages(0),
      connectionType(connectionType),
      globals(Globals::getInstance()),
      socket(globals.context, connectionType)
{
    socket.bind("tcp://*:" + port);
}

void Connection::send(CJAVal &message)
{
    bool noWait = true; // If no other ports connected, don't wait
    string msgString = message.Serialize();
    Print("Sending " + msgString);
    socket.send(ZmqMsg(msgString), noWait);
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
}

int Connection::getNumMessages()
{
    return numMessages;
}

int Connection::getPort()
{
    return port;
}

ConnectionType Connection::getConnectionType()
{
    return connectionType;
}