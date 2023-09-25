Class {
	#name : #PharoMetricsPluginTest,
	#superclass : #TestCase,
	#category : #'Stargate-Metrics-Pharo-Tests'
}

{ #category : #private }
PharoMetricsPluginTest >> asPluginConfiguration: configuration [

	^ Dictionary new
		at: MetricsPlugin endpoint put: configuration;
		yourself
]

{ #category : #private }
PharoMetricsPluginTest >> asPluginConfigurationGathering: metricProviderNames [

	^ self
		asPluginConfiguration:
			( Dictionary new
				at: #enabled put: true;
				at: #metrics put: metricProviderNames;
				yourself )
]

{ #category : #tests }
PharoMetricsPluginTest >> testConfiguredRunningGarbageCollectionMetrics [

	| plugin |

	plugin := MetricsPlugin
		configuredBy: ( self asPluginConfigurationGathering: ( Array with: GarbageCollectionMetrics providerName ) ).

	self assert: plugin gatherMetrics size equals: 3
]

{ #category : #tests }
PharoMetricsPluginTest >> testConfiguredRunningMemoryMetrics [

	| plugin |

	plugin := MetricsPlugin configuredBy: ( self asPluginConfigurationGathering: #('memory') ).

	self assert: plugin gatherMetrics size equals: 1
]

{ #category : #tests }
PharoMetricsPluginTest >> testConfiguredRunningSystemMetrics [

	| plugin |

	plugin := MetricsPlugin configuredBy: ( self asPluginConfigurationGathering: #('running system') ).

	self assert: plugin gatherMetrics size equals: 3
]
