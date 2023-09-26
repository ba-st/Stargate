"
I'm one of the operational plugins.
I provide information of the active loggers in the system

"
Class {
	#name : 'LoggersPlugin',
	#superclass : 'OperationalPlugin',
	#instVars : [
		'beacon'
	],
	#category : 'Stargate-Loggers',
	#package : 'Stargate-Loggers'
}

{ #category : 'accessing' }
LoggersPlugin class >> configureMediaControlsIn: builder within: requestContext [

	builder
		addRelativeLink: ( 'operations/<1s>' expandMacrosWith: self endpoint ) asUrl
		relatedTo: 'loggers'
]

{ #category : 'accessing' }
LoggersPlugin class >> configuredBy: configuration [

	| selfConfiguration |

	selfConfiguration := self pluginConfigurationOn: configuration.

	^ self new initializeWith: ( selfConfiguration at: #beacon ifAbsent: [ Beacon instance ] )
]

{ #category : 'accessing' }
LoggersPlugin class >> endpoint [

	^ 'loggers'
]

{ #category : 'accessing' }
LoggersPlugin class >> pluginName [

	^ 'Loggers'
]

{ #category : 'accessing' }
LoggersPlugin >> activeLoggerNamed: aName [

	^ self activeLoggers detect: [ :logger | logger name = aName ]
		  ifNone: [ ObjectNotFound signal: ( 'There''s no logger named <1s>' expandMacrosWith: aName ) ]
]

{ #category : 'accessing' }
LoggersPlugin >> activeLoggers [

	^ beacon loggers
]

{ #category : 'configuring' }
LoggersPlugin >> includeControllersIn: api [

	api addController:
		( LoggersRESTfulController over: self configuredBy: api operationsConfiguration )
]

{ #category : 'initialization' }
LoggersPlugin >> initializeWith: aBeaconInstance [

	beacon := aBeaconInstance 
]
