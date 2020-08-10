# Cross-Origin Resource Sharing 

Cross-Origin Resource Sharing, or simply CORS, is a protocol to allow web applications running at one origin access asynchronously resources from a different one.

Browsers follow the very restrictive [same-origin policy](https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy) for securiry reasons and use CORS to mitigate the risks of cross-origin HTTP requests when needed.

CORS adds HTTP headers specifying allowed origins to access the resources. Additionally, for some requests, the protocol defines the browser must preflight them. This preflight implies sending an `OPTIONS` request before the actual one describing its HTTP method and headers. The preflight response will indicate, using headers, the conditions to access the resource. If the actual request satisfies all is it sent to the server. 

For a more detailed explanation about CORS, see [MDN web docs](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS).

## Usage

### Simple usage

CORS support is disabled by default. To enable it, send `allowCrossOriginSharingApplying:` message along with a configuration block to the api. The simple posible configuration is:

```` smalltalk
api := HTTPBasedRESTfulAPI
    configuredBy: { "configuration"  }
		installing: { "controllers to install" } .

	  api allowCrossOriginSharingApplying: [:cors | cors allowAnyOrigin ]
````

This configuration will allow a web application to make requests to the API from any origin.

### Configure allowed origins

#### Allow any origin

To allow any origin send `allowAnyOrigin` into the configuration block.

#### Restrict allowed origins

You could specify a list of allowed origins by sending the message `allowOnlyFrom:` with a collection of one or more allowed origins.

```` smalltalk
api := HTTPBasedRESTfulAPI
    configuredBy: { "configuration"  }
		installing: { "controllers to install" } .

	  api allowCrossOriginSharingApplying: [:cors | cors allowOnlyFrom: { 'http://website.com '} ]
````

Take into account that an origin differ from another if you change the domain, port or protocol.

### Requests with credentials

To allow the use of credentials, like cookies or basic HTTP authentication, send `allowCredentials` into the configuration block.

```` smalltalk
api := HTTPBasedRESTfulAPI
    configuredBy: { "configuration"  }
		installing: { "controllers to install" } .

	  api allowCrossOriginSharingApplying: [:cors | cors 
      allowOnlyFrom: { 'http://website.com '};
      allowCredentials ]
````

#### Beware of wildcards

Allowing credentials will not work along with allowing any origin, you must be specify a list of allowed origins. The builder will not enforce you this so you're warned :blink:.

### Caching preflight requests

You could also indicate how long the result of the a preflight request will be cached by setting a cache duration in seconds. Maximun time varies between browsers.

Send `#expireIn:`

To avoid caching send the message `#doNotCache` into the configuration block.

### Expose headers

