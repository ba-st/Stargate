# Loggers

One of the operational plugins. It exposes information about the active loggers
of the running application.

This plugin is disabled by default and allows configuring the `Beacon` instance
to query. By default, it will use the default `Beacon` instance.
This configuration is made via the `#operations` config.

For example:

```smalltalk
Dictionary new
  at: #operations put: (
    Dictionary new
      at: 'loggers'
      put: {
        #enabled -> true.
        #beacon -> Beacon instance} asDictionary;
      yourself
    );
  yourself
```

## API

### Listing active loggers

- Endpoint: `/loggers`
- Allowed HTTP methods: `GET`
- Supported media types:
  - `application/vnd.stargate.logger+json`
- Authentication: Required
- Authorization: Requires `read:loggers`
- Expected Responses:
  - `200 OK`

Example response:

```json
HTTP/1.1 200 OK
Content-Type: application/vnd.stargate.logger+json;version=1.0.0

{
  "items": [
    {
      "name": "stdout-logger",
      "typeDescription": "stdout",
      "links": {
        "self": "https://api.example.com/operations/loggers/stdout-logger"
      }
    },
    {
      "name": "stderr-logger",
      "typeDescription": "stderr",
      "links": {
        "self": "https://api.example.com/operations/loggers/stderr-logger"
      }
    }
  ],
  "links": {
    "self": "https://api.example.com/operations/loggers"
  }
}
```

### Accessing an active logger

- Endpoint: `/loggers/{{logger-name}}`
- Allowed HTTP methods: `GET`
- Supported media types:
  - `application/vnd.stargate.logger+json`
- Authentication: Required
- Authorization: Requires `read:loggers`
- Expected Responses:
  - `200 OK`

Example response:

```http
HTTP/1.1 200 OK
Content-Type: application/vnd.stargate.logger+json;version=1.0.0

{
  "name": "stdout-logger",
  "typeDescription": "stdout",
  "links": {
    "self": "https://api.example.com/operations/loggers/stdout-logger"
  }
}
```
