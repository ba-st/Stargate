# Starting up the API

To start up an API you need to instantiate `HTTPBasedRESTfulAPI` providing the required configuration and the controllers to install.

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
will install the example controllers, and serve the API in the local machine using the port 9999.

The configuration parameters are passed to `Teapot` so you can configure here any of the options accepted by `Teapot` or `Zinc` servers. The `operations` key is mandatory and it's used for the plugin system of Stargate. See [the operations and plugins documentation](Operations.md) to get a list of valid options. For deployment situations is recommended to use the `jwt` authentication scheme.

`#serverUrl` parameter is used in Stargate as the base URL in the media controls. So, if you're deploying your API behind a proxy and using an specific domain, this must be reflected in the configuration so the media control links are generated properly. For example `#serverUrl -> 'http://api.example.com'`.

It's a good idea to get this configuration options from a command line or environment variable, so the same code can be deployed locally for testing and in production with the real values.

## Generating the operations tokens manually

When using JWT as the authentication scheme, the incoming API calls needs to provide a Bearer token with the required permissions encoded.

In production this tokens are usually coming from an Auth provider (like [Auth0](https://auth0.com)), but for testing you can generate tokens manually getting a Pharo image with Stargate loaded and printing the result of the following expression (replacing 'SECRET' by the actual secret key and tunning the permissions if required):
```smalltalk
| jws |

jws := JsonWebSignature new.
jws algorithmName: JWAHMACSHA256 parameterValue.
jws
	payload:
		( JWTClaimsSet new
			permissions:
				#('read:operations' 'read:metrics' 'execute:health-check' 'read:application-info' 'execute:application-control' 'read:application-configuration');
			yourself ).
jws	key: 'SECRET'.
jws compactSerialized
```
