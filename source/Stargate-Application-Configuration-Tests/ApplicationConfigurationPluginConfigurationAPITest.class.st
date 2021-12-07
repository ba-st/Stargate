"
I'm a test for API configuration options
"
Class {
	#name : #ApplicationConfigurationPluginConfigurationAPITest,
	#superclass : #OperationalPluginAPITest,
	#category : #'Stargate-Application-Configuration-Tests'
}

{ #category : #running }
ApplicationConfigurationPluginConfigurationAPITest >> operationsConfiguration [

	^ super operationsConfiguration
		at: ApplicationConfigurationPlugin endpoint put: { #enabled -> false } asDictionary;
		yourself
]

{ #category : #private }
ApplicationConfigurationPluginConfigurationAPITest >> requiredPermissions [

	^ #('read:application-configuration')
]

{ #category : #tests }
ApplicationConfigurationPluginConfigurationAPITest >> testPluginIsDisabled [

	self
		assertIsDisabled: ApplicationConfigurationPlugin;
		should: [ 
			self newJWTAuthorizedClient
				url: self operationsUrl / ApplicationConfigurationPlugin endpoint asUrl;
				setAccept: ZnMimeType textPlain;
				get
			]
		raise: ZnHttpUnsuccessful withExceptionDo: [ :error | self assert: error response isNotFound ]
]
