# Migration Guide

## Migration from v12 to v13

### Code changes

- `TeaResponse class >> noContent`, an extension in
  `Stargate-Teapot-Extensions`, is removed. Use `ZnResponse noContent`
  instead, for example when aborting a request with `abort:`.
- Error handlers must answer a `ZnResponse`. The API now applies the
  cross-origin resource sharing configuration to the response of every error
  handler, which fails for any other object.
- Error handlers no longer need to call
  `applyCrossSharingResourceConfigurationTo:accordingTo:` themselves. Calls
  left in place still work, and don't repeat any header.
- A handler added with `on: HTTPClientError addErrorHandler:` was never
  reached, because the API's own client error handler runs first. To answer
  client errors differently, add a `#clientErrorHandler` to the API's
  configuration instead. In a `StargateApplication`, re-implement
  `apiConfiguration` and add it to the result of the super send.
- `StargateApplication` has two new hooks:
  - `responseForUnexpectedError:request:` builds the response to unexpected
    errors. It defaults to the `500/Internal Server Error` answered before.
  - `configureAPI:` receives the API before the global error handler is added,
    so error handlers added there take precedence over it.

  See [how to start up an API](how-to/how-to-startup-API.md#handle-errors) and
  [the API skeleton](reference/Skeleton.md#error-responses).
- `ZnHeaders >> at:addSeparatedWithComma:`, an extension in
  `Stargate-Zinc-Extensions`, is removed. Send Hyperspace's `at:addToList:`
  instead, which also combines a field already stored as several lines.
- The class-side constructors of `RESTfulRequestHandler` and
  `HypermediaDrivenRESTfulRequestHandler` take a new
  `collectionValidationPolicy:` argument, after `paginationPolicy:`. Only code
  calling them directly, instead of through `RESTfulRequestHandlerBuilder`,
  has to change. To keep answering collections without ETags, pass:

  ```smalltalk
  [ :requestHandler |
    RESTfulControllerDoNotValidateCollectionsPolicy for: requestHandler ]
  ```

- `AllowOriginPolicy >> applyOn:for:using:` is replaced by
  `applyOn:for:using:ifNotAllowed:`, and subclasses must implement
  `addToVaryOn:using:`. This only affects code subclassing `AllowOriginPolicy`.

### Response changes

These don't need code changes, but clients, and tests asserting exact headers
or status codes, can notice them:

- Conditional requests follow
  [RFC 9110](https://www.rfc-editor.org/rfc/rfc9110#section-13.1) more
  closely:
  - `If-Match` uses the strong comparison, so a weak tag in it is answered
    `412 Precondition Failed`. Some proxies weaken ETags, for example nginx
    when it compresses a response.
  - `If-None-Match` on an update is evaluated before applying it, so a tag
    matching the current representation, or `*`, is answered `412` instead of
    applying the change.
  - Update preconditions are evaluated against the representation the
    response would carry. An update sending an `Accept` or `Accept-Language`
    other than the one its `If-Match` tag was read with is answered `412`:
    send the same negotiation headers used to read it. Updates without them
    are compared in the media type and language of their content.
- ETags from handlers that negotiate languages include the language, so they
  all change once on upgrade: clients get a full `200 OK` instead of a `304`
  once, and an update in flight with an old tag gets a `412` once.
- `Vary` names more headers: `Origin` on every response when cross-origin
  requests are allowed only from specific origins, and `Authorization` on every
  response of a route or API authenticated with `authenticatedBy:`, except
  those answered by an error handler.
- A request whose `Origin` isn't allowed gets the response without CORS
  headers, instead of an empty `204 No Content`. Browsers still refuse it,
  since it doesn't allow their origin.
- A `304 Not Modified` carries the `Cache-Control` and `Expires` its `200 OK`
  would have, and no longer carries `Content-Language`.
- Client error bodies include the data attached to the error with
  Hyperspace's `additionalDataAt:put:`, and omit fields with no value:
  - A `401` or `403` without an error code has no `errorCode`, instead of
    `"errorCode": null`.
  - A `406` with no languages to offer has no `allowedLanguageTags`, and one
    with no media types has no `allowedMediaTypes`.
- A `415 Unsupported Media Type` answered because no decoding rule matches
  the request lists the media types that have one in `acceptedMediaTypes`, and
  its message changes from `Decoder not found for given media type` to
  `Cannot decode a request body of media type <type>.`, or
  `The request body has no media type.` when the request has no
  `Content-Type`. A `415` from a JSON-RPC endpoint lists `application/json`.

## Migration from v7/8 to v9

- Pharo 8 and 9 support is deprecated, use Pharo 10 or 11.
- `StargateApplication class >> #applicationBaselineName` is replaced by
  `#projectName`.
  - For Pharo it will be concatenated to `BaselineOf` to
  search for the Baseline package when initializing the version.
  - For GS64 it will be used as the project name to search in the Rowan
  registry.
- `StargateApplication>>#stackTraceDumper` changed the default
  implementation to create a `StackTraceTextDumper` instead of the
  binary version. If you want to continue using the dumper as before,
  reimplement it with:

  ```smalltalk
  stackTraceDumper

  ^ StackTraceBinarySerializer on: [ :dumpAction | 
    self class fileReferenceToDumpStackTrace binaryWriteStreamDo: dumpAction ]
  ```

- `StargateApplication class >> fileReferenceToDumpStackTrace` changed
  the file naming convention. Now the produced file includes:
  - the command name used to start the application
  - the current timestamp
  - a UUID encoded in Base-36

  The new implementation will also check that the file to use doesn't
  exist before dumping information on it.
- `stackTraceDumpExtension` is introduced in `StargateApplication` so
  users can now specify a different file extension for the trace dumps.
- This version adds support for GemStone/S 64 bits 3.7.0, keep
  in mind that `String` and `Symbol` instances do not compare for equality
  like Pharo. Be careful when accessing header names in the request or
  response abstractions, for maximum compatibility strings must be used as keys.

## Migration from v6 to v7

- Pharo 7 support is now deprecated, use Pharo 8 or 9.
- There's a new `Loggers` group in the baseline that's included now by default in
  the `Deployment` group.
- The garbage collector invocation count metric changed its name, both
  in Prometheus and JSON formats
  - `garbage_collector_invokations` is now `garbage_collector_invocations`
  - `Garbage Collector invokations` is now `Garbage Collector invocations`

  This name change can impact previously collected metrics or filters
- Dependencies updated:
  - [`Launchpad`](https://github.com/ba-st/Launchpad) was updated to v4
  - [`ZTimestamp`](https://github.com/svenvc/ztimestamp) is now a dependency
- The application configuration plugin now needs that the `#provider` option
  evaluates to an instance of `ApplicationConfiguration`

## Migration from v5 to v6

Migration of APIs using CORS will be performed automatically via rewrite
expressions. To achieve this, manually load the package `Stargate-Deprecated-V6`.

## Migration from v2 to v3

Some changes can be automatically migrated from v2:

Manually load the package `Stargate-Deprecated-V3`. It includes deprecation rules,
some of them with automatic rewrite expressions.

Other changes cannot be migrated in an automated fashion:

- `ResourceRESTfulController` remains but his purpose has changed. The only
  mandatory thing you need to declare is the routes to install (You can
  adapt it from the specification, and changing the blocks removing the
  first argument that now will be `self`). You now will collaborate with a
  resource handler to resolve the different methods, and you can easily
  configure it by using: `RESTfulRequestHandlerBuilder`.
- If your controller was handling only one resource you should subclass
  `SingleResourceRESTfulController` instead.
- `ResourceRESTfulControllerSpecification` is now deprecated so if you have
  subclasses you need to adapt the code to the new structure.
- The mapping rules you have defined in the specification are now
  deprecated. But you can reuse the mappings configuring the `requestHandlerBuilder`.
- Hypermedia controls support in the context must be always tied to some
  object, so the methods supporting hypermedia controls not attached to
  anything are deprecated.
- `holdAsHypermediaControls:forSubresource:` was replaced by `holdAsHypermediaControls:for:`
- `addPaginationControl:` was replaced by `addPaginationControls:` that
  provides a builder to ease the control creation.
- All the methods that were `subclassResponsibility` on
  `ResourceRESTfulController` are no longer needed, now you must configure
  the builder to create a request handler with the desired behavior.

## Migration from v1 to v2

Some changes can be automatically migrated from v1:

Manually load the package `Stargate-MigrationTo2`. It will include deprecations
including automatic rewrite expressions, so if you execute the code it will get
converted to the new versions.

Other changes cannot be migrated in an automated fashion, but are easy to do:

Subclasses of `ResourceRESTfulController` must contemplate the following changes:

- `entityTagOf:encodedAs:` is now `entityTagOf:encodedAs:within:` and receives
  the context as argument
- `locationOf:` is now `locationOf:within:` and receives the context as argument
- `mediaControlsFor:` is now `mediaControlsFor:within:` and receives the context
  as an argument
- `provideResourceCreationPolicy` is now a subclass responsibility

For the methods including the new argument, you can use your old implementation
and ignore the context argument (Just change the method signature). For the
remaining `subclassResponsibility` implement it as:

```smalltalk
provideResourceCreationPolicy

  ^ RESTfulControllerDoNotRespondCreatedEntityPolicy for: self
```
