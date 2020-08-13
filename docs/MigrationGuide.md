# Migration Guide

## Migration from v5 to v6

Migration of APIs using CORS will be performed automatically via rewrite rule. To achieve this, manually load the package `Stargate-Deprecated-V6`.

## Migration from v2 to v3

Some changes can be automatically migrated from v2:

Manually load the package `Stargate-Deprecated-V3`. It includes deprecations, some of them with automatic rewrite expressions.

Other changes cannot be migrated in an automated fashion:

- `ResourceRESTfulController` remains but his purpose has changed. The only mandatory thing you need to declare are the routes to install (You can adapt it from the specification, and changing the blocks removing the first argument that now will be `self`). You now will collaborate with a resource handler to resolve the different methods, and you can easily configure it by using: `RESTfulRequestHandlerBuilder`.
- If your controller was handling only one resource you should subclass `SingleResourceRESTfulController` instead.
- `ResourceRESTfulControllerSpecification` is now deprecated so if you have subclasses you need to adapt the code to the new structure.
- The mapping rules you have defined in the specification are now deprecated. But you can reuse the mappings configuring the requestHandlerBuilder.
- Hypermedia controls support in the context must be always tied to some object, so the methods supporting hypermedia controls not attached to anything are deprecated.
- `holdAsHypermediaControls:forSubresource:` was replaced by `holdAsHypermediaControls:for:`
- `addPaginationControl:` was replaced by `addPaginationControls:` that provides a builder to ease the control creation.
- All the methods that were subclassResponsibility on `ResourceRESTfulController` are no longer needed, now you must configure the builder to create a request handler with the desired behavior.

## Migration from v1 to v2

Some changes can be automatically migrated from v1:

Manually load the package `Stargate-MigrationTo2`. It will include deprecations including automatic rewrite expressions, so if you execute the code it will get converted to the new versions.

Other changes cannot be migrated in an automated fashion, but are easy to do:

Subclasses of `ResourceRESTfulController` must contemplate the following changes:
- `entityTagOf:encodedAs:` is now `entityTagOf:encodedAs:within:` and receives the context as argument
- `locationOf:` is now `locationOf:within:` and receives the context as argument
- `mediaControlsFor:` is now `mediaControlsFor:within:` and receives the context as argument
- `provideResourceCreationPolicy` is now a subclass responsibility

For the methods including the new argument, you can use your old implementation and ignore the context argument (Just change the method signature). For the remaining subclassResponsibility implement it as:

```smalltalk
provideResourceCreationPolicy

	^ RESTfulControllerDoNotRespondCreatedEntityPolicy for: self
```
