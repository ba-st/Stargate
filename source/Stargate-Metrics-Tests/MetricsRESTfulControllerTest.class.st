"
A MetricsRESTfulControllerTest is a test class for testing the behavior of MetricsRESTfulController
"
Class {
	#name : #MetricsRESTfulControllerTest,
	#superclass : #OperationalPluginRESTfulControllerTest,
	#category : #'Stargate-Metrics-Tests'
}

{ #category : #'private - support' }
MetricsRESTfulControllerTest >> operationsConfiguration [

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
MetricsRESTfulControllerTest >> setUpResourceController [

	resourceController := MetricsRESTfulController
		over: ( MetricsPlugin configuredBy: self operationsConfiguration )
		configuredBy: self operationsConfiguration
]

{ #category : #tests }
MetricsRESTfulControllerTest >> testGetMetricsInJson [

	| response |

	response := resourceController
		            getMetricsBasedOn: ( self
				              requestToGET: self resourceUrl
				              accepting: resourceController operationalMetricsVersion1dot0dot0MediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType
		equals: resourceController operationalMetricsVersion1dot0dot0MediaType;
		withJsonFromContentsIn: response do: [ :metrics |
			self
				runOnlyInPharo: [ self assert: metrics size equals: 7 ];
				runOnlyInGemStone64: [ self assert: metrics size equals: 1 ].
			metrics do: [ :metric |
				self
					assert: metric name notEmpty;
					assert: metric description notEmpty;
					assert: metric value isNumber;
					assert: ( #( 'Gauge' 'Counter' ) includes: metric type )
				]
			]
]

{ #category : #tests }
MetricsRESTfulControllerTest >> testGetMetricsInPrometheusFormat [

	| response |

	response := resourceController
		getMetricsBasedOn:
			( self
				requestToGET: self resourceUrl
				accepting: resourceController textPrometheusClientDataExpositionFormatVersion0dot0dot4MediaType )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType
			equals: resourceController textPrometheusClientDataExpositionFormatVersion0dot0dot4MediaType;
		assert: response contents notEmpty
]

{ #category : #tests }
MetricsRESTfulControllerTest >> testGetMetricsInTextPlain [

	| response |

	response := resourceController
		getMetricsBasedOn: ( self requestToGET: self resourceUrl accepting: ZnMimeType textPlain )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response contentType asMediaType
			equals: resourceController textPlainVersion0dot0dot4MediaType;
		assert: response contents notEmpty
]
