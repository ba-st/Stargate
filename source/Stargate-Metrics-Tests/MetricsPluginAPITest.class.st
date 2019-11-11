"
I'm the test case for the Metrics API
"
Class {
	#name : #MetricsPluginAPITest,
	#superclass : #OperationalPluginAPITest,
	#category : #'Stargate-Metrics-Tests'
}

{ #category : #running }
MetricsPluginAPITest >> operationsConfiguration [

	^ super operationsConfiguration
		at: MetricsPlugin endpoint
			put:
			( Dictionary new
				at: #enabled put: true;
				at: #metrics put: MetricProvider allProviderNames;
				yourself );
		yourself
]

{ #category : #running }
MetricsPluginAPITest >> requiredPermissions [

	^ #('read:metrics')
]

{ #category : #tests }
MetricsPluginAPITest >> testGetMetricsWithPermissions [

	| metricsResponse |

	metricsResponse := self newJWTAuthorizedClient
		url: self operationsUrl / MetricsPlugin endpoint asUrl;
		setAccept: ZnMimeType textPlain;
		get;
		response.

	self
		assert: metricsResponse isSuccess;
		assert: metricsResponse contentType asMediaType equals: ( ZnMimeType textPlain version: '0.0.4' );
		assert: metricsResponse contents notEmpty
]

{ #category : #tests }
MetricsPluginAPITest >> testRunHealtCheckPluginAskingDetailsWithoutAuthentication [

	self
		should: [ self newClient
				url: self operationsUrl / HealthCheckPlugin endpoint asUrl;
				setAccept: 'application/vnd.stargate.health-check.details+json;version=1.0.0' asMediaType;
				post;
				response
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response code equals: 401 ]
]

{ #category : #tests }
MetricsPluginAPITest >> testRunHealtCheckPluginAskingDetailsWithoutPermissions [

	self
		should: [ self newJWTAuthorizedClientLackingPermissions
				url: self operationsUrl / HealthCheckPlugin endpoint asUrl;
				setAccept: 'application/vnd.stargate.health-check.details+json;version=1.0.0' asMediaType;
				post;
				response
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response code equals: 403 ]
]
