"
I'm a test case for the self-provided API of the operational plugins.
"
Class {
	#name : #OperationalPluginsAPITest,
	#superclass : #OperationalPluginAPITest,
	#category : #'Stargate-Model-Tests-Operations'
}

{ #category : #private }
OperationalPluginsAPITest >> healthCheckSummaryMediaType [

	^ 'application/vnd.stargate.health-check.summary+json;version=1.0.0' asMediaType
]

{ #category : #private }
OperationalPluginsAPITest >> newJWTAuthorizedClientForUpdates [

	^ self newJWTAuthorizedClientClaiming: ( self claimSet
			    permissions: #( 'update:operations' );
			    yourself )
]

{ #category : #private }
OperationalPluginsAPITest >> requiredPermissions [

	^ #('read:operations')
]

{ #category : #private }
OperationalPluginsAPITest >> statusChangeEntityTo: status [

	^ ZnEntity with: ( '{"status":"<1s>"}' expandMacrosWith: status )
		  ofType: 'application/vnd.stargate.operational-plugin+json;version=1.0.0' asMediaType
]

{ #category : #tests }
OperationalPluginsAPITest >> testCannotDisableHealtCheckPluginWhenMissingPermission [

	| json getResponse |

	getResponse := self newJWTAuthorizedClient
		               url: self operationsPluginsUrl / HealthCheckPlugin endpoint asUrl;
		               get;
		               response.

	json := NeoJSONObject fromString: getResponse contents.

	self assert: json status equals: 'ENABLED'.

	self
		should: [ 
			self newJWTAuthorizedClient
				url: json selfLocation;
				entity: ( self statusChangeEntityTo: 'DISABLED' );
				patch
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response code equals: 403 ]
]

{ #category : #tests }
OperationalPluginsAPITest >> testDisableHealtCheckPlugin [

	| json getResponse patchResponse |

	getResponse := self newJWTAuthorizedClient
		               url: self operationsPluginsUrl / HealthCheckPlugin endpoint asUrl;
		               get;
		               response.

	json := NeoJSONObject fromString: getResponse contents.

	self assert: json status equals: 'ENABLED'.

	patchResponse := self newJWTAuthorizedClientForUpdates
		                 url: json selfLocation;
		                 setIfMatchTo: getResponse entityTag;
		                 entity: ( self statusChangeEntityTo: 'DISABLED' );
		                 patch;
		                 response.

	self withJsonFromContentsIn: patchResponse do: [ :updatedJson | 
		self
			assert: updatedJson name equals: HealthCheckPlugin pluginName;
			assert: updatedJson status equals: 'DISABLED';
			assert: updatedJson links size equals: 1;
			assert: ( updatedJson selfLocation endsWith: '/operations/plugins/health-check' )
		]
]

{ #category : #tests }
OperationalPluginsAPITest >> testEnablePreviouslyDisabledHealtCheckPlugin [

	| json getResponse patchResponse |

	getResponse := self newJWTAuthorizedClient
		               url: self operationsPluginsUrl / HealthCheckPlugin endpoint asUrl;
		               get;
		               response.

	json := NeoJSONObject fromString: getResponse contents.

	self assert: json status equals: 'ENABLED'.

	patchResponse := self newJWTAuthorizedClientForUpdates
		                 url: json selfLocation;
		                 setIfMatchTo: getResponse entityTag;
		                 entity: ( self statusChangeEntityTo: 'DISABLED' );
		                 patch;
		                 response.

	json := NeoJSONObject fromString: patchResponse contents.

	self assert: json status equals: 'DISABLED'.

	patchResponse := self newJWTAuthorizedClientForUpdates
		                 url: json selfLocation;
		                 setIfMatchTo: patchResponse entityTag;
		                 entity: ( self statusChangeEntityTo: 'ENABLED' );
		                 patch;
		                 response.

	self withJsonFromContentsIn: patchResponse do: [ :updatedJson | 
		self
			assert: updatedJson name equals: HealthCheckPlugin pluginName;
			assert: updatedJson status equals: 'ENABLED';
			assert: updatedJson links size equals: 2;
			assert: ( updatedJson selfLocation endsWith: '/operations/plugins/health-check' )
		]
]

{ #category : #tests }
OperationalPluginsAPITest >> testGetHealtCheckPlugin [

	| json healthCheckResponse |

	json := NeoJSONObject fromString:
		        ( self newJWTAuthorizedClient get:
			          self operationsPluginsUrl / HealthCheckPlugin endpoint asUrl ).

	self
		assert: json status equals: 'ENABLED';
		assert: json name equals: HealthCheckPlugin pluginName;
		assert: json links size equals: 2;
		assert: ( json selfLocation endsWith: '/operations/plugins/health-check' ).

	healthCheckResponse := self newJWTAuthorizedClient
		                       url: json links run;
		                       setAccept: self healthCheckSummaryMediaType;
		                       post;
		                       response.

	self
		assert: healthCheckResponse isSuccess;
		assert: healthCheckResponse contentType asMediaType equals: self healthCheckSummaryMediaType;
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
OperationalPluginsAPITest >> testGetHealtCheckPluginWhenDisabled [

	| json |

	api disable: HealthCheckPlugin.

	json := NeoJSONObject fromString:
		        ( self newJWTAuthorizedClient get:
			          self operationsPluginsUrl / HealthCheckPlugin endpoint asUrl ).

	self
		assert: json status equals: 'DISABLED';
		assert: json name equals: HealthCheckPlugin pluginName;
		assert: json links size equals: 1;
		assert: ( json selfLocation endsWith: '/operations/plugins/health-check' ).

	self
		should: [ 
			self newJWTAuthorizedClient
				url: self operationsUrl / HealthCheckPlugin endpoint;
				setAccept: self healthCheckSummaryMediaType;
				post
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isNotFound ]
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
