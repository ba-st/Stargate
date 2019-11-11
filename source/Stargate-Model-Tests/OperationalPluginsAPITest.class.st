"
I'm a test case for the self-provided API of the operational plugins.
"
Class {
	#name : #OperationalPluginsAPITest,
	#superclass : #OperationalPluginAPITest,
	#category : #'Stargate-Model-Tests-Operations'
}

{ #category : #private }
OperationalPluginsAPITest >> requiredPermissions [

	^ #('read:operations')
]

{ #category : #tests }
OperationalPluginsAPITest >> testGetHealtCheckPlugin [

	| json healthCheckResponse |

	json := NeoJSONObject
		fromString: ( self newJWTAuthorizedClient get: self operationsPluginsUrl / HealthCheckPlugin endpoint asUrl ).

	self
		assert: json status equals: 'ENABLED';
		assert: json name equals: HealthCheckPlugin pluginName;
		assert: json links size equals: 2.

	healthCheckResponse := self newJWTAuthorizedClient
		url: json links run;
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

{ #category : #tests }
OperationalPluginsAPITest >> testGetHealtCheckPluginForbidden [

	self
		should: [ self newJWTAuthorizedClientLackingPermissions
				get: self operationsPluginsUrl / HealthCheckPlugin endpoint asUrl
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response code equals: 403 ]
]

{ #category : #tests }
OperationalPluginsAPITest >> testGetHealtCheckPluginUnauthorized [

	self
		should: [ self newClient get: self operationsPluginsUrl / HealthCheckPlugin endpoint asUrl ]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isAuthenticationRequired ]
]

{ #category : #tests }
OperationalPluginsAPITest >> testGetOperationalPlugins [

	| json |

	json := NeoJSONObject fromString: ( self newJWTAuthorizedClient get: self operationsPluginsUrl ).

	self
		assert: json items isCollection;
		assert: json links size equals: 1
]

{ #category : #tests }
OperationalPluginsAPITest >> testGetOperationalPluginsForbidden [

	self
		should: [ self newJWTAuthorizedClientLackingPermissions get: self operationsPluginsUrl ]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response code equals: 403 ]
]

{ #category : #tests }
OperationalPluginsAPITest >> testGetOperationalPluginsUnauthorized [

	self
		should: [ self newClient get: self operationsPluginsUrl ]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isAuthenticationRequired ]
]
