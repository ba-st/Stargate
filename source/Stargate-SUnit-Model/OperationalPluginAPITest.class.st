"
I'm an abstract test class providing facilities to test the API of Operational Plugins
"
Class {
	#name : #OperationalPluginAPITest,
	#superclass : #HTTPBasedRESTfulAPITest,
	#category : #'Stargate-SUnit-Model'
}

{ #category : #testing }
OperationalPluginAPITest class >> isAbstract [

	^ self name = #OperationalPluginAPITest
]

{ #category : #asserting }
OperationalPluginAPITest >> assertIsDisabled: anOperationPluginType [

	self deny: ( api isEnabled: anOperationPluginType )
]

{ #category : #asserting }
OperationalPluginAPITest >> assertIsEnabled: anOperationPluginType [

	self assert: ( api isEnabled: anOperationPluginType )
]

{ #category : #private }
OperationalPluginAPITest >> claimSet [

	^ super claimSet
		permissions: self requiredPermissions;
		yourself
]

{ #category : #private }
OperationalPluginAPITest >> controllersToInstall [

	^ Array with: self 
]

{ #category : #private }
OperationalPluginAPITest >> newJWTAuthorizedClientLackingPermissions [

	^ self newJWTAuthorizedClientClaiming: super claimSet
]

{ #category : #private }
OperationalPluginAPITest >> operationsPluginsUrl [

	^ self operationsUrl / 'plugins'
]

{ #category : #private }
OperationalPluginAPITest >> operationsUrl [

	^ self baseUrl / 'operations' asUrl
]

{ #category : #private }
OperationalPluginAPITest >> requiredPermissions [

	self subclassResponsibility
]

{ #category : #private }
OperationalPluginAPITest >> routes [

	^ #()
]

{ #category : #private }
OperationalPluginAPITest >> serverUrl: aUrl [ 
]
