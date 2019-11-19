"
An ApplicationControlPluginTest is a test class for testing the behavior of ApplicationControlPlugin
"
Class {
	#name : #ApplicationControlPluginTest,
	#superclass : #TestCase,
	#category : #'Stargate-Application-Control-Tests'
}

{ #category : #tests }
ApplicationControlPluginTest >> testAvailableCommands [

	self
		withTheOnlyOneIn: ApplicationControlPlugin availableCommands
		do: [ :command | self assert: command methodName equals: 'shutdown' ]
]

{ #category : #tests }
ApplicationControlPluginTest >> testEnabledByDefault [

	self deny: ApplicationControlPlugin enabledByDefault
]

{ #category : #tests }
ApplicationControlPluginTest >> testEndpoint [

	self assert: ApplicationControlPlugin endpoint equals: 'application-control'
]

{ #category : #tests }
ApplicationControlPluginTest >> testPluginName [

	self assert: ApplicationControlPlugin pluginName equals: 'Application Control'
]
