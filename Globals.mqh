#include "Include/Zmq/Zmq.mqh"

/**
 * Global variables
 * This follows the singleton pattern
 */
class Globals {
   public:
    int PUBLISHER_PORT;
    int API_PORT;
    Context context;

   private:
    /** 
     * Singleton pattern rubbish below
     * */
   public:
    static Globals *getInstance() {
        if (!instance) instance = new Globals();
        return instance;
    }
    static void releaseInstance() {
        delete instance;
        instance = NULL;
    }

   private:
    static Globals *instance;
    Globals() : PUBLISHER_PORT(0),
                API_PORT(0),
                context() {}

   public:
    Globals(const Globals &other) = delete;
    Globals operator=(const Globals &other) = delete;
};

Globals *Globals::instance = NULL;