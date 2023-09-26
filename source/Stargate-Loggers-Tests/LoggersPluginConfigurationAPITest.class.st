Class {
	#name : 'LoggersPluginConfigurationAPITest',
	#superclass : 'OperationalPluginAPITest',
	#category : 'Stargate-Loggers-Tests',
	#package : 'Stargate-Loggers-Tests'
}

{ #category : 'running' }
LoggersPluginConfigurationAPITest >> operationsConfiguration [

	^ super operationsConfiguration
		  at: LoggersPlugin endpoint put: { ( #enabled -> false ) } asDictionary;
		  yourself
]

{ #category : 'running' }
LoggersPluginConfigurationAPITest >> requiredPermissions [

	^ #('read:loggers')
]

{ #category : 'tests' }
LoggersPluginConfigurationAPITest >> testPluginIsDisabled [

	self
		assertIsDisabled: LoggersPlugin;
		should: [ 
			self newJWTAuthorizedClient
				url: self operationsUrl / LoggersPlugin endpoint asUrl;
				entity: ( ZnEntity json: '' );
				post
			]
		raise: ZnHttpUnsuccessful withExceptionDo: [ :error | self assert: error response isNotFound ]
]
