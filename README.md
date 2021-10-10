# mql_server

MQL server that executes trades, and feeds data to the python client

## Setup

- Copy the contents of the Library folder to your MQL4/Libraries folder in your MT4 data directory

## Compilation

- To compile, run the "Compile-MQL" task in the vscode tasks

# API

## Requests:

```
{
    action: int,
    options: {
        ...
    }
}
```

### action types:
 - 1 <-- Request connection - Options: `none`
 - 2 <-- Trade Request - Options: 
 ```
 {
     action: "BUY" | "SELL" | "CLOSE"
     type: "LIMIT", "MARKET", "STOP",
     price?: float,
     stop?: float, 
     take_profit?: float,
     ticket_id?: int,
     amount?: float     
 }
 ```
 - 3 <-- Healthcheck - Options: `none`

 In the case of a trade request there are 
### Responses:


## Publisher Format

The publisher, which sends the ohlc data to the python client, sends data in the following JSON format

```
{
    symbol: string,
    time: int,
    open: float,
    high: float,
    low: float,
    close: float,
    volume: int,
}
```

When the MQL Client receives no data from the Python Client (due to no wait), an empty JSON message is generated


# Global Config

The `global_config.json` file includes variables that are shared between the Python and MQL client
It is accessed via a web request to [this gist](https://gist.github.com/bigboiblue/cb668007714195333fd9a0c79a6946ee)
This gist automatically updates using github actions on pushes / merges with the master branch.
Note that this may take a few minutes to update each time

## Included variables:

- `PUBLISHER_PORT` -> Used to publish the chart data to from the MQL client to the Python client
- `API_PORT` -> Used by the MQL client to receive (json) requests on that port, and respond to them (in json)
