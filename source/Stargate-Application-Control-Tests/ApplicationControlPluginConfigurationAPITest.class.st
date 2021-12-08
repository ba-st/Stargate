"
I'm a test case for plugin disable options
"
Class {
	#name : #ApplicationControlPluginConfigurationAPITest,
	#superclass : #OperationalPluginAPITest,
	#category : #'Stargate-Application-Control-Tests'
}

{ #category : #tests }
ApplicationControlPluginConfigurationAPITest >> operationsConfiguration [

	^ super operationsConfiguration
		at: ApplicationControlPlugin endpoint put: { #enabled -> false } asDictionary;
		yourself
]

{ #category : #running }
ApplicationControlPluginConfigurationAPITest >> requiredPermissions [

	^ #('execute:application-control')
]

{ #category : #tests }
ApplicationControlPluginConfigurationAPITest >> testPluginIsDisabled [

	self
		assertIsDisabled: ApplicationControlPlugin;
		should: [ 
			self newJWTAuthorizedClient
				url: self operationsUrl / ApplicationControlPlugin endpoint asUrl;
				entity: ( ZnEntity json: '' );
				post
			]
		raise: ZnHttpUnsuccessful withExceptionDo: [ :error | self assert: error response isNotFound ]
]
