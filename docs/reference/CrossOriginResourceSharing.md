# Cross-Origin Resource Sharing

Cross-Origin Resource Sharing, or simply CORS, is a protocol that allows web
applications running at one origin, asynchronous access to resources from a
different one.

Browsers follow the very restrictive [same-origin policy](https://developer.mozilla.org/en-US/docs/Web/Security/Same-origin_policy)
for security reasons and use CORS to mitigate the risks of cross-origin HTTP
requests when needed.

CORS adds HTTP headers that specify which origins are allowed access to the
resources. Additionally, for some requests, the protocol defines the browser must
preflight them. This preflight implies sending an `OPTIONS` request before the
actual one describing its HTTP method and headers. The preflight response will
indicate, using headers, the conditions to access the resource. If the actual
request satisfies all is it sent to the server.

For a more detailed explanation about CORS, see [MDN web docs](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS).

## Usage

### Simple usage

CORS support is disabled by default. To enable it, send
`allowCrossOriginSharingApplying:` message along with a configuration block to
the API. The simplest possible configuration is:

```smalltalk
api := HTTPBasedRESTfulAPI
  configuredBy: { "configuration"  }  
  installing: { "controllers to install" } .

api allowCrossOriginSharingApplying: [:cors | cors allowAnyOrigin ]
```

This configuration will allow a web application to make requests to the API from
any origin.

### Configuring allowed origins

Allowed origin's configuration is mandatory. There are two options available.

#### Allowing any origin

To allow any origin send `allowAnyOrigin` inside the configuration block.

#### Restrict allowed origins

To specify a list of allowed origins send `allowOnlyFrom:` with a collection of
one or more origins.

```smalltalk
api := HTTPBasedRESTfulAPI
  configuredBy: { "configuration"  }
  installing: { "controllers to install" }.

api allowCrossOriginSharingApplying:
  [:cors | cors allowOnlyFrom: { 'http://website.com '} ]
```

Take into account that an origin differs from another if you change the domain,
port, or protocol.

A request from an origin that isn't in the list gets the same response it would
get without CORS: the API leaves the CORS headers out, and the browser blocks
the response. A preflight request from such an origin is answered with an empty
`204 No Content`.

With a restricted list of origins, whether a response includes
`Access-Control-Allow-Origin` depends on the request's `Origin` header. So,
[as the Fetch standard requires](https://fetch.spec.whatwg.org/#cors-protocol-and-http-caches),
every response of the API includes `Origin` in its `Vary` header, even the ones
to requests without `Origin`. This way shared caches don't serve a response to
an origin it wasn't meant for. When allowing any origin, `Vary` is left alone.

### Requests with credentials

Optionally, to allow credentials in the server, like cookies or basic HTTP
authentication, send `allowCredentials` into the configuration block.

```smalltalk
api := HTTPBasedRESTfulAPI
  configuredBy: { "configuration"  }
  installing: { "controllers to install" } .

api allowCrossOriginSharingApplying: [:cors | cors
  allowOnlyFrom: { 'http://website.com '};
  allowCredentials ]
```

*Note* Using `allowCredentials` will not work along with `allowingAnyOrigin`, you
must specify a list of allowed origins. Currently, the builder will not enforce
this itself.

### Caching preflight requests

You can also indicate for how long the result of the preflight request will be
cached by setting a cache duration (in seconds). Maximum time varies between browsers.

With the following code the cache is set to expire in 600 seconds:

```` smalltalk
api := HTTPBasedRESTfulAPI
  configuredBy: { "configuration"  }
  installing: { "controllers to install" } .

api allowCrossOriginSharingApplying: [:cors | cors
  allowOnlyFrom: { 'http://website.com '};
  expireIn: 600 seconds ]
````

To avoid caching send the message `#doNotCache` inside the configuration block.

### Expose headers

To explicitly declare a set of headers allowed by the server send the message
`expose:` along with a collection of allowed headers into the configuration
block. This configuration is also optional.

```` smalltalk
api := HTTPBasedRESTfulAPI
  configuredBy: { "configuration"  }
  installing: { "controllers to install" } .

api allowCrossOriginSharingApplying: [:cors | cors
  allowOnlyFrom: { 'http://website.com '};
  expose: #('Authorization' 'X-Custom') ]
````
