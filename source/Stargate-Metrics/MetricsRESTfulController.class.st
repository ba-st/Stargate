"
I'm a controller exposing the API of MetricsPlugin
"
Class {
	#name : #MetricsRESTfulController,
	#superclass : #OperationsRESTfulController,
	#instVars : [
		'requestHandler',
		'plugin',
		'prometheusEncoder'
	],
	#category : #'Stargate-Metrics'
}

{ #category : #'instance creation' }
MetricsRESTfulController class >> over: aMetricsPlugin configuredBy: configuration [

	^ ( self authenticationFilterBasedOn: configuration ) initializeOver: aMetricsPlugin
]

{ #category : #private }
MetricsRESTfulController >> configureMetricsEncodingOn: aWriter [

	aWriter
		for: CompositeMetric
			do: [ :mapping | 
			mapping
				mapProperty: #name getter: #name;
				mapProperty: #description getter: #description;
				mapProperty: #type getter: [ :metric | metric type name ];
				mapProperty: #value getter: #value;
				mapProperty: #metrics getter: #metrics
			];
		for: TimestampedMetric
			customDo: [ :mapping | 
			mapping
				encoder: [ :metric | 
					| result |

					result := Dictionary new.
					result
						at: #timestamp put: metric timestamp asString;
						at: #value put: metric value.
					metric metric labels keysAndValuesDo: [ :key :value | result at: key put: value ].
					result
					]
			];
		for: Counter
			do: [ :mapping | 
			mapping
				mapProperty: #name getter: #name;
				mapProperty: #description getter: #description;
				mapProperty: #type getter: [ :metric | metric type name ];
				mapProperty: #value getter: #value
			];
		for: Gauge
			do: [ :mapping | 
			mapping
				mapProperty: #name getter: #name;
				mapProperty: #description getter: #description;
				mapProperty: #type getter: [ :metric | metric type name ];
				mapProperty: #value getter: #value
			]
]

{ #category : #routes }
MetricsRESTfulController >> declareGetMetricsRoute [

	^ RouteSpecification
		handling: #GET
		at: self endpoint
		evaluating: [ :httpRequest :requestContext | self getMetricsBasedOn: httpRequest within: requestContext ]
]

{ #category : #private }
MetricsRESTfulController >> encodeMetricsInPrometheusTextFormat: resource [

	^ String
		streamContents: [ :stream | resource do: [ :metric | prometheusEncoder encode: metric on: stream ] ]
]

{ #category : #API }
MetricsRESTfulController >> getMetricsBasedOn: httpRequest within: requestContext [

	self assert: httpRequest isAuthorizedWithin: requestContext.

	^ requestHandler from: httpRequest within: requestContext getCollection: [ plugin gatherMetrics ]
]

{ #category : #initialization }
MetricsRESTfulController >> initializeOver: aMetricsPlugin [

	plugin := aMetricsPlugin.
	self initializeRequestHandler.
	prometheusEncoder := PrometheusMetricsEncoder new
]

{ #category : #initialization }
MetricsRESTfulController >> initializeRequestHandler [

	requestHandler := RESTfulRequestHandlerBuilder new
		handling: ( 'operations/<1s>' expandMacrosWith: self pluginEndpoint )
			extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ];
		whenResponding: self textPlainVersion0dot0dot4MediaType
			encodeApplying: [ :resource | self encodeMetricsInPrometheusTextFormat: resource ];
		whenResponding: self textPrometheusClientDataExpositionFormatVersion0dot0dot4MediaType
			encodeApplying: [ :resource | self encodeMetricsInPrometheusTextFormat: resource ];
		whenResponding: self operationalMetricsVersion1dot0dot0MediaType
			encodeToJsonApplying: [ :resource :requestContext :writer | self configureMetricsEncodingOn: writer ];
		createEntityTagHashing: [ :hasher | "Metrics will be different on each call" hasher include: DateAndTime now ];
		build
]

{ #category : #private }
MetricsRESTfulController >> operationalMetricsVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'operational-metrics' vendoredBy: 'stargate' version: '1.0.0'
]

{ #category : #private }
MetricsRESTfulController >> pluginEndpoint [

	^ plugin class endpoint
]

{ #category : #private }
MetricsRESTfulController >> requestHandler [

	^ requestHandler
]

{ #category : #private }
MetricsRESTfulController >> requiredPermission [

	^ 'read:<1s>' expandMacrosWith: self pluginEndpoint
]

{ #category : #private }
MetricsRESTfulController >> textPlainVersion0dot0dot4MediaType [

	"This is Prometheus Client Data Exposition Format v0.0.4. The Prometheus serves requires the text/plain as the media type,
	even when it wants a specific format"

	^ ZnMimeType textPlain version: '0.0.4'
]

{ #category : #private }
MetricsRESTfulController >> textPrometheusClientDataExpositionFormatVersion0dot0dot4MediaType [

	^ 'text/vnd.stargate.prometheus.client-data-exposition' asMediaType version: '0.0.4'
]
