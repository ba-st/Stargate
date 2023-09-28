# Migration Guide

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
