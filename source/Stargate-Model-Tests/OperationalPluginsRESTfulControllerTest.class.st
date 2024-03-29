"
An OperationalPluginsRESTfulControllerTest is a test class for testing the behavior of OperationalPluginsRESTfulController
"
Class {
	#name : #OperationalPluginsRESTfulControllerTest,
	#superclass : #OperationalPluginRESTfulControllerTest,
	#instVars : [
		'isPluginEnabled'
	],
	#category : #'Stargate-Model-Tests-Operations'
}

{ #category : #'private - asserting' }
OperationalPluginsRESTfulControllerTest >> assertApplicationConfigurationStatusOn: plugins [

	^ plugins
		detect: [ :plugin | plugin name = ApplicationConfigurationPlugin pluginName ]
		ifFound: [ :applicationControl | 
			self
				assert: applicationControl status equals: 'DISABLED';
				assertUrl: applicationControl selfLocation
					equals: 'https://api.example.com/operations/plugins/application-configuration'
			]
		ifNone: [ self fail ]
]

{ #category : #'private - asserting' }
OperationalPluginsRESTfulControllerTest >> assertApplicationControlStatusOn: plugins [

	^ plugins
		detect: [ :plugin | plugin name = ApplicationControlPlugin pluginName ]
		ifFound: [ :applicationControl | 
			self
				assert: applicationControl status equals: 'DISABLED';
				assertUrl: applicationControl selfLocation
					equals: 'https://api.example.com/operations/plugins/application-control'
			]
		ifNone: [ self fail ]
]

{ #category : #'private - asserting' }
OperationalPluginsRESTfulControllerTest >> assertApplicationInfoStatusOn: plugins [

	^ plugins
		detect: [ :plugin | plugin name = ApplicationInfoPlugin pluginName ]
		ifFound: [ :applicationControl | 
			self
				assert: applicationControl status equals: 'DISABLED';
				assertUrl: applicationControl selfLocation
					equals: 'https://api.example.com/operations/plugins/application-info'
			]
		ifNone: [ self fail ]
]

{ #category : #'private - asserting' }
OperationalPluginsRESTfulControllerTest >> assertHealthcheckStatusOn: plugins [

	^ plugins
		detect: [ :plugin | plugin name = HealthCheckPlugin pluginName ]
		ifFound: [ :healthcheck | 
			self
				assert: healthcheck status equals: 'DISABLED';
				assertUrl: healthcheck selfLocation
					equals: 'https://api.example.com/operations/plugins/health-check'
			]
		ifNone: [ self fail ]
]

{ #category : #'private - asserting' }
OperationalPluginsRESTfulControllerTest >> assertLoggersStatusOn: plugins [

	^ plugins
		  detect: [ :plugin | plugin name = LoggersPlugin pluginName ]
		  ifFound: [ :plugin | 
			  self
				  assert: plugin status equals: 'DISABLED';
				  assertUrl: plugin selfLocation equals: 'https://api.example.com/operations/plugins/loggers'
			  ]
		  ifNone: [ self fail ]
]

{ #category : #'private - asserting' }
OperationalPluginsRESTfulControllerTest >> assertMetricsStatusOn: plugins [

	^ plugins
		detect: [ :plugin | plugin name = MetricsPlugin pluginName ]
		ifFound: [ :metrics | 
			self
				assert: metrics status equals: 'DISABLED';
				assertUrl: metrics selfLocation equals: 'https://api.example.com/operations/plugins/metrics'
			]
		ifNone: [ self fail ]
]

{ #category : #'private - support' }
OperationalPluginsRESTfulControllerTest >> disable: anOperationalPluginType [

	isPluginEnabled := false
]

{ #category : #'private - support' }
OperationalPluginsRESTfulControllerTest >> enable: aPluginEndpoint [

	isPluginEnabled := true
]

{ #category : #'private - support' }
OperationalPluginsRESTfulControllerTest >> isEnabled: aPlugin [

	^ isPluginEnabled
]

{ #category : #running }
OperationalPluginsRESTfulControllerTest >> setUp [

	super setUp .
	isPluginEnabled := true
]

{ #category : #running }
OperationalPluginsRESTfulControllerTest >> setUpResourceController [

	resourceController := OperationalPluginsRESTfulController on: self
]

{ #category : #tests }
OperationalPluginsRESTfulControllerTest >> testDisableHealtCheckPlugin [

	| getResponse response |

	getResponse := resourceController
		               operationalPluginBasedOn:
			               ( self requestToGETResourceIdentifiedBy: HealthCheckPlugin endpoint
				                 accepting: resourceController operationalPluginVersion1dot0dot0MediaType )
		               within: self newHttpRequestContext.

	response := resourceController
		            changeOperationalPluginStatusBasedOn:
			            ( self requestToPATCHResourceIdentifiedBy: HealthCheckPlugin endpoint
				              with: '{"status":"DISABLED"}'
				              accepting: resourceController operationalPluginVersion1dot0dot0MediaType
				              conditionalTo: getResponse entityTag )
		            within: ( self newHttpRequestContext
				              permissions: { resourceController updatePermission };
				              yourself ).

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: resourceController operationalPluginVersion1dot0dot0MediaType.

	self withJsonFromContentsIn: response do: [ :healthcheck | 
		self
			assert: healthcheck name equals: HealthCheckPlugin pluginName;
			assert: healthcheck status equals: 'DISABLED';
			assertUrl: healthcheck selfLocation
			equals: 'https://api.example.com/operations/plugins/health-check';
			assert: healthcheck links size equals: 1
		]
]

{ #category : #tests }
OperationalPluginsRESTfulControllerTest >> testEnablePreviouslyDisabledHealtCheckPlugin [

	| getResponse disableResponse response |

	getResponse := resourceController
		               operationalPluginBasedOn:
			               ( self requestToGETResourceIdentifiedBy: HealthCheckPlugin endpoint
				                 accepting: resourceController operationalPluginVersion1dot0dot0MediaType )
		               within: self newHttpRequestContext.

	disableResponse := resourceController
		                   changeOperationalPluginStatusBasedOn:
			                   ( self requestToPATCHResourceIdentifiedBy: HealthCheckPlugin endpoint
				                     with: '{"status":"DISABLED"}'
				                     accepting: resourceController operationalPluginVersion1dot0dot0MediaType
				                     conditionalTo: getResponse entityTag )
		                   within: ( self newHttpRequestContext
				                     permissions: { resourceController updatePermission };
				                     yourself ).
	self withJsonFromContentsIn: disableResponse
		do: [ :healthcheck | self assert: healthcheck status equals: 'DISABLED' ].

	response := resourceController
		            changeOperationalPluginStatusBasedOn:
			            ( self requestToPATCHResourceIdentifiedBy: HealthCheckPlugin endpoint
				              with: '{"status":"ENABLED"}'
				              accepting: resourceController operationalPluginVersion1dot0dot0MediaType
				              conditionalTo: disableResponse entityTag )
		            within: ( self newHttpRequestContext
				              permissions: { resourceController updatePermission };
				              yourself ).
	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: resourceController operationalPluginVersion1dot0dot0MediaType.

	self withJsonFromContentsIn: response do: [ :healthcheck | 
		self
			assert: healthcheck name equals: HealthCheckPlugin pluginName;
			assert: healthcheck status equals: 'ENABLED';
			assertUrl: healthcheck selfLocation
			equals: 'https://api.example.com/operations/plugins/health-check';
			assertUrl: healthcheck links run equals: 'https://api.example.com/operations/health-check'
		]
]

{ #category : #tests }
OperationalPluginsRESTfulControllerTest >> testGetHealtCheckPlugin [

	| response |

	response := resourceController
		            operationalPluginBasedOn:
			            ( self requestToGETResourceIdentifiedBy: HealthCheckPlugin endpoint
				              accepting: resourceController operationalPluginVersion1dot0dot0MediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: resourceController operationalPluginVersion1dot0dot0MediaType.

	self withJsonFromContentsIn: response do: [ :healthcheck | 
		self
			assert: healthcheck name equals: HealthCheckPlugin pluginName;
			assert: healthcheck status equals: 'ENABLED';
			assertUrl: healthcheck selfLocation
			equals: 'https://api.example.com/operations/plugins/health-check';
			assertUrl: healthcheck links run equals: 'https://api.example.com/operations/health-check'
		]
]

{ #category : #tests }
OperationalPluginsRESTfulControllerTest >> testGetPlugins [

	| response |

	isPluginEnabled := false.

	response := resourceController
		operationalPluginsBasedOn:
			( self
				requestToGET: self resourceUrl
				accepting: resourceController operationalPluginVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
			equals: resourceController operationalPluginVersion1dot0dot0MediaType.

	self
		withJsonFromItemsIn: response
		do: [ :plugins | 
			self assert: plugins size >= 6.
			self
				assertHealthcheckStatusOn: plugins;
				assertMetricsStatusOn: plugins;
				assertApplicationControlStatusOn: plugins;
				assertApplicationInfoStatusOn: plugins;
				assertApplicationConfigurationStatusOn: plugins;
				assertLoggersStatusOn: plugins
			]
]
