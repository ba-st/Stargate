# Application Configuration

One of the operational plugins. It exposes information about the configuration of the running application.

This plugin is disabled by default and allows configuring the available configuration providers. This configuration is made via the `#operations` config.

For example:

```smalltalk
Dictionary new
  at: #operations put: (
    Dictionary new
      at: 'application-configuration'
      put: {#enabled -> true. #'definitions' -> application definitions. #provider -> application configuration } asDictionary;
      yourself
    );
  yourself
```

## API

### Getting configuration information

- Endpoint: `/application-configuration`
- Allowed HTTP methods: `GET`
- Supported media types:
  - `application/vnd.stargate.operational-application-configuration+json`
  - `text/plain`
- Authentication: Required
- Authorization: Requires `read:application-configuration`
- Expected Responses:
  - `200 OK`

Example response:

```json
HTTP/1.1 200 OK
...
[
  {
    "type": "optional",
    "name": "port",
    "current-value": 6000,
    "default": 4000
  },
  {
    "type": "mandatory",
    "name": "base-url",
    "current-value": "https://api.example.com"
  },
  {
    "type": "flag",
    "name": "debug-mode",
    "current-value": true
  }
]
```

```
HTTP/1.1 200 OK
...

port = 6000
base-url = https://api.example.com
debug-mode = true
```
