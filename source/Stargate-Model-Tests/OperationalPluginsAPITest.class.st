"
I'm a test case for the self-provided API of the operational plugins.
"
Class {
	#name : #OperationalPluginsAPITest,
	#superclass : #HTTPBasedRESTfulAPITest,
	#category : #'Stargate-Model-Tests-Operations'
}

{ #category : #private }
OperationalPluginsAPITest >> claimSet [

	^ super claimSet
		permissions: #('read:operations');
		yourself
]

{ #category : #private }
OperationalPluginsAPITest >> controllersToInstall [

	^ Array with: self 
]

{ #category : #private }
OperationalPluginsAPITest >> newJWTAuthorizedClientLackingPermissions [

	^ self newJWTAuthorizedClientClaiming: super claimSet
]

{ #category : #private }
OperationalPluginsAPITest >> operationsUrl [

	^ self baseUrl / 'operations' asUrl
]

{ #category : #private }
OperationalPluginsAPITest >> port [

	^ 9999
]

{ #category : #private }
OperationalPluginsAPITest >> routes [

	^ #()
]

{ #category : #private }
OperationalPluginsAPITest >> serverUrl: aUrl [ 
]

{ #category : #tests }
OperationalPluginsAPITest >> testGetHealtCheckPlugin [

	| json healthCheckResponse |

	json := NeoJSONObject
		fromString: ( self newJWTAuthorizedClient get: self operationsUrl / HealthCheckPlugin endpoint asUrl ).

	self
		assert: json status equals: 'ENABLED';
		assert: json name equals: HealthCheckPlugin pluginName;
		assert: json links size equals: 1.

	healthCheckResponse := self newJWTAuthorizedClient
		url: json selfLocation;
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
				get: self operationsUrl / HealthCheckPlugin endpoint asUrl
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response code equals: 403 ]
]

{ #category : #tests }
OperationalPluginsAPITest >> testGetHealtCheckPluginUnauthorized [

	self
		should: [ self newClient get: self operationsUrl / HealthCheckPlugin endpoint asUrl ]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isAuthenticationRequired ]
]

{ #category : #tests }
OperationalPluginsAPITest >> testGetOperationalPlugins [

	| json |

	json := NeoJSONObject fromString: ( self newJWTAuthorizedClient get: self operationsUrl ).

	self
		assert: json items isCollection;
		assert: json links size equals: 1
]

{ #category : #tests }
OperationalPluginsAPITest >> testGetOperationalPluginsForbidden [

	self
		should: [ self newJWTAuthorizedClientLackingPermissions get: self operationsUrl ]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response code equals: 403 ]
]

{ #category : #tests }
OperationalPluginsAPITest >> testGetOperationalPluginsUnauthorized [

	self
		should: [ self newClient get: self operationsUrl ]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isAuthenticationRequired ]
]
