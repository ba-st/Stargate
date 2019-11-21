"
I'm a test for API configuration options
"
Class {
	#name : #ApplicationInfoPluginConfigurationAPITest,
	#superclass : #OperationalPluginAPITest,
	#category : #'Stargate-Application-Info-Tests'
}

{ #category : #running }
ApplicationInfoPluginConfigurationAPITest >> operationsConfiguration [

	^ super operationsConfiguration
		at: ApplicationInfoPlugin endpoint put: { #enabled -> false } asDictionary;
		yourself
]

{ #category : #private }
ApplicationInfoPluginConfigurationAPITest >> requiredPermissions [

	^ #('read:application-info')
]

{ #category : #tests }
ApplicationInfoPluginConfigurationAPITest >> testPluginIsDisabled [

	self
		deny: ( api isEnabled: ApplicationInfoPlugin );
		should: [ self newJWTAuthorizedClient
				url: self operationsUrl / ApplicationInfoPlugin endpoint asUrl;
				setAccept: ZnMimeType textPlain;
				get
			]
			raise: ZnHttpUnsuccessful
			withExceptionDo: [ :error | self assert: error response isNotFound ]
]
