# RESTful Controllers

A controller is responsible for providing a set of routes to be configured in
an API and acts as the mediator between the HTTP Server and the request handlers
it manages. To fulfill its purpose it will configure one or more request
handlers and collaborate with them to implement the methods required in every
route it declares.

Usually, controllers are tied to a resource. In that case, you must subclass
`SingleResourceRESTfulController`, in case you want to manage more than one
resource with the same controller directly, subclass `ResourceRESTfulController`.

In any case, a controller must provide a set of routes to be installed. You can
easily declare new routes by implementing a method starting with `declare` and
ending with `Route`, returning an instance of `RouteSpecification`, for example:

```smalltalk
declareGetCurrencyRoute

  ^ RouteSpecification
    handling: #GET
    at: self identifierTemplate
    evaluating: [ :httpRequest :requestContext |
      self currencyBasedOn: httpRequest within: requestContext ]

```

A route specification must declare which HTTP method will match, a matching
 template for the URI, and a handling block to be evaluated.

Controllers must also implement `serverUrl:`. Usually, this ends up delegating
this method to all the declared request handlers, because it's used to produce
the URLs corresponding to a resource location.

Subclasses of `SingleResourceRESTfulController` must implement `requestHandler`
returning the request handler attached to the managed resource and
`typeIdConstraint` returning some object in the `IsObject` hierarchy. This
constraint is used to provide a URI template for an individual resource instance.

Controllers perform their action by collaboration with one or more instances of
a request handler. The easy way to create a request handler is to use an
instance of `RESTfulRequestHandlerBuilder`.

## Request handler

A request handler's purpose is to help implement each operation a controller
must support.

- `GET` operations over an individual resource must send `from:within:get:` to
  the request handler with the `httpRequest`, the `requestContext`, and a block
  that will be evaluated with the `id` parsed from the URL and must return a
  resource instance.
- `GET` operations over a resource collection must send
  `from:within:getCollection:` with a block that will be evaluated with a
  pagination object in case the request handler was configured with pagination.
  This block must return the collection to be encoded in the response, and in
  case it's paginated and hypermedia driven, it must update the `requestContext`
  with the corresponding pagination links.
- `POST` operations creating a new resource instance must send any of:
  - `withResourceCreatedFrom:within:do:` with a block that will be evaluated
    with the resource instance created by decoding the request body.
  - `withRepresentationIn:within:createResourceWith:thenDo:`, the first block
    will be evaluated with a half-decoded representation (for example a
    `NeoJSONObject`) and must produce a resource instance, the second block will
    be evaluated with the resource instance. This separation allows for better
    error handling because during the first block evaluation decoding errors
    will be automatically handled.
- `DELETE` operations or `POST` operations not creating new resources must send
  `from:within:get:thenDo:`. The first block will receive the resource id parsed
  from the URL and must look up for a resource instance. The second block will
  receive this resource instance to perform the action we want. This message
  will always produce a `204/No Content` response if successful.
- `PUT` or `PATCH` operations over an individual resource must send
  `from:within:get:thenUpdateWith:`. The first block will receive the resource
  id and must look up a resource instance. The second block will receive both
  the found resource and the resource created by decoding the request body and
  must perform the update operation and return the updated resource that will be
  encoded in the response body.

## Request Handler Builder

A request handler builder will help us to create a request handler. The builder
must be configured to produce a valid request handler:

## Basic Configuration

- For non-hypermedia driven controllers only implementing GET functionality over
  a resource, configure the builder using `handling:extractingIdentifierWith:`.
  This method will receive an endpoint to handle and a block used to extract the
  identifier of a resource instance from the request. For example:

  ```smalltalk
  builder
      handling: 'currencies'
      extractingIdentifierWith:
      [ :httpRequest | self identifierIn: httpRequest ];
  ```

- For non-hypermedia driven controllers only implementing GET functionality over
  a subresource, configure the builder using
  `handling:extractingIdentifierWith:locatingParentResourceWith:`. This method
  will receive additionally a resource locator to be used for locating the
  parent resource instance. For example:

  ```smalltalk
  builder
      handling: 'banknotes'
      extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ]
      locatingParentResourceWith: parentRequestHandler resourceLocator;
  ```

- For hypermedia driven controllers or controllers implementing POST
  functionality over a resource, you will need to configure the builder using
  `handling:locatingResourcesWith:extractingIdentifierWith:`. This method will
  require a configuration block used to produce the location of a resource
  instance. This block will receive the resource and must return the identifier
  associated with it, the library then uses the base URL and the endpoint to
  produce the unique URL identifying it. For example:

  ```smalltalk
  builder
      handling: 'orders'
      locatingResourcesWith:
        [ :order :requestContext | ordersRepository identifierOf: order ]
      extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ];
  ```

- For hypermedia driven controllers or controllers implementing POST
  functionality over a subresource, you will need to configure the builder using
  `handling:locatingSubresourcesWith:extractingIdentifierWith:locatingParentResourceWith:`.
  This method will require a configuration block used to produce the location of
  the subresource. This block will receive the subresource instance and can
  access the parent resource through the request context. For example:

  ```smalltalk
  builder
      handling: 'comments'
      locatingSubresourcesWith: [ :comment :requestContext |
        self commentIdentifierOf: comment relatedTo: requestContext parentResource
      ]
      extractingIdentifierWith:
        [ :httpRequest | self commentIdentifierIn: httpRequest ]
      locatingParentResourceWith: parentRequestHandler resourceLocator
  ```

## Representation Decoding

Controllers implementing `POST`, `PUT` or `PATCH` methods will need to take the
request body and convert this representation to a resource instance, configuring
the builder by using any of:

- `whenAccepting:decodeApplying:` will create a decoding rule attached to a media
  type and apply a block receiving the request body as the parameter.
- `whenAccepting:decodeFromJsonApplying:` will use `NeoJSON` to help in the
  decoding. The block will receive the original JSON and a `NeoJSONReader` ready
  to be configured.
- `decodeToNeoJSONObjectWhenAccepting:` will produce an instance of `NeoJSONObject`

## Representation Encoding

Controllers needing to include a body in the response will need to take a
resource instance and convert it to the negotiated representation, configuring
the builder using any of:

- `whenResponding:encodeApplying:` will create a decoding rule attached to a
  media type applying a block receiving the resource instance as a parameter.
- `whenResponding:encodeToJsonApplying:` will use `NeoJSON` to help in the
  encoding. The provided block will receive a `NeoJSONWriter` ready to be configured.

The media types attached to an encoding rule are automatically considered in the
content negotiation.

## Hypermedia driven controllers

Controllers wanting to provide hypermedia links must configure the builder using
one of the following methods:

- `beHypermediaDriven` will only produce a `self` link for the resource
- `beHypermediaDrivenBy:` requires a configuration block that will be evaluated
  with a link builder, the resource, the context, and the resource location
  allowing the controller to add as many links as it wants. For example:

  ```smalltalk
  builder
      beHypermediaDrivenBy: [ :builder :order :requestContext :orderLocation |
          builder addLink: orderLocation / 'complete' relatedTo: 'complete'
        ]
  ```

## ETags

Controllers must provide a way to calculate an ETag for resources configuring
the builder with one of the following methods:

- `createEntityTagWith:` will receive a block that will be evaluated with the
  resource, the media type, and the request context and must produce an ETag value.
- `createEntityTagHashing:` will receive a block that will be evaluated with a
  `hasher`, the resource, and the request context. One must include objects to be
  considered in the hash by sending `include:` to the `hasher` instance. The
  `hasher` will then produce an ETag value applying a Hash function to all the
  included objects.

## Collection Pagination

By default GET requests over collections will not be paginated. To get
collections paginated, configure the builder by sending the message
`paginateCollectionsWithDefaultLimit:` providing the default page limit. A
request handler will parse `start` and `limit` as query parameters during a GET
request processing and will provide a pagination object.

## Exception Handling

Request handlers will handle some exceptions by default and raise them as proper
HTTP errors:

- `ObjectNotFound` will raise a 404/Not Found error
- `ConflictingObjectFound` will raise a 409/Conflict error
- `KeyNotFound` and `NeoJSONParseError` will raise a 400/Bad Request error
- `TeaNoSuchParam` will raise a 400/Bad Request error

The end user can configure additional exceptions to be automatically handled by
sending `handleExceptionsApplying:` to the builder. For example:

```smalltalk
builder
    handleExceptionsApplying: [ :handler |
      handler
        addAsNotFoundError: NotFound;
        addAsDecodingError: InstanceCreationFailed ];
```

## Caching directives

Stargate allows including caching directives in the response headers, according
to [RFC 7234](https://tools.ietf.org/html/rfc7234).

Headers are configured per resource, which means they are specified in the
builder, by indicating the caching behavior.

```smalltalk
builder directCachingWith: [ :caching |
    caching
      expireIn: 4 hours;
      bePublic;
      doNotTransform;
      mustRevalidate
    ];
```

The available messages can be found in the `configuring` protocol of `CachingDirectivesBuilder`.

Apart from all the response directives (see [here](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Cache-Control)
for a summary), there is also support for the extension directive `immutable`,
and the `Expires` header.

To simplify some common caching scenarios, the builder can also receive:

- `beAvailableFor: aDuration` which implies `public`, `max-age` and `expires`
- `doNotExpire` which implies `immutable`and `max-age=365000000`
- `requireRevalidation` which implies `no-cache`and `max-age=0`

Both `private` and `no-cache` directives can specify a list of fields that
restrict them using `bePrivateRestrictedTo: aFieldNameCollection` and
`doNotCacheRestrictedTo: aFieldNameCollection` respectively.

Additionally, if you may have different caching directive depending on the
response, you can add a condition before configuring the builder.

For specific examples on all the different options offered by Stargate, check the
example classes and their respective tests:

- `PetsRESTfulController` offers `/pets` as a _public_ resource for _4 hours_, but
  when using a specific content-type it _can't be transformed_, and
  _must be revalidated_ once stale.
- `PetOrdersRESTfulController` offers `/orders` as a _public_ resource for
  _1 minute_, using both the `expires` header and the `max-age` directive.
- `PetOrdersRESTfulController` offers `/orders/<id>/comments`, indicating
  _shared_ caches _must revalidate_ the resources after _10 minutes_.
- `SouthAmericanCurrenciesRESTfulController` offers `/currencies` as an
  _immutable_ resource, and `/currencies/<id>/banknotes` as an _immutable_
  resource fresh for _365.000.000 seconds_.

## Language negotiation

For APIs requiring the support of several languages, Stargate offers support to
consider `Accept-Language` headers in the content negotiation. To enable
this, the request builder needs to be configured with the supported language tags.

```smalltalk
builder
  addAsSupportedLanguage: 'en-US';
  addAsSupportedLanguage: 'es-AR'
```

As soon as a language is supported, Stargate will consider the
`Accept-Language` header and make the negotiated language available in the
request context.

To access the negotiated language, send `targetLanguageTag` or
`withTargetLanguageTagDo:` to the request context. API implementors can then use
it to produce a response in the corresponding language.

Once language negotiation is enabled, the `Content-Language` header will
contain the negotiated language in the response.
