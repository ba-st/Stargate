# Application Configuration

One of the operational plugins. It exposes information about the configuration
of the running application.

This plugin is disabled by default and allows configuring the available
configuration providers. This configuration is made via the `#operations` config.

For example:

```smalltalk
Dictionary new
  at: #operations put: (
    Dictionary new
      at: 'application-configuration'
      put: {
        #enabled -> true.
        #definitions -> application configurationParameters.
        #provider -> [ application configuration ] } asDictionary;
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
    "name": "Port",
    "summary": "Listening Port. Defaults to 4000",
    "attributeName": "port",
    "commandLineArgumentName": "port",
    "environmentVariableName": "PORT",
    "sections": [],
    "current-value": 6000,
    "default": 4000
  },
  {
    "name": "Base URL",
    "summary": "Base URL",
    "attributeName": "baseURL",
    "commandLineArgumentName": "base-url",
    "environmentVariableName": "BASE_URL",
    "sections": [],
    "current-value": "https://api.example.com",
    "type": "mandatory"
  },
  {
    "name": "Debug Mode",
    "summary": "Debugging Mode Flag. Defaults to false",
    "attributeName": "debugMode",
    "commandLineArgumentName": "debug-mode",
    "environmentVariableName": "DEBUG_MODE",
    "sections": [],
    "current-value": true,
    "type": "optional",
    "default": false
  },
  {
    "name": "Secret",
    "summary": "Secret",
    "attributeName": "secret",
    "commandLineArgumentName": "vault.secret",
    "environmentVariableName": "VAULT__SECRET",
    "sections": [
      "Vault"
    ],
    "current-value": "**********",
    "type": "sensitive"
  }
]
```

```http
HTTP/1.1 200 OK
...

port = 6000
base-url = https://api.example.com
debug-mode = true
vault.secret = **********
```
