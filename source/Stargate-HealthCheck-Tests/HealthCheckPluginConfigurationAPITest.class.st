"
I'm a test case for plugin disable options
"
Class {
	#name : #HealthCheckPluginConfigurationAPITest,
	#superclass : #OperationalPluginAPITest,
	#category : #'Stargate-HealthCheck-Tests'
}

{ #category : #tests }
HealthCheckPluginConfigurationAPITest >> operationsConfiguration [

	^ super operationsConfiguration
		at: HealthCheckPlugin endpoint put: { #enabled -> false } asDictionary;
		yourself
]

{ #category : #running }
HealthCheckPluginConfigurationAPITest >> requiredPermissions [

	^ #('execute:health-check')
]

{ #category : #tests }
HealthCheckPluginConfigurationAPITest >> testPluginIsDisabled [

	self
		deny: ( api isEnabled: HealthCheckPlugin );
		should: [ self newJWTAuthorizedClient
				url: self operationsUrl / HealthCheckPlugin endpoint asUrl;
				setAccept: 'application/vnd.stargate.health-check.details+json;version=1.0.0' asMediaType;
				post
			]
			raise: ZnHttpUnsuccessful
			withExceptionDo: [ :error | self assert: error response isNotFound ]
]
