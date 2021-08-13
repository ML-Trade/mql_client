#include "Connection.mqh"

void Connection::Connection(ConnectionType connectionType)
    : numMessages(0), connectionType(connectionType), socket() {
    // Connection::controllerSocket = Socket();
    // Init ZMQ Socket
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

ConnectionType Connection::getConnectionType() {
    return connectionType;
}