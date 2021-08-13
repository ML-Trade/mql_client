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
    action: string

}
```

### action types:
 - "REQUEST CONNECTION" <-- Request connection

### Responses:


# Global Config

The `global_config.json` file includes variables that are shared between the Python and MQL client
It is accessed via a web request to [this gist](https://gist.github.com/bigboiblue/cb668007714195333fd9a0c79a6946ee)
This gist automatically updates using github actions on pushes / merges with the master branch

## Included variables:

- `PUBLISHER_PORT` -> Used to publish the chart data to from the MQL client to the Python client
- `API_PORT` -> Used by the MQL client to receive (json) requests on that port, and respond to them (in json)
