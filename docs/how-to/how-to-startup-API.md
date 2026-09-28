# How to start up an API

To start up an API you need to instantiate `HTTPBasedRESTfulAPI` providing the
required configuration and the controllers to install.

For example

```smalltalk
| api |
api := HTTPBasedRESTfulAPI
configuredBy: {
    #port -> 9999.
    #serverUrl -> ('http://localhost' asUrl port: 9999).
    #operations ->
      (Dictionary new
        at: #authSchema put: 'basic';
        at: #authUsername put: 'test';
        at: #authPassword put: 'test';
        yourself )
    }
installing: {
    SouthAmericanCurrenciesRESTfulController new.
    PetsRESTfulController new.
    PetOrdersRESTfulController new
    }.

api
    install;
    start
```

will install the example controllers, and serve the API in the local machine
using port 9999.

The configuration parameters are passed to `Teapot` so you can configure here
any of the options accepted by `Teapot` or `Zinc` servers. The `operations`
key is mandatory, and it's used for the plugin system of Stargate. See [the
operations and plugins documentation](../reference/Operations.md) to get a list
of valid options. For deployment environments, the `jwt` authentication scheme
is recommended.

`#serverUrl` parameter is used as the base URL in the media controls. So, if
you're deploying your API behind a proxy and using a specific domain, this
must be reflected in the configuration so the media controls links are
generated properly. For example `#serverUrl -> 'http://api.example.com'`.

It's a good idea to get these configuration options from a command line or
environment variable, so the same code can be deployed locally for testing and
in production with the real values.

## Handle errors

When a route signals an `HTTPClientError`, the API answers with its status code
and a JSON body describing it. To answer client errors differently, for
example with an [RFC 9457](https://www.rfc-editor.org/rfc/rfc9457) problem
document, give the API a `#clientErrorHandler` in its configuration:

```smalltalk
api := HTTPBasedRESTfulAPI
  configuredBy: {
    #port -> 9999.
    #serverUrl -> ('http://localhost' asUrl port: 9999).
    #operations -> operationsConfiguration.
    #clientErrorHandler -> [ :clientError :request |
      ( ZnResponse statusCode: clientError code )
        entity: ( ZnEntity
          with: ( NeoJSONWriter toString: ( Dictionary new
            at: #status put: clientError code;
            at: #title put: clientError messageText;
            yourself ) )
          ofType: 'application/problem+json' asMediaType );
        yourself
      ]
    }
  installing: controllers
```

To handle other errors, add a handler for them before installing the API:

```smalltalk
api on: Error addErrorHandler: [ :error :request |
  ZnResponse serverError: error messageText ]
```

The client error handler always runs first, and added handlers run in the order
they were added, so add specific handlers before generic ones. A handler added
for `HTTPClientError`, or for any of its subclasses, is never reached: use
`#clientErrorHandler` instead.

If [cross-origin resource sharing](../reference/CrossOriginResourceSharing.md)
is enabled, the API applies its configuration to the responses error handlers
answer, so handlers don't need to.
