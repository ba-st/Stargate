# Operations

Operational plugins bring production-ready features to your application supporting the operations team.

An operational plugin has the following characteristics:
- Must expose operational information or allow to control some operation
- It's optional. It can be enabled by default but should be possible to disable it
- Must expose at least one endpoint to access it's functionality under `/operations/{{plugin-endpoint}}`
- Must be secured with a proper authorization filter. In specific cases a plugin can respond with some basic data in case there's no authorization (for example a basic health-check) but this behavior must be the exception to the rule.
- Should be possible to enable/disable/configure it on the fly using an API endpoint (given the proper authorization credentials) using the media controls provided in the plugin representation

## Implemented Plugins
- [Application Configuration](ApplicationConfiguration.md)
- [Application Control](ApplicationControl.md)
- [Application Info](ApplicationInfo.md)
- [Healt Check](HealthCheck.md)
- [Metrics](Metrics.md)

## Configuration Options

Configuration options are received in the general Stargate configuration parameters under the `#operations` key. This key is a dictionary including general configuration and plugin specific configuration.

Following is a list of the general options:
- `#authSchema`: `jwt` or `basic`. This is used to configure the authentication filters on the operational plugin endpoints. In case Basic auth is used the only accessible endpoints will be the ones not requiring authorization. When JWT is used the `scope` claim will be parsed and used as permissions.

If the schema is `jwt` (Recommended)
  - `#authAlgorithm`: This option must specify the algorithm to be used. By now just `HS256` is supported.
  - `#authSecret`: The shared secret required by `HS256`.

If the schema is `basic`
- `#authUsername`: The username to be used in basic auth
- `#authPassword`: The password to be used in basic auth

Plugin specific configuration are included under a `#{{plugin-endpoint}}` key. All the plugins can be enabled or disabled by configuration including an `#enabled` option in the specific configuration. For example to disable the Health Check plugin the configuration must be something like:
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

A RESTful API is available as the entry point for the operational plugins. All the endpoints require authentication and most of them authorization.

### Listing available plugins

- Endpoint: `/operations/plugins`
- Allowed HTTP methods: `GET`
- Supported media types: `application/vnd.stargate.operational-plugin+json`
- Authentication: Required
- Authorization: Requires `read:operations` permission.

Example response:
```
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
```
{
  "name":"Health Check",
  "status":"ENABLED",
  "links":{
    "self":"{{BASE_URL}}/operations/plugins/health-check",
    "run":"{{BASE_URL}}/operations/health-check"
  }
}
```
