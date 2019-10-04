Class {
	#name : #HealthCheckRESTfulController,
	#superclass : #SingleResourceRESTfulController,
	#instVars : [
		'requestHandler',
		'plugin'
	],
	#classVars : [
		'RiskScoreToStatusMapping'
	],
	#category : #'Stargate-HealthCheck'
}

{ #category : #'class initialization' }
HealthCheckRESTfulController class >> initialize [

	RiskScoreToStatusMapping := #('PASS' 'WARN' 'FAIL').
]

{ #category : #'instance creation' }
HealthCheckRESTfulController class >> over: aHealthCheckPlugin [

	^ self new initializeOver: aHealthCheckPlugin
]

{ #category : #routes }
HealthCheckRESTfulController >> declareRunHealthChecksRoute [

	^ RouteSpecification
		handling: #POST
		at: self endpoint
		evaluating: [ :httpRequest :requestContext | self runHealthChecksBasedOn: httpRequest within: requestContext ]
]

{ #category : #private }
HealthCheckRESTfulController >> healthCheckSummaryVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'health-check.summary' vendoredBy: 'stargate' version: '1.0.0'
]

{ #category : #initialization }
HealthCheckRESTfulController >> initializeOver: aHealthCheckPlugin [

	plugin := aHealthCheckPlugin.
	self initializeRequestHandler
]

{ #category : #initialization }
HealthCheckRESTfulController >> initializeRequestHandler [

	requestHandler := RESTfulRequestHandlerBuilder new
		handling: ( 'operations/<1s>' expandMacrosWith: plugin class endpoint )
			extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ];
		whenResponding: self healthCheckSummaryVersion1dot0dot0MediaType
			encodeToJsonApplying: [ :resource :requestContext :writer | 
			writer
				for: OverallHealthCondition
				do: [ :mapping | 
					mapping
						mapProperty: #status
						getter: [ :condition | RiskScoreToStatusMapping at: condition riskScore ]
					]
			];
		createEntityTagHashing: [ :hasher :healthCheckStatus :requestContext |  ];
		build
]

{ #category : #private }
HealthCheckRESTfulController >> requestHandler [

	^ requestHandler
]

{ #category : #API }
HealthCheckRESTfulController >> runHealthChecksBasedOn: httpRequest within: requestContext [

	| healthCheckStatus entity |

	healthCheckStatus := plugin runHealthChecks.

	entity := requestHandler
		encodeResource: healthCheckStatus
		to: ( requestHandler targetMediaTypeFrom: httpRequest )
		within: requestContext.

	^ healthCheckStatus hasSucceeded
		then: [ ZnResponse ok: entity ]
		otherwise: [ ( ZnResponse statusCode: 503 )
				entity: entity;
				yourself
			]
]

{ #category : #private }
HealthCheckRESTfulController >> typeIdConstraint [

	^ IsObject
]
