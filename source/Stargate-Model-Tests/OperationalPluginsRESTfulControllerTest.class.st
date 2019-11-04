"
An OperationalPluginsRESTfulControllerTest is a test class for testing the behavior of OperationalPluginsRESTfulController
"
Class {
	#name : #OperationalPluginsRESTfulControllerTest,
	#superclass : #SingleResourceRESTfulControllerTest,
	#category : #'Stargate-Model-Tests-Operations'
}

{ #category : #'private - support' }
OperationalPluginsRESTfulControllerTest >> baseUrl [

	^ 'https://api.example.com' asUrl
]

{ #category : #'private - support' }
OperationalPluginsRESTfulControllerTest >> isEnabled: aPlugin [

	^ false
]

{ #category : #'private - support' }
OperationalPluginsRESTfulControllerTest >> operationsConfiguration [

	^ Dictionary new
		at: #authSchema put: 'jwt';
		at: #authAlgorithm put: JWAHMACSHA256 parameterValue;
		at: #authSecret put: 'secret';
		yourself
]

{ #category : #running }
OperationalPluginsRESTfulControllerTest >> setUpResourceController [

	resourceController := OperationalPluginsRESTfulController on: self
]

{ #category : #tests }
OperationalPluginsRESTfulControllerTest >> testGetHealtCheckPlugin [

	| response |

	response := resourceController
		operationalPluginBasedOn:
			( self
				requestToGETResourceIdentifiedBy: HealthCheckPlugin endpoint
				accepting: resourceController operationalPluginVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
			equals: resourceController operationalPluginVersion1dot0dot0MediaType.

	self
		withJsonFromContentsIn: response
		do: [ :healthcheck | 
			self
				assert: healthcheck name equals: HealthCheckPlugin pluginName;
				assert: healthcheck status equals: 'DISABLED';
				assertUrl: healthcheck selfLocation equals: 'https://api.example.com/operations/health-check'
			]
]

{ #category : #tests }
OperationalPluginsRESTfulControllerTest >> testGetPlugins [

	| response |

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
			self
				withTheOnlyOneIn: plugins
				do: [ :healthcheck | 
					self
						assert: healthcheck name equals: HealthCheckPlugin pluginName;
						assert: healthcheck status equals: 'DISABLED';
						assertUrl: healthcheck selfLocation equals: 'https://api.example.com/operations/health-check'
					]
			]
]
