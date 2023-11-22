Class {
	#name : 'OperationalPluginRESTfulControllerTest',
	#superclass : 'SingleResourceRESTfulControllerTest',
	#category : 'Stargate-SUnit-Model',
	#package : 'Stargate-SUnit-Model'
}

{ #category : 'testing' }
OperationalPluginRESTfulControllerTest class >> isAbstract [

	^ self name = #OperationalPluginRESTfulControllerTest
]

{ #category : 'private - support' }
OperationalPluginRESTfulControllerTest >> baseUrl [

	^ 'https://api.example.com' asUrl
]

{ #category : 'private - support' }
OperationalPluginRESTfulControllerTest >> newHttpRequestContext [

	^ super newHttpRequestContext
		permissions: ( Array with: resourceController requiredPermission );
		yourself
]

{ #category : 'private - support' }
OperationalPluginRESTfulControllerTest >> operationsConfiguration [

	^ Dictionary new
		at: #authSchema put: 'jwt';
		at: #authAlgorithm put: 'HS256';
		at: #authSecret put: 'secret';
		yourself
]
