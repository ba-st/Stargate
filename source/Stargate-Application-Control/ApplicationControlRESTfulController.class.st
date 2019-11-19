"
I'm a controller exposing the API of ApplicationControlPlugin
"
Class {
	#name : #ApplicationControlRESTfulController,
	#superclass : #OperationsRESTfulController,
	#instVars : [
		'requestHandler',
		'plugin'
	],
	#category : #'Stargate-Application-Control'
}

{ #category : #'instance creation' }
ApplicationControlRESTfulController class >> over: anApplicationControlPlugin configuredBy: configuration [

	^ ( self authenticationFilterBasedOn: configuration ) initializeOver: anApplicationControlPlugin
]

{ #category : #routes }
ApplicationControlRESTfulController >> declareRunApplicationControlMethodRoute [

	^ RouteSpecification
		handling: #POST
		at: self endpoint
		evaluating: [ :httpRequest :requestContext | self runApplicationControlMethodBasedOn: httpRequest within: requestContext ]
]

{ #category : #initialization }
ApplicationControlRESTfulController >> initializeOver: anApplicationControlPlugin [

	plugin := anApplicationControlPlugin.
	requestHandler := JsonRPCRequestHandler
		handling: ( 'operations/<1s>' expandMacrosWith: self pluginEndpoint ).
	plugin configureHandlersIn: requestHandler
]

{ #category : #private }
ApplicationControlRESTfulController >> pluginEndpoint [

	^ plugin class endpoint
]

{ #category : #private }
ApplicationControlRESTfulController >> requestHandler [

	^ requestHandler
]

{ #category : #private }
ApplicationControlRESTfulController >> requiredPermission [

	^ 'execute:<1s>' expandMacrosWith: self pluginEndpoint
]

{ #category : #API }
ApplicationControlRESTfulController >> runApplicationControlMethodBasedOn: httpRequest within: requestContext [

	self assert: httpRequest isAuthorizedWithin: requestContext.
	^ requestHandler process: httpRequest within: requestContext
]
