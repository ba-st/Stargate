"
A HealthCheckRESTfulControllerTest is a test class for testing the behavior of HealthCheckRESTfulController
"
Class {
	#name : #HealthCheckRESTfulControllerTest,
	#superclass : #OperationalPluginRESTfulControllerTest,
	#instVars : [
		'healthChecks'
	],
	#category : #'Stargate-HealthCheck-Tests'
}

{ #category : #'private - support' }
HealthCheckRESTfulControllerTest >> requestToPOSTAccepting: aMediaType [

	^ TeaRequest
		fromZnRequest:
			( ( ZnRequest post: self resourceUrl )
				setAccept: aMediaType;
				yourself )
]

{ #category : #running }
HealthCheckRESTfulControllerTest >> setUp [

	healthChecks := OrderedCollection new.
	super setUp
]

{ #category : #running }
HealthCheckRESTfulControllerTest >> setUpResourceController [

	resourceController := HealthCheckRESTfulController
		over: ( HealthCheckPlugin runningAll: healthChecks )
		configuredBy: self operationsConfiguration
]

{ #category : #tests }
HealthCheckRESTfulControllerTest >> testRunHealthChecksWithFailuresAskingDetailedData [

	| response |

	healthChecks
		add:
			( TestHealthCheck
				responding:
					( CriticalHealth
						detailedBy:
							( Dictionary new
								at: 'free-space' put: 50000;
								at: 'total' put: 60000;
								yourself )
						onHealthCheckNamed: 'low disk space' ) ).

	response := resourceController
		runHealthChecksBasedOn: ( self requestToPOSTAccepting: resourceController healthCheckDetailsVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response code equals: 503;
		assert: response contentType asMediaType
			equals: resourceController healthCheckDetailsVersion1dot0dot0MediaType;
		withJsonFromContentsIn: response
			do: [ :json | 
			| lowDiskSpace |

			self assert: json status equals: 'FAIL'.
			lowDiskSpace := json details at: 'low-disk-space'.
			self
				assert: lowDiskSpace status equals: 'FAIL';
				assert: ( lowDiskSpace details at: 'free-space' ) equals: 50000;
				assert: ( lowDiskSpace details at: 'total' ) equals: 60000
			]
]

{ #category : #tests }
HealthCheckRESTfulControllerTest >> testRunHealthChecksWithFailuresAskingSummarizedData [

	| response |

	healthChecks
		add:
			( TestHealthCheck
				responding: ( CriticalHealth detailedBy: Dictionary new onHealthCheckNamed: 'low disk space' ) ).

	response := resourceController
		runHealthChecksBasedOn: ( self requestToPOSTAccepting: resourceController healthCheckSummaryVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response code equals: 503;
		assert: response contentType asMediaType
			equals: resourceController healthCheckSummaryVersion1dot0dot0MediaType;
		withJsonFromContentsIn: response do: [ :json | self assert: json status equals: 'FAIL' ]
]

{ #category : #tests }
HealthCheckRESTfulControllerTest >> testRunHealthChecksWithWarningsAskingDetailedData [

	| response |

	healthChecks
		add: ( TestHealthCheck responding: ( Sick detailedBy: Dictionary new onHealthCheckNamed: 'warning' ) ).

	response := resourceController
		runHealthChecksBasedOn: ( self requestToPOSTAccepting: resourceController healthCheckDetailsVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType
			equals: resourceController healthCheckDetailsVersion1dot0dot0MediaType;
		withJsonFromContentsIn: response
			do: [ :json | 
			self
				assert: json status equals: 'WARN';
				assert: json details warning status equals: 'WARN';
				assert: json details warning details isEmpty
			]
]

{ #category : #tests }
HealthCheckRESTfulControllerTest >> testRunHealthChecksWithWarningsAskingSummarizedData [

	| response |

	healthChecks
		add: ( TestHealthCheck responding: ( Sick detailedBy: Dictionary new onHealthCheckNamed: 'warning' ) ).

	response := resourceController
		runHealthChecksBasedOn: ( self requestToPOSTAccepting: resourceController healthCheckSummaryVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType
			equals: resourceController healthCheckSummaryVersion1dot0dot0MediaType;
		withJsonFromContentsIn: response do: [ :json | self assert: json status equals: 'WARN' ]
]

{ #category : #tests }
HealthCheckRESTfulControllerTest >> testRunSeveralHealthChecksAskingDetailedData [

	| response |

	healthChecks
		add:
			( TestHealthCheck
				responding: ( CriticalHealth detailedBy: Dictionary new onHealthCheckNamed: 'failed' ) );
		add: ( TestHealthCheck responding: ( Sick detailedBy: Dictionary new onHealthCheckNamed: 'warning' ) );
		add: ( TestHealthCheck responding: ( Healthy onHealthCheckNamed: 'success' ) ).

	response := resourceController
		runHealthChecksBasedOn: ( self requestToPOSTAccepting: resourceController healthCheckDetailsVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response code equals: 503;
		assert: response contentType asMediaType
			equals: resourceController healthCheckDetailsVersion1dot0dot0MediaType;
		withJsonFromContentsIn: response
			do: [ :json | 
			self
				assert: json status equals: 'FAIL';
				assert: json details failed status equals: 'FAIL';
				assert: json details warning status equals: 'WARN';
				assert: json details success status equals: 'PASS'
			]
]

{ #category : #tests }
HealthCheckRESTfulControllerTest >> testSuccessfullyRunHealthChecksAskingDetailedData [

	| response |

	response := resourceController
		runHealthChecksBasedOn: ( self requestToPOSTAccepting: resourceController healthCheckDetailsVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType
			equals: resourceController healthCheckDetailsVersion1dot0dot0MediaType;
		withJsonFromContentsIn: response
			do: [ :json | 
			self
				assert: json status equals: 'PASS';
				assert: json details isEmpty
			]
]

{ #category : #tests }
HealthCheckRESTfulControllerTest >> testSuccessfullyRunHealthChecksAskingSummarizedData [

	| response |

	response := resourceController
		runHealthChecksBasedOn: ( self requestToPOSTAccepting: resourceController healthCheckSummaryVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType
			equals: resourceController healthCheckSummaryVersion1dot0dot0MediaType;
		withJsonFromContentsIn: response do: [ :json | self assert: json status equals: 'PASS' ]
]
