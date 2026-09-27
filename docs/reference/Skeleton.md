# API Skeletons

Since v7, Stargate brings support to easily create a Launchpad-based application
implementing an API. This API Skeleton provides a sensible plugin configuration,
global error handler configuration, and out-of-the-box logging.

## Basic setup

Create a subclass of `StargateApplication` and implement
the required subclass responsibilities:

```smalltalk
YourApplication class>>initialize

  <ignoreForCoverage>
  self initializeVersion

YourApplication class>>projectName

  ^#YourApplication

YourApplication class>>commandName

  ^'your-app'

YourApplication class>>description

  ^'My API'

YourApplication>>controllersToInstall

  ^{ ... the controllers you want to install ... }
```

Providing this minimal behavior, you will get a Launchpad-based application that:

- Will start an API with the provided controllers
- Health-check, metrics, information, configuration, control, and
  loggers plugins enabled
- On unexpected errors, it will dump a stack trace in fuel format,
  and respond with `500/Internal Server Error`
- On `Exit`, it will stop the API if successful

To see the minimal required configuration, inspect the following snippet:

```smalltalk
String streamContents: [ :s | YourApplication printHelpOn: s].
```

## Further configuration

### Stack trace generation

By default, stack traces are written in a `logs` directory relative to
the image's working directory in a filename whose name is `app-name-YYYY-MM-DD_HH-MM-SS_uuid-as-base36.dump`.

- To change the stack trace location, re-implement the `logsDirectory` class method.
- To change the stack trace file name, re-implement `fileReferenceToDumpStackTrace`
  class method
- To change the stack trace file extension, re-implement
  `stackTraceDumpExtension` class method
- To change the dump format, re-implement `stackTraceDumper` instance method

### Error responses

Outside debug mode, unexpected errors are answered with a `500/Internal Server
Error` whose body is the error's message text. To answer them differently,
re-implement the `responseForUnexpectedError:request:` instance method. The
error is still logged and its stack trace dumped.

To configure the API before it is installed, re-implement the `configureAPI:`
instance method. It receives the `HTTPBasedRESTfulAPI`, before the global error
handler is added, so error handlers added there take precedence over it. For
example, to answer client errors with problem documents:

```smalltalk
YourApplication>>configureAPI: anAPI

  anAPI handleClientErrorsWith: [ :clientError :request |
    ... build the response ... ]
```

See [how to start up an API](../how-to/how-to-startup-API.md#handle-errors) for
more on error handlers.

### Additional configuration parameters

If you need additional configuration parameters, re-implement `configurationParameters`
class method. Don't forget to perform a super send, or you will lose the
Stargate parameter configuration.

### Nest Stargate configuration under a different section

By default, Stargate configuration parameters are nested under a `Stargate` section.
If you want to use a different nesting strategy, re-implement `sectionsForStargateConfiguration`
class method and `stargateConfiguration` instance method.

### Add additional control commands

The application control plugin allows adding extra commands.

You can add new commands by doing something like:

```smalltalk
ApplicationControlPlugin
  registerAsAvailableCommand:
    ( ApplicationControlCommand
      named: 'command'
      executing: [ .. action ..])
```

and then make it available to execute by re-implementing

```smalltalk
applicationControlCommandsToEnable

  ^#('command')
```

### Change operational plugins configuration

Each operational plugin has its configuration defined in an instance method, so
you can re-implement it to disable the plugin or change the configuration.
