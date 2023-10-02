"
A LoggersPluginTest is a test class for testing the behavior of LoggersPlugin
"
Class {
	#name : 'LoggersPluginTest',
	#superclass : 'TestCase',
	#category : 'Stargate-Loggers-Tests',
	#package : 'Stargate-Loggers-Tests'
}

{ #category : 'tests' }
LoggersPluginTest >> testEnabledByDefault [

	self deny: LoggersPlugin enabledByDefault
]

{ #category : 'tests' }
LoggersPluginTest >> testEndpoint [

	self assert: LoggersPlugin endpoint = 'loggers'
]

{ #category : 'tests' }
LoggersPluginTest >> testPluginName [

	self assert: LoggersPlugin pluginName equals: 'Loggers'
]

{ #category : 'tests' }
LoggersPluginTest >> testPrintOn [

	self assert: LoggersPlugin new printString equals: 'Loggers'
]
