"
I'm the test case for the Metrics API
"
Class {
	#name : #MetricsPluginAPITest,
	#superclass : #OperationalPluginAPITest,
	#category : #'Stargate-Metrics-Tests'
}

{ #category : #running }
MetricsPluginAPITest >> operationsConfiguration [

	^ super operationsConfiguration
		at: MetricsPlugin endpoint
			put:
			( Dictionary new
				at: #enabled put: true;
				at: #metrics put: MetricProvider allProviderNames;
				yourself );
		yourself
]

{ #category : #running }
MetricsPluginAPITest >> requiredPermissions [

	^ #('read:metrics')
]

{ #category : #tests }
MetricsPluginAPITest >> testDisablePlugin [

	self assertIsEnabled: MetricsPlugin.

	api disable: MetricsPlugin.
	self assertIsDisabled: MetricsPlugin.

	self
		should: [ 
			self newJWTAuthorizedClient
				url: self operationsUrl / MetricsPlugin endpoint asUrl;
				setAccept: ZnMimeType textPlain;
				get
			]
		raise: ZnHttpUnsuccessful
		withExceptionDo: [ :error | self assert: error response isNotFound ]
]

{ #category : #tests }
MetricsPluginAPITest >> testEnablePreviouslyDisabledPlugin [

	self assertIsEnabled: MetricsPlugin.

	api disable: MetricsPlugin.
	self assertIsDisabled: MetricsPlugin.

	api enable: MetricsPlugin.
	self assertIsEnabled: MetricsPlugin.

	self testGetMetricsWithPermissions
]

{ #category : #tests }
MetricsPluginAPITest >> testGetMetricsWithPermissions [

	| metricsResponse |

	metricsResponse := self newJWTAuthorizedClient
		url: self operationsUrl / MetricsPlugin endpoint asUrl;
		setAccept: ZnMimeType textPlain;
		get;
		response.

	self
		assert: metricsResponse isSuccess;
		assert: metricsResponse contentType asMediaType equals: ( ZnMimeType textPlain version: '0.0.4' );
		assert: metricsResponse contents notEmpty
]
