"
I'm one of the operational plugins.
I provide commands that can be executed to control the running application.
"
Class {
	#name : #ApplicationControlPlugin,
	#superclass : #OperationalPlugin,
	#instVars : [
		'commands',
		'configuration'
	],
	#classVars : [
		'AvailableCommands'
	],
	#category : #'Stargate-Application-Control'
}

{ #category : #accessing }
ApplicationControlPlugin class >> availableCommands [

	^ AvailableCommands copy
]

{ #category : #configuring }
ApplicationControlPlugin class >> configureMediaControlsIn: builder within: requestContext [

	builder
		addRelativeLink: ( 'operations/<1s>' expandMacrosWith: self endpoint ) asUrl
		relatedTo: 'run'
]

{ #category : #'instance creation' }
ApplicationControlPlugin class >> configuredBy: configuration [

	^ self new initializeConfiguredBy: ( self pluginConfigurationOn: configuration )
]

{ #category : #accessing }
ApplicationControlPlugin class >> endpoint [

	^ 'application-control'
]

{ #category : #'class initialization' }
ApplicationControlPlugin class >> initialize [

	<ignoreForCoverage>
	AvailableCommands := OrderedCollection new.
	self
		registerAsAvailableCommand:
			( ApplicationControlCommand
				named: 'shutdown'
				executing: [ Exit signalSuccess: 'Remote SHUTDOWN command was received.' ] )
]

{ #category : #accessing }
ApplicationControlPlugin class >> pluginName [

	^ 'Application Control'
]

{ #category : #configuring }
ApplicationControlPlugin class >> registerAsAvailableCommand: anApplicationControlCommand [

	AvailableCommands add: anApplicationControlCommand
]

{ #category : #configuring }
ApplicationControlPlugin class >> unregisterCommandNamed: aMethodName [

	AvailableCommands removeAllSuchThat: [ :command | command methodName = aMethodName ]
]

{ #category : #configuring }
ApplicationControlPlugin >> configureHandlersIn: aJsonRPCRequestHandler [

	commands do: [ :command | command addTo: aJsonRPCRequestHandler ].
	configuration at: #debugMode ifPresent: [ :boolean | aJsonRPCRequestHandler debugMode: boolean ]
]

{ #category : #configuring }
ApplicationControlPlugin >> includeControllersIn: api [

	api addController:
		( ApplicationControlRESTfulController over: self configuredBy: api operationsConfiguration )
]

{ #category : #initialization }
ApplicationControlPlugin >> initializeCommands [

	| enabledCommandNames |

	enabledCommandNames := configuration at: #commands ifAbsent: [ #(  ) ].
	commands := self class availableCommands select: [ :command | 
		            enabledCommandNames includes: command methodName ]
]

{ #category : #initialization }
ApplicationControlPlugin >> initializeConfiguredBy: pluginConfiguration [

	configuration := pluginConfiguration.
	self initializeCommands
]
