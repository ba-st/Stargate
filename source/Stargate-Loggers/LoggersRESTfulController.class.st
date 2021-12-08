"
I'm a controller exposing the API of LoggersPlugin
"
Class {
	#name : #LoggersRESTfulController,
	#superclass : #OperationsRESTfulController,
	#instVars : [
		'requestHandler',
		'plugin'
	],
	#category : #'Stargate-Loggers'
}

{ #category : #'instance creation' }
LoggersRESTfulController class >> over: aLoggersPlugin configuredBy: configuration [

	^ ( self authenticationFilterBasedOn: configuration ) initializeOver: aLoggersPlugin
]

{ #category : #routes }
LoggersRESTfulController >> declareGetLoggerRoute [

	^ RouteSpecification
		handling: #GET
		at: self identifierTemplate
		evaluating: [ :httpRequest :requestContext | self getLoggerBasedOn: httpRequest within: requestContext ]
]

{ #category : #routes }
LoggersRESTfulController >> declareGetLoggersRoute [

	^ RouteSpecification
		handling: #GET
		at: self endpoint
		evaluating: [ :httpRequest :requestContext | self getLoggersBasedOn: httpRequest within: requestContext ]
]

{ #category : #API }
LoggersRESTfulController >> getLoggerBasedOn: httpRequest within: requestContext [

	self assert: httpRequest isAuthorizedWithin: requestContext.
	^ requestHandler from: httpRequest
		  within: requestContext
		  get: [ :name | plugin activeLoggerNamed: name ]
]

{ #category : #API }
LoggersRESTfulController >> getLoggersBasedOn: httpRequest within: requestContext [

	self assert: httpRequest isAuthorizedWithin: requestContext.
	^ requestHandler from: httpRequest within: requestContext getCollection: [ plugin activeLoggers ]
]

{ #category : #initialization }
LoggersRESTfulController >> initializeOver: aLoggersPlugin [

	plugin := aLoggersPlugin.
	self initializeRequestHandler
]

{ #category : #initialization }
LoggersRESTfulController >> initializeRequestHandler [

	requestHandler := RESTfulRequestHandlerBuilder new
		                  handling: ( 'operations/<1s>' expandMacrosWith: self pluginEndpoint )
		                  locatingResourcesWith: [ :logger :requestContext | logger name ]
		                  extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ];
		                  beHypermediaDriven;
		                  whenResponding: self loggerVersion1dor0dot0MediaType
		                  encodeToJsonApplying: [ :resource :requestContext :writer | 
			                  SignalLogger availableInStargate do: [ :loggerClass | 
					                  writer for: loggerClass do: [ :mapping | 
							                  mapping
								                  mapAccessor: #name;
								                  mapAccessor: #typeDescription;
								                  mapAsHypermediaControls: [ :logger | 
									                  requestContext hypermediaControlsFor: logger ]
							                  ]
					                  ]
			                  ];
		                  createEntityTagHashing: [ :hasher :logger :requestContext | 
			                  hasher
				                  include: logger name;
				                  include: logger typeDescription
			                  ];
		                  build
]

{ #category : #private }
LoggersRESTfulController >> loggerVersion1dor0dot0MediaType [
	
	^ self jsonMediaType: 'logger' vendoredBy: 'stargate' version: '1.0.0'
]

{ #category : #private }
LoggersRESTfulController >> pluginEndpoint [

	^ plugin endpoint
]

{ #category : #private }
LoggersRESTfulController >> requestHandler [

	^ requestHandler
]

{ #category : #private }
LoggersRESTfulController >> requiredPermission [

	^ 'read:<1s>' expandMacrosWith: self pluginEndpoint
]
