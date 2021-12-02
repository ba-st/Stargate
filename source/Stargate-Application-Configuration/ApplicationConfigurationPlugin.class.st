"
I'm one of the operational plugins.
I provide information about the configuration of the running system.
"
Class {
	#name : #ApplicationConfigurationPlugin,
	#superclass : #OperationalPlugin,
	#instVars : [
		'valueProvider',
		'configurationParameters'
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

	^ self new initializeDefinedBy: ( selfConfiguration at: #parameters ifAbsent: [ #(  ) ] )
		  querying: ( selfConfiguration at: #provider
				    ifAbsent: [ 
				    [ ApplicationConfiguration forAll: #(  ) providedBy: NullConfigurationProvider new ] ] )
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
ApplicationConfigurationPlugin >> configurationParameters [

	^ configurationParameters
]

{ #category : #private }
ApplicationConfigurationPlugin >> currentConfiguration [

	^ valueProvider value
]

{ #category : #accessing }
ApplicationConfigurationPlugin >> currentValueFor: parameter [

	^ parameter valueToLogFrom: self currentConfiguration
]

{ #category : #configuring }
ApplicationConfigurationPlugin >> includeControllersIn: api [

	api
		addController: ( ApplicationConfigurationRESTfulController over: self configuredBy: api operationsConfiguration )
]

{ #category : #initialization }
ApplicationConfigurationPlugin >> initializeDefinedBy: parameters querying: aConfigurationProvider [

	configurationParameters := parameters.
	valueProvider := aConfigurationProvider
]
