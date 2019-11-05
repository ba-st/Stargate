Class {
	#name : #HealthCheckRESTfulController,
	#superclass : #OperationsRESTfulController,
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

	<ignoreInCoverage>
	RiskScoreToStatusMapping := #('PASS' 'WARN' 'FAIL')
]

{ #category : #'instance creation' }
HealthCheckRESTfulController class >> over: aHealthCheckPlugin configuredBy: configuration [

	^ ( self authenticationFilterBasedOn: configuration ) initializeOver: aHealthCheckPlugin
]

{ #category : #private }
HealthCheckRESTfulController >> asHealthConditionDetails: overallHealthCondition [

	| details |

	details := Dictionary new.
	overallHealthCondition
		conditionsDo: [ :healthCondition | 
			details
				at: ( healthCondition concern copyReplaceAll: ' ' with: '-' )
				put:
					( Dictionary new
						at: 'status' put: ( self statusOf: healthCondition );
						at: 'details' put: healthCondition details;
						yourself )
			].
	^ details
]

{ #category : #routes }
HealthCheckRESTfulController >> declareRunHealthChecksRoute [

	^ RouteSpecification
		handling: #POST
		at: self endpoint
		evaluating: [ :httpRequest :requestContext | self runHealthChecksBasedOn: httpRequest within: requestContext ]
]

{ #category : #private }
HealthCheckRESTfulController >> healthCheckDetailsVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'health-check.details' vendoredBy: 'stargate' version: '1.0.0'
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
		handling: ( 'operations/<1s>' expandMacrosWith: self pluginEndpoint )
			extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ];
		whenResponding: self healthCheckSummaryVersion1dot0dot0MediaType
			encodeToJsonApplying: [ :resource :requestContext :writer | 
			writer
				for: OverallHealthCondition
				do: [ :mapping | mapping mapProperty: #status getter: [ :condition | self statusOf: condition ] ]
			];
		whenResponding: self healthCheckDetailsVersion1dot0dot0MediaType
			encodeToJsonApplying: [ :resource :requestContext :writer | 
			writer
				for: OverallHealthCondition
				do: [ :mapping | 
					mapping
						mapProperty: #status getter: [ :condition | self statusOf: condition ];
						mapProperty: #details getter: [ :condition | self asHealthConditionDetails: condition ]
					]
			];
		createEntityTagHashing: [ :hasher :healthCheckStatus :requestContext |  ];
		build
]

{ #category : #private }
HealthCheckRESTfulController >> pluginEndpoint [

	^ plugin class endpoint
]

{ #category : #private }
HealthCheckRESTfulController >> requestHandler [

	^ requestHandler
]

{ #category : #private }
HealthCheckRESTfulController >> requiredPermission [

	^ 'run:<1s>' expandMacrosWith: self pluginEndpoint
]

{ #category : #API }
HealthCheckRESTfulController >> runHealthChecksBasedOn: httpRequest within: requestContext [

	| healthCheckStatus entity targetMediaType |

	targetMediaType := requestHandler targetMediaTypeFrom: httpRequest.
	"The summary media type can be requested without authorization credentials"
	[ self assert: httpRequest isAuthorizedWithin: requestContext ]
		unless: targetMediaType = self healthCheckSummaryVersion1dot0dot0MediaType .

	healthCheckStatus := plugin runHealthChecks.

	entity := requestHandler
		encodeResource: healthCheckStatus
		to: targetMediaType
		within: requestContext.

	^ healthCheckStatus hasSucceeded
		then: [ ZnResponse ok: entity ]
		otherwise: [ ( ZnResponse statusCode: 503 )
				entity: entity;
				yourself
			]
]

{ #category : #private }
HealthCheckRESTfulController >> statusOf: condition [

	^ RiskScoreToStatusMapping at: condition riskScore
]

{ #category : #private }
HealthCheckRESTfulController >> typeIdConstraint [

	^ IsObject
]
