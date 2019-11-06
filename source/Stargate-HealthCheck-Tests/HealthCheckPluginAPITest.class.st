"
I'm a test case for the healtcheck API
"
Class {
	#name : #HealthCheckPluginAPITest,
	#superclass : #OperationalPluginAPITest,
	#category : #'Stargate-HealthCheck-Tests'
}

{ #category : #running }
HealthCheckPluginAPITest >> requiredPermissions [

	^ #('execute:health-check')
]

{ #category : #tests }
HealthCheckPluginAPITest >> testRunHealtCheckPluginAskingDetailsWithPermissions [

	| healthCheckResponse |

	healthCheckResponse := self newJWTAuthorizedClient
		url: self operationsUrl / HealthCheckPlugin endpoint asUrl;
		setAccept: 'application/vnd.stargate.health-check.details+json;version=1.0.0' asMediaType;
		post;
		response.

	self
		assert: healthCheckResponse isSuccess;
		assert: healthCheckResponse contentType asMediaType
			equals: 'application/vnd.stargate.health-check.details+json;version=1.0.0' asMediaType;
		withJsonFromContentsIn: healthCheckResponse
			do: [ :detailedResponse | 
			self
				assert: detailedResponse status equals: 'PASS';
				assert: detailedResponse details isEmpty
			]
]

{ #category : #tests }
HealthCheckPluginAPITest >> testRunHealtCheckPluginAskingDetailsWithoutAuthentication [

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
HealthCheckPluginAPITest >> testRunHealtCheckPluginAskingDetailsWithoutPermissions [

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

{ #category : #tests }
HealthCheckPluginAPITest >> testRunHealtCheckPluginAskingSummaryWithoutAuthentication [

	self
		should: [ self newClient
				url: self operationsUrl / HealthCheckPlugin endpoint asUrl;
				setAccept: 'application/vnd.stargate.health-check.summary+json;version=1.0.0' asMediaType;
				post;
				response
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response code equals: 401 ]
]

{ #category : #tests }
HealthCheckPluginAPITest >> testRunHealtCheckPluginAskingSummaryWithoutPermissions [

	| healthCheckResponse |

	healthCheckResponse := self newJWTAuthorizedClientLackingPermissions
		url: self operationsUrl / HealthCheckPlugin endpoint asUrl;
		setAccept: 'application/vnd.stargate.health-check.summary+json;version=1.0.0' asMediaType;
		post;
		response.

	self
		assert: healthCheckResponse isSuccess;
		assert: healthCheckResponse contentType asMediaType
			equals: 'application/vnd.stargate.health-check.summary+json;version=1.0.0' asMediaType;
		withJsonFromContentsIn: healthCheckResponse
			do: [ :summary | self assert: summary status equals: 'PASS' ]
]
