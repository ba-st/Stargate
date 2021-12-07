"
I'm a controller exposing the API of ApplicationInfoPlugin
"
Class {
	#name : #ApplicationInfoRESTfulController,
	#superclass : #OperationsRESTfulController,
	#instVars : [
		'requestHandler',
		'plugin'
	],
	#category : #'Stargate-Application-Info'
}

{ #category : #'instance creation' }
ApplicationInfoRESTfulController class >> over: anApplicationInfoPlugin configuredBy: configuration [

	^ ( self authenticationFilterBasedOn: configuration ) initializeOver: anApplicationInfoPlugin
]

{ #category : #routes }
ApplicationInfoRESTfulController >> declareGetApplicationInfoRoute [

	^ RouteSpecification
		handling: #GET
		at: self endpoint
		evaluating:
			[ :httpRequest :requestContext | self getApplicationInfoBasedOn: httpRequest within: requestContext ]
]

{ #category : #API }
ApplicationInfoRESTfulController >> getApplicationInfoBasedOn: httpRequest within: requestContext [

	self assert: httpRequest isAuthorizedWithin: requestContext.

	^ requestHandler
		from: httpRequest
		within: requestContext
		getCollection: [ plugin gatherInformation ]
]

{ #category : #initialization }
ApplicationInfoRESTfulController >> initializeOver: anApplicationInfoPlugin [

	plugin := anApplicationInfoPlugin.
	self initializeRequestHandler
]

{ #category : #initialization }
ApplicationInfoRESTfulController >> initializeRequestHandler [

	requestHandler := RESTfulRequestHandlerBuilder new
		handling: ( 'operations/<1s>' expandMacrosWith: self pluginEndpoint );
		whenResponding: self operationalApplicationInfoVersion1dot0dot0MediaType
			encodeToJsonApplying: [ :resource :requestContext :writer |  ];
		createEntityTagHashingEncodedResource;
		build
]

{ #category : #private }
ApplicationInfoRESTfulController >> operationalApplicationInfoVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'operational-application-info' vendoredBy: 'stargate' version: '1.0.0'
]

{ #category : #private }
ApplicationInfoRESTfulController >> pluginEndpoint [

	^ plugin endpoint
]

{ #category : #private }
ApplicationInfoRESTfulController >> requestHandler [

	^ requestHandler
]

{ #category : #private }
ApplicationInfoRESTfulController >> requiredPermission [

	^ 'read:<1s>' expandMacrosWith: self pluginEndpoint
]
