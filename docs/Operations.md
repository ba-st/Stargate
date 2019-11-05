# Operations

Operational plugins bring production-ready features to your application supporting the operations team.

An operational plugin has the following characteristics:
- Must expose operational information or allow to control some operation
- It's optional. It can be enabled by default but should be possible to disable it
- Must expose at least one endpoint to access it's functionality under `/operations/{{plugin-endpoint}}`
- Must be secured with a proper authorization filter. In specific cases a plugin can respond with some basic data in case there's no authorization (for example a basic health-check) but this behavior  must be the exception to the rule.
- Should be possible to enable/disable/configure it on the fly using an API endpoint (given the proper authorization credentials) using the media controls provided in the plugin representation

## Operations API

A RESTful API is available as the entry point for the operational plugins. All the endpoints requires authentication and most of them authorization.

### Configuration Options

Operations configuration are received in the general Stargate configuration parameters under the `#operations` key. This key is a dictionary including general configuration and plugin specific configuration. Following is a list of the general options:
- `#authSchema`: `jwt` or `basic`. It's used to configure the authentication filters on the operational plugin endpoints. In case Basic auth is used the only accessible endpoints will be the ones not requiring authorization. When JWT is used the `scope` claim will be parsed and used as permissions.

If the schema is `jwt` (Recommended)
  - `#authAlgorithm`: This option must specify the algorithm to be used. By now `HS256` is supported.
  - `#authSecret`: The shared secret required by `HS256`.

If the schema is `basic`
- `#username`: The username to be used in basic auth
- `#password`: The password to be used in basic auth

### Listing available plugins

- Endpoint: `/operations`
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
        "self":"{{BASE_URL}}/operations/health-check"
      }
    }
  ],
  "links":{
    "self":"{{BASE_URL}}/operations"
  }
}
```
### Accessing a plugin

- Endpoint: `/operations/{{plugin-endpoint}}`
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
    "self":"{{BASE_URL}}/operations/health-check"
  }
}
```
