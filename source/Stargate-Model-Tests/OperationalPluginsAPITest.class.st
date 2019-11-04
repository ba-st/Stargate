"
I'm a test case for the self-provided API of the operational plugins.
"
Class {
	#name : #OperationalPluginsAPITest,
	#superclass : #HTTPBasedRESTfulAPITest,
	#category : #'Stargate-Model-Tests-Operations'
}

{ #category : #private }
OperationalPluginsAPITest >> controllersToInstall [

	^ Array with: self 
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
OperationalPluginsAPITest >> testCannotGetHealtCheckPluginWithoutProperPermissions [

	self
		should: [ self newClient get: self operationsUrl / HealthCheckPlugin endpoint asUrl ]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isAuthenticationRequired ]
]

{ #category : #tests }
OperationalPluginsAPITest >> testCannotGetOperationalPluginsWithoutProperPermissions [

	self
		should: [ self newClient get: self operationsUrl ]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isAuthenticationRequired ]
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

	healthCheckResponse := self newClient
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
OperationalPluginsAPITest >> testGetOperationalPlugins [

	| json |

	json := NeoJSONObject fromString: ( self newJWTAuthorizedClient get: self operationsUrl ).

	self
		assert: json items isCollection;
		assert: json links size equals: 1
]
