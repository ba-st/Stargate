Class {
	#name : #OperationalPluginRESTfulControllerTest,
	#superclass : #SingleResourceRESTfulControllerTest,
	#category : #'Stargate-Model-Tests-Operations'
}

{ #category : #testing }
OperationalPluginRESTfulControllerTest class >> isAbstract [

	^ self name = #OperationalPluginRESTfulControllerTest
]

{ #category : #'private - support' }
OperationalPluginRESTfulControllerTest >> baseUrl [

	^ 'https://api.example.com' asUrl
]

{ #category : #'private - support' }
OperationalPluginRESTfulControllerTest >> newHttpRequestContext [

	^ super newHttpRequestContext
		permissions: ( Array with: resourceController requiredPermission );
		yourself
]

{ #category : #'private - support' }
OperationalPluginRESTfulControllerTest >> operationsConfiguration [

	^ Dictionary new
		at: #authSchema put: 'jwt';
		at: #authAlgorithm put: JWAHMACSHA256 parameterValue;
		at: #authSecret put: 'secret';
		yourself
]
