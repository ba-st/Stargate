"
I'm one of the operational plugins.
I provide metrics of the running system.
"
Class {
	#name : #MetricsPlugin,
	#superclass : #OperationalPlugin,
	#instVars : [
		'metricProviders'
	],
	#category : #'Stargate-Metrics'
}

{ #category : #configuring }
MetricsPlugin class >> configureMediaControlsIn: builder within: requestContext [

	builder
		addRelativeLink: ( 'operations/<1s>' expandMacrosWith: self endpoint ) asUrl
		relatedTo: 'metrics'
]

{ #category : #'instance creation' }
MetricsPlugin class >> configuredBy: configuration [

	| selfConfiguration |

	selfConfiguration := configuration at: self endpoint.

	AssertionChecker
		enforce: [ selfConfiguration at: #enabled ]
		because: 'A disabled plugin must not be configured.'.

	^ self new initializeGatheringAll: ( selfConfiguration at: #metrics ifAbsent: [ #() ] )
]

{ #category : #accessing }
MetricsPlugin class >> endpoint [

	^ 'metrics'
]

{ #category : #accessing }
MetricsPlugin class >> pluginName [

	^ 'Metrics'
]

{ #category : #querying }
MetricsPlugin >> gatherMetrics [

	^ metricProviders
		inject: OrderedCollection new
		into: [ :metrics :provider | 
			metrics
				addAll: provider gatherMetrics;
				yourself
			]
]

{ #category : #configuring }
MetricsPlugin >> includeControllersIn: api [

	api
		addController: ( MetricsRESTfulController over: self configuredBy: api operationsConfiguration )
]

{ #category : #initialize }
MetricsPlugin >> initializeGatheringAll: enabledMetricNames [

	metricProviders := MetricProvider allSubclasses
		select: [ :provider | enabledMetricNames includes: provider providerName ]
		thenCollect: [ :providerClass | providerClass new ]
]

{ #category : #printing }
MetricsPlugin >> printOn: stream [

	stream nextPutAll: self name
]

{ #category : #initialize }
MetricsPlugin >> startOn: teapotServer [

	metricProviders do: [ :provider | provider installOn: teapotServer ]
]

{ #category : #initialize }
MetricsPlugin >> stop [

	metricProviders do: #uninstall
]
