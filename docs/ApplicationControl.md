# Application Control

One of the operational plugins. It allows to remotely control the running application.

This plugin is disabled by default and allows configuring the available
commands. This configuration is made via the `#operations` config.

For example:

```smalltalk
Dictionary new
  at: #operations put: (
    Dictionary new
      at: 'application-control' 
      put: {
        #enabled -> true. 
        #commands -> #('shutdown')} asDictionary;
      yourself
    );
  yourself
```

To get a list of supported commands, print the result of

```smalltalk
ApplicationControlPlugin availableCommands collect: #methodName as: Array
```

Available commands:

- `shutdown` Gracefully shutdowns the running application

## API

This is a JSON RPC API.

### Running

- Endpoint: `/application-control`
- Allowed HTTP methods: `POST`
- Supported media types: `application/json`
- Authentication: Required
- Authorization: Requires `execute:application-control`
- Expected Responses:
  - `200 OK` when used for Procedure Calls
  - `202 Accepted` when used for Notifications

### Notification

```json
POST /operations/application-control HTTP/1.1
Content-Type: application/json
Accept: application/json

{
  "jsonrpc" : "2.0",
  "method" : "shutdown"
}
```

```json
HTTP/1.1 202 Accepted
```

### Remote Procedure Call

```json
POST /operations/application-control HTTP/1.1
Content-Type: application/json
Accept: application/json

{
  "jsonrpc" : "2.0",
  "id" : 1,
  "method" : "shutdown"
}
```

```json
HTTP/1.1 200 OK
Content-Type: application/json

{
  "jsonrpc": "2.0",
  "result": "Remote SHUTDOWN command was received.",
  "id": 1
}
```

### Unknown Method

```json
POST /operations/application-control HTTP/1.1
Content-Type: application/json
Accept: application/json

{
  "jsonrpc" : "2.0",
  "id" : 1,
  "method" : "xxx"
}
```

```json
HTTP/1.1 200 OK
Content-Type: application/json

{
  "jsonrpc": "2.0",
  "id": 1,
  "error": {
    "message": "The method does not exist / is not available.",
    "code": -32601
  }
}
```
