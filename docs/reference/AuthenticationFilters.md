# Authentication Filters

Authentication filters are useful for adding credential checks to some specific
routes in the API or the whole API.

There are two flavour of filters implemented:

- `JWTBearerAuthenticationFilter` will check the `Authorization` header for a
  Bearer token, and will verify if it's valid against the key and algorithm
  provided to the filter. If the validation is successful it will also make
  available through the `requestContext` the set of permissions encoded in the
  JWT.
- `ZnAuthenticationFilter` is an adapter over `ZnBasicAuthenticator` instances,
  so it can be used as authentication filter in the library. This adapter will
  send `isRequestAuthenticated:` to the authenticator to verify the authentication
  status.

In any case, if the credentials are invalid the request responds with a
`401/Unauthorized` error.

## Authenticating a single route

To authenticate a single route send `authenticatedBy:` with the authentication
filter instance to the route specification.

## Authenticating the whole API

To authenticate the whole API send `authenticatedBy:` with the authentication
filter instance to the `HTTPBasedRESTfulAPI` instance. This configuration takes
into account CORS preflight requests because they cannot be authenticated.

## Caching authenticated responses

The response to an authenticated request depends on its credentials: the filter
refuses the ones it doesn't accept, and a controller can answer differently
depending on the permissions they grant. So both ways of authenticating add
`Authorization` to the `Vary` header of every response the route or the API
answers, keeping a shared cache from reusing it for requests with other
credentials, or none.

Responses answered by an error handler, such as the `401/Unauthorized` the
filter answers itself, don't get it, because they don't go through the filter.

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
