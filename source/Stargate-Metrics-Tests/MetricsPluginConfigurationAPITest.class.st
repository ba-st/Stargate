Class {
	#name : #MetricsPluginConfigurationAPITest,
	#superclass : #OperationalPluginAPITest,
	#category : #'Stargate-Metrics-Tests'
}

{ #category : #running }
MetricsPluginConfigurationAPITest >> operationsConfiguration [

	^ super operationsConfiguration
		at: MetricsPlugin endpoint put: {( #enabled -> false )} asDictionary;
		yourself
]

{ #category : #running }
MetricsPluginConfigurationAPITest >> requiredPermissions [

	^ #('read:metrics')
]

{ #category : #tests }
MetricsPluginConfigurationAPITest >> testPluginIsDisabled [

	self
		deny: ( api isEnabled: MetricsPlugin );
		should: [ self newJWTAuthorizedClient
				url: self operationsUrl / MetricsPlugin endpoint asUrl;
				setAccept: ZnMimeType textPlain;
				get
			]
			raise: ZnHttpUnsuccessful
			withExceptionDo: [ :error | self assert: error response isNotFound ]
]
