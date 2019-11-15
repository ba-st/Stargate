"
I'm the abstract class of the operational plugins in Stargate.
An operational plugin purpose is to provide production-ready features for the API that can be leveraged by the operations team.

An operational plugin must have the following characteristics:

- Must expose operational info
- Can allow to control some operation
- It's optional. It can be enabled by default but should be possible to disable it
- Must expose at least an endpoint to access it's functionality under /operations/{{plugin-endpoint}}
- Must be secured with a proper authorization filter. In specific situations a plugin can respond with some basic data in case there is no authorization (for example a basic healthcheck) but this behavior must be the exception to the rule.
- Should be possible to enable/disable/configure it on the fly using an API endpoint (given the proper authorization credentials) using the media controls provided in the plugin representation.

"
Class {
	#name : #OperationalPlugin,
	#superclass : #Object,
	#category : #'Stargate-Model-Operations'
}

{ #category : #accessing }
OperationalPlugin class >> availablePlugins [

	^ self allLeafSubclasses
]

{ #category : #configuring }
OperationalPlugin class >> configureMediaControlsIn: builder within: requestContext [

	self subclassResponsibility
]

{ #category : #'instance creation' }
OperationalPlugin class >> configuredBy: configuration [

	^ self subclassResponsibility
]

{ #category : #testing }
OperationalPlugin class >> enabledByDefault [

	^ false
]

{ #category : #accessing }
OperationalPlugin class >> endpoint [

	^ self subclassResponsibility
]

{ #category : #accessing }
OperationalPlugin class >> pluginAt: endpoint [

	^ self availablePlugins
		detect: [ :plugin | plugin endpoint = endpoint ]
		ifNone: [ ObjectNotFound signal: ( 'Plugin <1s> not available' expandMacrosWith: endpoint ) ]
]

{ #category : #'instance creation' }
OperationalPlugin class >> pluginConfigurationOn: configuration [

	| selfConfiguration |

	selfConfiguration := configuration at: self endpoint.

	AssertionChecker
		enforce: [ selfConfiguration at: #enabled ]
		because: 'A disabled plugin must not be configured.'.

	^ selfConfiguration
]

{ #category : #accessing }
OperationalPlugin class >> pluginName [

	^ self subclassResponsibility
]

{ #category : #configuring }
OperationalPlugin >> includeControllersIn: api [

	self subclassResponsibility
]

{ #category : #acccessing }
OperationalPlugin >> name [

	^ self class pluginName
]

{ #category : #accessing }
OperationalPlugin >> startOn: teapotServer [

	"This method is called when the server is started, giving
	the chance to the plugin to perform some start-up tasks"

	
]

{ #category : #accessing }
OperationalPlugin >> stop [

	"This method is called when the server is stopped, giving
	the chance to the plugin to perform some clean-up tasks"

	
]
