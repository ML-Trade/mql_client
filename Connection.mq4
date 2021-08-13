#include "Connection.mqh"

void Connection::Connection(ConnectionType connectionType, int port)
    : numMessages(0),
      connectionType(connectionType),
      globals(Globals::getInstance()),
      socket(globals.context, connectionType) {
}

void Connection::send(CJAVal& message) {
    // Send message over MQL Socket
}

CJAVal Connection::receive() {
    // Receive most recent message over MQL Socket
    return CJAVal();
}

void Connection::receiveAll(CJAVal& messages[]) {
}

int Connection::getNumMessages() {
    return numMessages;
}

int Connection::getPort() {
    return port;
}

ConnectionType Connection::getConnectionType() {
    return connectionType;
}