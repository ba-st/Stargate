# Authentication Filters

Authentication filters are useful for adding credential checks to some specific
routes in the API or the whole API.

There are two flavour of filters implemented:

- `JWTBearerAuthenticationFilter` will check the `Authorization` header for a
  Bearer token, and will verify if it's valid against the key and algorithm
  provided to the filter. If the validation is successful it will also make
  available through the `requestContext` the set of permissions encoded in the
  JWT.
- `ZnAuthenticationFilter` is an adapter over `ZnBasicAuthenticator` instances
  so it can be used as authentication filters in the library. This adapter will
  send `isRequestAuthenticated:` to the authenticator to verify the authentication
  status.

In any case, if the credentials are invalid the request is responded with a
`401/Unauthorized` error.

## Authenticating a single route

To authenticate a single route send `authenticatedBy:` with the authentication
filter instance to the route specification.

## Authenticating the whole API

To authenticate the whole API send `authenticatedBy:` with the authentication
filter instance to the `HTTPBasedRESTfulAPI` instance. This configuration takes
into account CORS preflight requests because they cannot be authenticated.

## Using with a plain Teapot server

Authentication filters can be used as handlers for any of the routing methods
in Teapot.

For example:

```smalltalk
Teapot on
  before: '/secure/*' -> (ZnAuthenticationFilter username: 'user' password: 'secret');
  GET: '/secure' -> 'protected';
  start.
```
