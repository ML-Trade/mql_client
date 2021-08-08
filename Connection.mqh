#include "./Include/JAson.mqh"

class Connection {
   public:
    Connection();
    void send(CJAVal message);
    string receive();

   private:
}