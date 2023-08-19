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
operations and plugins documentation](../reference/Operations.md) to get a list of valid
options. For deployment environments, the `jwt` authentication scheme is recommended.

`#serverUrl` parameter is used as the base URL in the media controls. So, if
you're deploying your API behind a proxy and using a specific domain, this
must be reflected in the configuration so the media controls links are
generated properly. For example `#serverUrl -> 'http://api.example.com'`.

It's a good idea to get these configuration options from a command line or
environment variable, so the same code can be deployed locally for testing and
in production with the real values.
