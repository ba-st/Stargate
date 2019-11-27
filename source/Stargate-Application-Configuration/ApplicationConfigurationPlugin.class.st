"
I'm one of the operational plugins.
I provide information about the configuration of the running system.
"
Class {
	#name : #ApplicationConfigurationPlugin,
	#superclass : #OperationalPlugin,
	#instVars : [
		'valueProvider',
		'configurationDefinitions'
	],
	#category : #'Stargate-Application-Configuration'
}

{ #category : #configuring }
ApplicationConfigurationPlugin class >> configureMediaControlsIn: builder within: requestContext [

	builder
		addRelativeLink: ( 'operations/<1s>' expandMacrosWith: self endpoint ) asUrl
		relatedTo: 'configuration'
]

{ #category : #'instance creation' }
ApplicationConfigurationPlugin class >> configuredBy: configuration [

	| selfConfiguration |

	selfConfiguration := self pluginConfigurationOn: configuration.

	^ self new
		initializeDefinedBy: ( selfConfiguration at: #definitions ifAbsent: [ #() ] )
		querying: ( selfConfiguration at: #provider ifAbsent: [ [ Dictionary new ] ] )
]

{ #category : #accessing }
ApplicationConfigurationPlugin class >> endpoint [

	^ 'application-configuration'
]

{ #category : #accessing }
ApplicationConfigurationPlugin class >> pluginName [

	^ 'Application Configuration'
]

{ #category : #accessing }
ApplicationConfigurationPlugin >> configurationDefinitions [

	^ configurationDefinitions
]

{ #category : #accessing }
ApplicationConfigurationPlugin >> currentValueFor: aDefinition [

	^ valueProvider value at: aDefinition name 
]

{ #category : #configuring }
ApplicationConfigurationPlugin >> includeControllersIn: api [

	api
		addController: ( ApplicationConfigurationRESTfulController over: self configuredBy: api operationsConfiguration )
]

{ #category : #initialization }
ApplicationConfigurationPlugin >> initializeDefinedBy: configurationDefinition querying: aConfigurationProvider [

	configurationDefinitions := configurationDefinition.
	valueProvider := aConfigurationProvider
]
