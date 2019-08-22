# RESTful Controllers

A controller is responsible for providing a set of routes to be configured in an API and acts as mediator between the HTTP Server and the request handlers it manages. To fulfill it's purpose it will configure one or more request handlers and collaborate with them to implement the methods required in every route it declares.

Usually controllers are tied to a resource, in that case you must subclass `SingleResourceRESTfulController`, in case you want to manage more than one resource with the same controller directly subclass `ResourceRESTfulController`.

In any case a controller must provide a set of routes to be installed. You can easily declare new routes by implementing a method starting with `declare` and ending with `Route`, returning an instance of `RouteSpecification`, for example:

```smalltalk
declareGetCurrencyRoute

	^ RouteSpecification
		handling: #GET
		at: self identifierTemplate
		evaluating: [ :httpRequest :requestContext |
          self currencyBasedOn: httpRequest within: requestContext ]

```
A route specification must declare which HTTP method will match, a matching template for the URI and a handling block to be evaluated.

Controllers must also implement `serverUrl:`. Usually this end ups delegating this method to all the declared request handlers, because it's used to produce the URLs corresponding to a resource location.

Subclasses of `SingleResourceRESTfulController` must implement `requestHandler` returning the request handler attached to the managed resource and `typeIdConstraint` returning some object in the `IsObject` hierarchy. This constraint is used to provide a URI template for an individual resource instance.

Controllers perform it's action by collaboration with one or more instances of a request handler. The easy way to create a request handler is to use an instance of `RESTfulRequestHandlerBuilder`.

# Request Handler Builder

A request handler builder will help us to create a request handler. The builder must be configured in order to produce a valid request handler:

## Basic Configuration

- For non hypermedia driven controllers only implementing GET functionality over a resource configure the builder using `handling:extractingIdentifierWith:`. This method will receive an endpoint to handle and a block used to extract the identifier of a resource instance from the request. For example:
```smalltalk
builder
    handling: 'currencies'
    extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ];
```
- For non hypermedia driven controllers only implementing GET functionality over a subresource configure the builder using `handling:extractingIdentifierWith:locatingParentResourceWith:`. This method will receive additionally a resource locator to be used for locating the parent resource instance. For example:
```smalltalk
builder
    handling: 'banknotes'
    extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ]
    locatingParentResourceWith: parentRequestHandler resourceLocator;
```
- For hypermedia driven controllers or controllers implementing POST functionality over a resource you will need to configure the builder using `handling:locatingResourcesWith:extractingIdentifierWith:`. This method will require a configuration block used to produce the location of a resource instance. This block will receive the resource and must return the identifier associated to it, the library then uses the base URL and the endpoint to produce the unique URL identifying it. For example:
```smalltalk
builder
    handling: 'orders'
		locatingResourcesWith: [ :order :requestContext | ordersRepository identifierOf: order ]
		extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ];
```
- For hypermedia driven controllers or controllers implementing POST functionality over a subresource you will need to configure the builder using `handling:locatingSubresourcesWith:extractingIdentifierWith:locatingParentResourceWith:`. This method will require a configuration block used to produce the location of the subresource. This block will receive the subresource instance and can access the parent resource through the request context. For example:
```smalltalk
builder
    handling: 'comments'
		locatingSubresourcesWith: [ :comment :requestContext |
				self commentIdentifierOf: comment relatedTo: requestContext parentResource
				]
		extractingIdentifierWith: [ :httpRequest | self commentIdentifierIn: httpRequest ]
		locatingParentResourceWith: parentRequestHandler resourceLocator
```

## Hypermedia driven controllers

Controllers wanting to provide hypermedia links must configure the builder using one of the following methods:
- `beHypermediaDriven` will only produce a `self` link for the resource
- `beHypermediaDrivenBy:` requires a configuration block that will be evaluated with a link builder, the resource, the context and the resource location allowing the controller to add as many links as it wants. For example:
```smalltalk
builder
    beHypermediaDrivenBy: [ :builder :order :requestContext :orderLocation |
        builder addLink: orderLocation / 'complete' relatedTo: 'complete'
      ]
```

## ETags

Controllers must provide a way to calculate an ETag for resources configuring the builder with one of the following methods:
- `createEntityTagWith:` will receive a block that will be evaluated with the resource, the media type and the request context and must produce an ETag value
- `createEntityTagHashing:` will receive a block that will be evaluated with a `hasher`, the resource and the request context. One must include objects to be considered in the hash by sending `include:` to the hasher instance. The hasher will then produce an ETag value applying a Hash function to all the included objects.

## Collection Pagination

By default GET requests over collections will not be paginated. To get collections paginated configure the builder by sending the message `paginateCollectionsWithDefaultLimit:` providing the default page limit. A request handler will parse `start` and `limit` as query parameters during a GET request processing and will provide a pagination object.

## Exception Handling

Request handlers will handle some exceptions by default and raise it as proper HTTP errors:
- `ObjectNotFound` will raise a 404/Not Found error
- `ConflictingObjectFound` will raise a 409/Conflict error
- `KeyNotFound` and `NeoJSONParseError` will raise a 400/Bad Request error
- `TeaNoSuchParam` will raise a 400/Bad Request error

The end use can configure additional exceptions to be automatically handled by sending `handleExceptionsApplying:` to the builder. For example:
```smalltalk
builder
    handleExceptionsApplying: [ :handler |
      handler
        addAsNotFoundError: NotFound;
        addAsDecodingError: InstanceCreationFailed ];
```
