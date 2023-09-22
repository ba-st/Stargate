Class {
	#name : 'LoggersPluginAPITest',
	#superclass : 'OperationalPluginAPITest',
	#instVars : [
		'beacon'
	],
	#category : 'Stargate-Loggers-Tests',
	#package : 'Stargate-Loggers-Tests'
}

{ #category : 'running' }
LoggersPluginAPITest >> operationsConfiguration [

	^ super operationsConfiguration
		  at: LoggersPlugin endpoint put: ( Dictionary new
				    at: #enabled put: true;
				    at: #beacon put: beacon;
				    yourself );
		  yourself
]

{ #category : 'running' }
LoggersPluginAPITest >> requiredPermissions [

	^ #('read:loggers')
]

{ #category : 'initialization' }
LoggersPluginAPITest >> setUp [

	beacon := Beacon new.
	super setUp
]

{ #category : 'private - support' }
LoggersPluginAPITest >> startLoggersDuring: aBlock [

	| stderrLogger |

	stderrLogger := StandardStreamLogger onStandardErrorFor: beacon.
	stderrLogger name: self stderrLoggerName.

	[ 
	stderrLogger startFor: ( LogRecord where: [ :record | record isInformational not ] ).
	aBlock value
	] ensure: [ stderrLogger stop ]
]

{ #category : 'private - support' }
LoggersPluginAPITest >> stderrLoggerName [

	^ 'stderr-logger'
]

{ #category : 'running' }
LoggersPluginAPITest >> tearDown [

	beacon announcer subscriptions reset.
	super tearDown
]

{ #category : 'running' }
LoggersPluginAPITest >> testDisablePlugin [

	self assertIsEnabled: LoggersPlugin.

	api disable: LoggersPlugin.
	self assertIsDisabled: LoggersPlugin.

	self
		should: [ 
			self newJWTAuthorizedClient
				url: self operationsUrl / LoggersPlugin endpoint asUrl;
				setAccept: ZnMimeType applicationJson;
				get;
				response
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isNotFound ]
]

{ #category : 'running' }
LoggersPluginAPITest >> testEnablePreviouslyDisabledPlugin [

	self assertIsEnabled: LoggersPlugin.

	api disable: LoggersPlugin.
	self assertIsDisabled: LoggersPlugin.

	api enable: LoggersPlugin.
	self assertIsEnabled: LoggersPlugin.

	self testGetLoggerWithPermissions
]

{ #category : 'running' }
LoggersPluginAPITest >> testGetLoggerMissingPermissions [

	self
		should: [ 
			self newJWTAuthorizedClientLackingPermissions
				url: self operationsUrl / LoggersPlugin endpoint asUrl / self stderrLoggerName;
				setAccept: ZnMimeType applicationJson;
				get;
				response
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response code equals: 403 ]
]

{ #category : 'running' }
LoggersPluginAPITest >> testGetLoggerNotFound [

	self
		should: [ 
			self newJWTAuthorizedClient
				url: self operationsUrl / LoggersPlugin endpoint asUrl / self stderrLoggerName;
				setAccept: ZnMimeType applicationJson;
				get;
				response
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isNotFound ]
]

{ #category : 'running' }
LoggersPluginAPITest >> testGetLoggerWithPermissions [

	self startLoggersDuring: [ 
		| response |

		response := self newJWTAuthorizedClient
			            url: self operationsUrl / LoggersPlugin endpoint asUrl / self stderrLoggerName;
			            setAccept: ZnMimeType applicationJson;
			            get;
			            response.

		self
			assert: response isSuccess;
			assert: response contentType asMediaType
			equals: 'application/vnd.stargate.logger+json;version=1.0.0' asMediaType;
			withJsonFromContentsIn: response
			do: [ :json | self assert: json name equals: self stderrLoggerName ]
		]
]

{ #category : 'running' }
LoggersPluginAPITest >> testGetLoggersMissingPermissions [

	self
		should: [ 
			self newJWTAuthorizedClientLackingPermissions
				url: self operationsUrl / LoggersPlugin endpoint asUrl;
				setAccept: ZnMimeType applicationJson;
				get;
				response
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response code equals: 403 ]
]

{ #category : 'running' }
LoggersPluginAPITest >> testGetLoggersWhenNotEmptyWithPermissions [

	self startLoggersDuring: [ 
		| response |

		response := self newJWTAuthorizedClient
			            url: self operationsUrl / LoggersPlugin endpoint asUrl;
			            setAccept: ZnMimeType applicationJson;
			            get;
			            response.

		self
			assert: response isSuccess;
			assert: response contentType asMediaType
			equals: 'application/vnd.stargate.logger+json;version=1.0.0' asMediaType;
			withJsonFromContentsIn: response do: [ :json | 
				self withTheOnlyOneIn: json items do: [ :logger | 
						self
							assert: logger name equals: 'stderr-logger';
							assert: logger typeDescription equals: 'stderr';
							assert: ( logger selfLocation endsWith: logger name )
						]
				]
		]
]

{ #category : 'running' }
LoggersPluginAPITest >> testGetLoggersWithPermissions [

	| response |

	response := self newJWTAuthorizedClient
		            url: self operationsUrl / LoggersPlugin endpoint asUrl;
		            setAccept: ZnMimeType applicationJson;
		            get;
		            response.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType
		equals: 'application/vnd.stargate.logger+json;version=1.0.0' asMediaType;
		withJsonFromContentsIn: response do: [ :json | self assert: json items isEmpty ]
]
