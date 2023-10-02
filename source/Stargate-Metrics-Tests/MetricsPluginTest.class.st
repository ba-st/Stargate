"
A MetricsPluginTest is a test class for testing the behavior of MetricsPlugin
"
Class {
	#name : #MetricsPluginTest,
	#superclass : #TestCase,
	#category : #'Stargate-Metrics-Tests'
}

{ #category : #private }
MetricsPluginTest >> asPluginConfiguration: configuration [

	^ Dictionary new
		at: MetricsPlugin endpoint put: configuration;
		yourself
]

{ #category : #private }
MetricsPluginTest >> asPluginConfigurationGathering: metricProviderNames [

	^ self
		asPluginConfiguration:
			( Dictionary new
				at: #enabled put: true;
				at: #metrics put: metricProviderNames;
				yourself )
]

{ #category : #tests }
MetricsPluginTest >> testConfiguredRunningAllMetrics [

	| plugin |

	plugin := MetricsPlugin configuredBy:
		          ( self asPluginConfigurationGathering: MetricProvider allProviderNames ).

	self
		runOnlyInPharo: [ self assert: plugin gatherMetrics size equals: 7 ];
		runOnlyInGemStone64: [ self assert: plugin gatherMetrics size equals: 1 ]
]

{ #category : #tests }
MetricsPluginTest >> testConfiguredWithoutMetricsToRun [

	| plugin |

	plugin := MetricsPlugin
		configuredBy: ( self asPluginConfiguration: {( #enabled -> true )} asDictionary ).

	self assert: plugin gatherMetrics isEmpty
]

{ #category : #tests }
MetricsPluginTest >> testEnabledByDefault [

	self deny: MetricsPlugin enabledByDefault
]

{ #category : #tests }
MetricsPluginTest >> testEndpoint [

	self assert: MetricsPlugin endpoint equals: 'metrics'
]

{ #category : #tests }
MetricsPluginTest >> testPluginName [

	self assert: MetricsPlugin pluginName equals: 'Metrics'
]

{ #category : #tests }
MetricsPluginTest >> testPrintOn [

	self assert: MetricsPlugin new printString equals: 'Metrics'
]
