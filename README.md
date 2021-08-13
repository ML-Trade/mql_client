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