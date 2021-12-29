"
I'm a test case for the application-control API
"
Class {
	#name : #ApplicationControlPluginAPITest,
	#superclass : #OperationalPluginAPITest,
	#category : #'Stargate-Application-Control-Tests'
}

{ #category : #private }
ApplicationControlPluginAPITest >> echoCommandEntity [

	^ ZnEntity
		json:
			'{
	"jsonrpc" : "2.0",
	"id" : 1,
	"method" : "echo",
	"params" : [ "Hello!" ]
}'
]

{ #category : #running }
ApplicationControlPluginAPITest >> operationsConfiguration [

	^ super operationsConfiguration
		at: ApplicationControlPlugin endpoint
			put:
			( Dictionary new
				at: #enabled put: true;
				at: #commands put: #('echo');
				yourself );
		yourself
]

{ #category : #running }
ApplicationControlPluginAPITest >> requiredPermissions [

	^ #('execute:application-control')
]

{ #category : #running }
ApplicationControlPluginAPITest >> setUp [

	ApplicationControlPlugin registerAsAvailableCommand: ( ApplicationControlCommand named: 'echo'
			  withArgumentNames: #( message )
			  executing: [ :message | message ] ).
	super setUp
]

{ #category : #private }
ApplicationControlPluginAPITest >> shutdownCommandEntity [

	^ ZnEntity
		json:
			'{
	"jsonrpc" : "2.0",
	"id" : 1,
	"method" : "shutdown"
}'
]

{ #category : #running }
ApplicationControlPluginAPITest >> tearDown [

	ApplicationControlPlugin unregisterCommandNamed: 'echo'.
	super tearDown
]

{ #category : #tests }
ApplicationControlPluginAPITest >> testDisablePlugin [

	self assertIsEnabled: ApplicationControlPlugin.

	api disable: ApplicationControlPlugin.
	self assertIsDisabled: ApplicationControlPlugin.

	self
		should: [ 
			self newJWTAuthorizedClient
				url: self operationsUrl / ApplicationControlPlugin endpoint asUrl;
				entity: self echoCommandEntity;
				post;
				response
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isNotFound ]
]

{ #category : #tests }
ApplicationControlPluginAPITest >> testEnablePreviouslyDisabledPlugin [

	self assertIsEnabled: ApplicationControlPlugin.

	api disable: ApplicationControlPlugin.
	self assertIsDisabled: ApplicationControlPlugin.

	api enable: ApplicationControlPlugin.
	self assertIsEnabled: ApplicationControlPlugin.

	self testRunCommandWithPermissions
]

{ #category : #tests }
ApplicationControlPluginAPITest >> testInvalidFormat [

	| response |

	response := self newJWTAuthorizedClient
		url: self operationsUrl / ApplicationControlPlugin endpoint asUrl;
		entity: ( ZnEntity json: '' );
		post;
		response.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType equals: ZnMimeType applicationJson;
		withJsonFromContentsIn: response
			do: [ :json | 
			self
				assert: json id isNil;
				assert: json jsonrpc equals: '2.0';
				assert: ( json at: #error ) message equals: 'Internal JSON-RPC error.'
			]
]

{ #category : #tests }
ApplicationControlPluginAPITest >> testMethodNotAllowed [

	self
		should: [ self newJWTAuthorizedClient get: self operationsUrl / ApplicationControlPlugin endpoint asUrl ]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | 
			self
				assert: error response code equals: 405;
				assert: error response contents trimBoth 
					equals: 'Method Not Allowed GET /operations/application-control'
			]
]

{ #category : #tests }
ApplicationControlPluginAPITest >> testNotAcceptable [

	self
		should: [ self newJWTAuthorizedClient
				url: self operationsUrl / ApplicationControlPlugin endpoint asUrl;
				setAccept: ZnMimeType textPlain;
				entity: ( ZnEntity json: '' );
				post;
				response
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | 
			self
				assert: error response code equals: 406;
				withJsonFromContentsIn: error response
					do: [ :json | 
					self
						assert: json message
							equals: 'Cannot generate a response entity with acceptable characteristics.';
						withTheOnlyOneIn: json allowedMediaTypes
							do: [ :mediaType | self assert: mediaType equals: 'application/json' ]
					]
			]
]

{ #category : #tests }
ApplicationControlPluginAPITest >> testRunCommandWithPermissions [

	| response |

	response := self newJWTAuthorizedClient
		url: self operationsUrl / ApplicationControlPlugin endpoint asUrl;
		entity: self echoCommandEntity;
		post;
		response.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType equals: ZnMimeType applicationJson;
		withJsonFromContentsIn: response
			do: [ :json | 
			self
				assert: json id equals: 1;
				assert: json jsonrpc equals: '2.0';
				assert: json result equals: 'Hello!'
			]
]

{ #category : #tests }
ApplicationControlPluginAPITest >> testRunCommandWithoutAuthentication [

	self
		should: [ self newClient
				url: self operationsUrl / ApplicationControlPlugin endpoint asUrl;
				entity: self echoCommandEntity;
				post;
				response
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response code equals: 401 ]
]

{ #category : #tests }
ApplicationControlPluginAPITest >> testRunCommandWithoutPermissions [

	self
		should: [ self newJWTAuthorizedClientLackingPermissions
				url: self operationsUrl / ApplicationControlPlugin endpoint asUrl;
				entity: self echoCommandEntity;
				post;
				response
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response code equals: 403 ]
]

{ #category : #tests }
ApplicationControlPluginAPITest >> testRunDisabledCommandWithPermissions [

	| response |

	response := self newJWTAuthorizedClient
		url: self operationsUrl / ApplicationControlPlugin endpoint asUrl;
		entity: self shutdownCommandEntity;
		post;
		response.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType equals: ZnMimeType applicationJson;
		withJsonFromContentsIn: response
			do: [ :json | 
			self
				assert: json id equals: 1;
				assert: json jsonrpc equals: '2.0';
				assert: ( json at: #error ) message equals: 'The method does not exist / is not available.'
			]
]

{ #category : #tests }
ApplicationControlPluginAPITest >> testRunUnknownCommandWithPermissions [

	| response |

	response := self newJWTAuthorizedClient
		url: self operationsUrl / ApplicationControlPlugin endpoint asUrl;
		entity: self unknownCommandEntity;
		post;
		response.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType equals: ZnMimeType applicationJson;
		withJsonFromContentsIn: response
			do: [ :json | 
			self
				assert: json id equals: 1;
				assert: json jsonrpc equals: '2.0';
				assert: ( json at: #error ) message equals: 'The method does not exist / is not available.'
			]
]

{ #category : #tests }
ApplicationControlPluginAPITest >> testUnsupportedMediaType [

	self
		should: [ self newJWTAuthorizedClient
				url: self operationsUrl / ApplicationControlPlugin endpoint asUrl;
				entity: ( ZnEntity text: '' );
				post;
				response
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | 
			self
				assert: error response code equals: 415;
				withJsonFromContentsIn: error response
					do: [ :json | self assert: json message equals: 'The request Content-Type must be application/json' ]
			]
]

{ #category : #private }
ApplicationControlPluginAPITest >> unknownCommandEntity [

	^ ZnEntity
		json:
			'{
	"jsonrpc" : "2.0",
	"id" : 1,
	"method" : "xxx"
}'
]
