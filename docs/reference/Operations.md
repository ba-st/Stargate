# Operations

Operational plugins bring production-ready features to your application
supporting the operations team.

An operational plugin has the following characteristics:

- Must expose operational information or allow to control some operation
- It's optional. It can be enabled by default but should be possible to disable it
- Must expose at least one endpoint to access its functionality under `/operations/{{plugin-endpoint}}`
- Must be secured with a proper authorization filter. In specific cases a
  plugin can respond with some basic data in case there's no authorization
  (for example a basic health-check) but this behavior must be the exception
  to the rule.
- Should be possible to enable/disable it on the fly using an API
  endpoint (given the proper authorization credentials) using the media
  controls provided in the plugin representation

## Implemented Plugins

- [Application Configuration](ApplicationConfiguration.md)
- [Application Control](ApplicationControl.md)
- [Application Info](ApplicationInfo.md)
- [Health Check](HealthCheck.md)
- [Metrics](Metrics.md)
- [Loggers](Loggers.md)

## Configuration Options

Configuration options are received in the general Stargate configuration
parameters under the `#operations` key. This key is a dictionary including
general configuration and plugin-specific configuration.

Following is a list of the general options:

- `#authSchema`: `jwt` or `basic`. This is used to configure the authentication
  filters on the operational plugin endpoints. In case Basic auth is used the
  only accessible endpoints will be the ones not requiring authorization. When
  JWT is used the `permissions` claim will be parsed and used as permissions.

If the schema is `jwt` (Recommended)

- `#authAlgorithm`: This option must specify the algorithm to be used. By now
  just `HS256` is supported.
- `#authSecret`: The shared secret required by `HS256`.

If the schema is `basic`

- `#authUsername`: The username to be used in basic auth
- `#authPassword`: The password to be used in basic auth

Plugin specific configuration are included under a `#{{plugin-endpoint}}` key.
All the plugins can be enabled or disabled through configuration including an
`#enabled` option in the specific configuration. For example to disable the
Health Check plugin the configuration must be something like:

```smalltalk
Dictionary new
  at: #operations put: (
    Dictionary new
      at: #'health-check' put: {#enabled -> false} asDictionary;
      yourself
    );
  yourself
```

## Operations API

A RESTful API is available as the entry point for the operational plugins. All
the endpoints require authentication and most of them, authorization.

### Listing available plugins

- Endpoint: `/operations/plugins`
- Allowed HTTP methods: `GET`
- Supported media types: `application/vnd.stargate.operational-plugin+json`
- Authentication: Required
- Authorization: Requires `read:operations` permission.

Example response:

```json
{
  "items":[
    {
      "name":"Health Check",
      "status":"ENABLED",
      "links":{
        "self":"{{BASE_URL}}/operations/plugins/health-check",
        "run":"{{BASE_URL}}/operations/health-check"
      }
    }
  ],
  "links":{
    "self":"{{BASE_URL}}/operations/plugins"
  }
}
```

### Accessing a plugin

- Endpoint: `/operations/plugins/{{plugin-endpoint}}`
- Allowed HTTP methods: `GET`
- Supported media types: `application/vnd.stargate.operational-plugin+json`
- Authentication: Required
- Authorization: Requires `read:operations` permission.

Example response:

```json
{
  "name":"Health Check",
  "status":"ENABLED",
  "links":{
    "self":"{{BASE_URL}}/operations/plugins/health-check",
    "run":"{{BASE_URL}}/operations/health-check"
  }
}
```

### Disabling a plugin

- Endpoint: `/operations/plugins/{{plugin-endpoint}}`
- Allowed HTTP methods: `PATCH`
- Supported media types: `application/vnd.stargate.operational-plugin+json`
- Authentication: Required
- Authorization: Requires `update:operations` permission.

```http
PATCH /operations/plugins/health-check HTTP/1.1
Content-Type: application/vnd.stargate.operational-plugin+json;version=1.0.0
Accept: application/vnd.stargate.operational-plugin+json;version=1
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJwZXJtaXNzaW9ucyI6WyJ1cGRhdGU6b3BlcmF0aW9ucyJdfQ.E4xcxUQm-2-7ZeMxEe7FI2iEUOAfqJlQRVxNPlAlUAY
If-Match: "0a651615d7dfa0d9d289eea848cd746fcb178848"

{"status":"DISABLED"}
```

```http
HTTP/1.1 200 OK
Content-Type: application/vnd.stargate.operational-plugin+json;version=1.0.0
Etag: "ac64ae1c7f6f4a4dc2165833b5f6218fd8b07545"
Vary: Accept

{
  "name":"Health Check",
  "status":"DISABLED",
  "links":{
    "self":"{{BASE_URL}}/operations/plugins/health-check"}}
```

### Enabling a plugin

- Endpoint: `/operations/plugins/{{plugin-endpoint}}`
- Allowed HTTP methods: `PATCH`
- Supported media types: `application/vnd.stargate.operational-plugin+json`
- Authentication: Required
- Authorization: Requires `update:operations` permission.

```http
PATCH /operations/plugins/health-check HTTP/1.1
Content-Type: application/vnd.stargate.operational-plugin+json;version=1.0.0
Accept: application/vnd.stargate.operational-plugin+json;version=1
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJwZXJtaXNzaW9ucyI6WyJ1cGRhdGU6b3BlcmF0aW9ucyJdfQ.E4xcxUQm-2-7ZeMxEe7FI2iEUOAfqJlQRVxNPlAlUAY
If-Match: "0a651615d7dfa0d9d289eea848cd746fcb178848"

{"status":"ENABLED"}
```

```http
HTTP/1.1 200 OK
Content-Type: application/vnd.stargate.operational-plugin+json;version=1.0.0
Etag: "d41da10c1c8f0d00ad70128b0f682cbc"
Vary: Accept

{
  "name":"Health Check",
  "status":"ENABLED",
  "links":{
    "self":"{{BASE_URL}}/operations/plugins/health-check",
    "run":"{{BASE_URL}}/operations/health-check"
  }
}
```
