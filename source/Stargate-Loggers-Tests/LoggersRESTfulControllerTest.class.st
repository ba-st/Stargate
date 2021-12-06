"
A LoggersRESTfulControllerTest is a test class for testing the behavior of LoggersRESTfulController
"
Class {
	#name : #LoggersRESTfulControllerTest,
	#superclass : #OperationalPluginRESTfulControllerTest,
	#instVars : [
		'beacon'
	],
	#category : #'Stargate-Loggers-Tests'
}

{ #category : #'private - support' }
LoggersRESTfulControllerTest >> operationsConfiguration [

	^ super operationsConfiguration
		  at: LoggersPlugin endpoint put: ( Dictionary new
				    at: #enabled put: true;
				    at: #beacon put: beacon;
				    yourself );
		  yourself
]

{ #category : #running }
LoggersRESTfulControllerTest >> setUp [
	
	beacon := Beacon new.
	super setUp.
]

{ #category : #running }
LoggersRESTfulControllerTest >> setUpResourceController [

	resourceController := LoggersRESTfulController over:
		                      ( LoggersPlugin configuredBy: self operationsConfiguration )
		                      configuredBy: self operationsConfiguration
]

{ #category : #'private - support' }
LoggersRESTfulControllerTest >> startLoggersDuring: aBlock [

	| stdoutLogger stderrLogger |

	stdoutLogger := StandardStreamLogger onStandardOutputFor: beacon.
	stderrLogger := StandardStreamLogger onStandardErrorFor: beacon.

	stdoutLogger name: self stdoutLoggerName.
	stderrLogger name: self stderrLoggerName.

	[ 
	stdoutLogger startFor: ( LaunchpadLogRecord where: [ :record | record isInformational ] ).
	stderrLogger startFor: ( LaunchpadLogRecord where: [ :record | record isInformational not ] ).
	aBlock value
	] ensure: [ 
		stdoutLogger stop.
		stderrLogger stop
		]
]

{ #category : #'private - support' }
LoggersRESTfulControllerTest >> stderrLoggerName [

	^ 'stderr-logger'
]

{ #category : #'private - support' }
LoggersRESTfulControllerTest >> stdoutLoggerName [

	^ 'stdout-logger'
]

{ #category : #running }
LoggersRESTfulControllerTest >> tearDown [

	super tearDown.
	beacon announcer subscriptions reset
]

{ #category : #tests }
LoggersRESTfulControllerTest >> testGetLoggerWhenNotFound [

	self
		should: [ 
			resourceController
				getLoggerBasedOn: ( self requestToGETResourceIdentifiedBy: 'stderr'
						  accepting: resourceController loggerVersion1dor0dot0MediaType )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError notFound
]

{ #category : #tests }
LoggersRESTfulControllerTest >> testGetLoggersWhenEmpty [

	| response |

	self assert: beacon loggers isEmpty.

	response := resourceController getLoggersBasedOn:
		            ( self requestToGET: self resourceUrl
			              accepting: resourceController loggerVersion1dor0dot0MediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType
		equals: resourceController loggerVersion1dor0dot0MediaType;
		withJsonFromItemsIn: response do: [ :loggers | self assert: loggers isEmpty ]
]

{ #category : #tests }
LoggersRESTfulControllerTest >> testGetLoggersWhenNotEmpty [

	self startLoggersDuring: [ 
		| response |

		self deny: beacon loggers isEmpty.

		response := resourceController getLoggersBasedOn:
			            ( self requestToGET: self resourceUrl
				              accepting: resourceController loggerVersion1dor0dot0MediaType )
			            within: self newHttpRequestContext.

		self
			assert: response isSuccess;
			assert: response contentType asMediaType
			equals: resourceController loggerVersion1dor0dot0MediaType;
			withJsonFromItemsIn: response do: [ :loggers | 
				self assert: loggers size equals: 2.
				loggers
					detect: [ :logger | logger name = self stdoutLoggerName ]
					ifFound: [ :logger | 
						self
							assert: logger typeDescription equals: 'stdout';
							assert: logger selfLocation equals: 'https://api.example.com/operations/loggers/stdout-logger'
						]
					ifNone: [ self fail ].
				loggers
					detect: [ :logger | logger name = self stderrLoggerName ]
					ifFound: [ :logger | 
						self
							assert: logger typeDescription equals: 'stderr';
							assert: logger selfLocation equals: 'https://api.example.com/operations/loggers/stderr-logger'
						]
					ifNone: [ self fail ]
				]
		]
]

{ #category : #tests }
LoggersRESTfulControllerTest >> testGetStderrLogger [

	self startLoggersDuring: [ 
		| response |

		self deny: beacon loggers isEmpty.

		response := resourceController
			            getLoggerBasedOn: ( self requestToGETResourceIdentifiedBy: self stderrLoggerName
					              accepting: resourceController loggerVersion1dor0dot0MediaType )
			            within: self newHttpRequestContext.

		self
			assert: response isSuccess;
			assert: response contentType asMediaType
			equals: resourceController loggerVersion1dor0dot0MediaType;
			withJsonFromContentsIn: response do: [ :logger | 
				self
					assert: logger name equals: self stderrLoggerName;
					assert: logger typeDescription equals: 'stderr';
					assert: logger selfLocation equals: 'https://api.example.com/operations/loggers/stderr-logger'
				]
		]
]

{ #category : #tests }
LoggersRESTfulControllerTest >> testGetStdoutLogger [

	self startLoggersDuring: [ 
		| response |

		self deny: beacon loggers isEmpty.

		response := resourceController
			            getLoggerBasedOn: ( self requestToGETResourceIdentifiedBy: self stdoutLoggerName
					              accepting: resourceController loggerVersion1dor0dot0MediaType )
			            within: self newHttpRequestContext.

		self
			assert: response isSuccess;
			assert: response contentType asMediaType
			equals: resourceController loggerVersion1dor0dot0MediaType;
			withJsonFromContentsIn: response do: [ :logger | 
				self
					assert: logger name equals: self stdoutLoggerName;
					assert: logger typeDescription equals: 'stdout';
					assert: logger selfLocation equals: 'https://api.example.com/operations/loggers/stdout-logger'
				]
		]
]
