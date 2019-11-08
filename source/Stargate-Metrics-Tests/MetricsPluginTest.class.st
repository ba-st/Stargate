"
A MetricsPluginTest is a test class for testing the behavior of MetricsPlugin
"
Class {
	#name : #MetricsPluginTest,
	#superclass : #TestCase,
	#category : #'Stargate-Metrics-Tests'
}

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
