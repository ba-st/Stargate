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
