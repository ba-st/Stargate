"
I'm a test case for the healtcheck API
"
Class {
	#name : 'HealthCheckPluginAPITest',
	#superclass : 'OperationalPluginAPITest',
	#category : 'Stargate-HealthCheck-Tests',
	#package : 'Stargate-HealthCheck-Tests'
}

{ #category : 'running' }
HealthCheckPluginAPITest >> requiredPermissions [

	^ #('execute:health-check')
]

{ #category : 'tests' }
HealthCheckPluginAPITest >> testDisablePlugin [

	self assertIsEnabled: HealthCheckPlugin.

	api disable: HealthCheckPlugin.
	self assertIsDisabled: HealthCheckPlugin.

	self
		should: [ 
			self newJWTAuthorizedClient
				url: self operationsUrl / HealthCheckPlugin endpoint asUrl;
				setAccept: 'application/vnd.stargate.health-check.details+json;version=1.0.0' asMediaType;
				post;
				response
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isNotFound ]
]

{ #category : 'tests' }
HealthCheckPluginAPITest >> testEnablePreviouslyDisabledPlugin [

	self assertIsEnabled: HealthCheckPlugin.

	api disable: HealthCheckPlugin.
	self assertIsDisabled: HealthCheckPlugin.

	api enable: HealthCheckPlugin.
	self assertIsEnabled: HealthCheckPlugin.

	self testRunHealtCheckPluginAskingDetailsWithPermissions
]

{ #category : 'tests' }
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

{ #category : 'tests' }
HealthCheckPluginAPITest >> testRunHealtCheckPluginAskingDetailsWithoutAuthentication [

  self
    should: [
        self newClient
          url: self operationsUrl / HealthCheckPlugin endpoint asUrl;
          setAccept: 'application/vnd.stargate.health-check.details+json;version=1.0.0' asMediaType;
          post;
          response
      ]
    raise: ZnHttpUnsuccessful
    withExceptionDo: [ :error |
        | response |
        response := error response.
        self
          assert: response code equals: 401;
          assert: ( response headers at: 'WWW-Authenticate' )
          equals: 'Bearer realm=api.operations.example.com';
          withJsonFromContentsIn: response do: [ :payload |
              self
                assert: payload message equals: 'Unauthorized';
                assert: payload code equals: 401
            ]
      ]
]

{ #category : 'tests' }
HealthCheckPluginAPITest >> testRunHealtCheckPluginAskingDetailsWithoutPermissions [

  self
    should: [
        self newJWTAuthorizedClientLackingPermissions
          url: self operationsUrl / HealthCheckPlugin endpoint asUrl;
          setAccept: 'application/vnd.stargate.health-check.details+json;version=1.0.0' asMediaType;
          post;
          response
      ]
    raise: ZnHttpUnsuccessful
    withExceptionDo: [ :error |
        | response |
        response := error response.
        self
          assert: response code equals: 403;
          assert: ( response headers at: 'WWW-Authenticate' )
          equals: 'Bearer realm=api.operations.example.com';
          withJsonFromContentsIn: response do: [ :payload |
              self
                assert: payload message equals: 'Missing permissions';
                assert: payload code equals: 403;
                assert: payload errorCode equals: 'insufficient_scope';
                assert: payload scope equals: 'execute:health-check'
            ]
      ]
]

{ #category : 'tests' }
HealthCheckPluginAPITest >> testRunHealtCheckPluginAskingSummaryWithoutAuthentication [

  self
    should: [
        self newClient
          url: self operationsUrl / HealthCheckPlugin endpoint asUrl;
          setAccept: 'application/vnd.stargate.health-check.summary+json;version=1.0.0' asMediaType;
          post;
          response
      ]
    raise: ZnHttpUnsuccessful
    withExceptionDo: [ :error |
        | response |
        response := error response.
        self
          assert: response code equals: 401;
          assert: ( response headers at: 'WWW-Authenticate' )
          equals: 'Bearer realm=api.operations.example.com';
          withJsonFromContentsIn: response do: [ :payload |
              self
                assert: payload message equals: 'Unauthorized';
                assert: payload code equals: 401
            ]
      ]
]

{ #category : 'tests' }
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
