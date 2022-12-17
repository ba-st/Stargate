Class {
	#name : #StargateApplication,
	#superclass : #LaunchpadApplication,
	#instVars : [
		'apiOptional'
	],
	#classInstVars : [
		'Version'
	],
	#category : #'Stargate-API-Skeleton'
}

{ #category : #private }
StargateApplication class >> applicationBaselineName [

	^ self subclassResponsibility
]

{ #category : #accessing }
StargateApplication class >> configurationParameters [

	^ self stargateConfigurationParameters
]

{ #category : #private }
StargateApplication class >> fileReferenceToDumpStackTrace [

	^ self logsDirectory / ( '<1s>-<2s>.fuel' expandMacrosWith: self commandName
		    with: ( ( ZTimestampFormat fromString: '2001-02-03_16-05-06.07' ) format: ZTimestamp now ) )
]

{ #category : #initialization }
StargateApplication class >> initializeVersion [

	<ignoreForCoverage>
	Version := VersionFromRepositoryResolver new valueFor: self applicationBaselineName
]

{ #category : #testing }
StargateApplication class >> isAbstract [

	^ self = StargateApplication
]

{ #category : #private }
StargateApplication class >> logsDirectory [

	^ FileLocator workingDirectory / 'logs'
]

{ #category : #private }
StargateApplication class >> sectionsForStargateConfiguration [

	^ #('Stargate')
]

{ #category : #private }
StargateApplication class >> stargateConfigurationParameters [

	^ OrderedCollection new
		  add: ( MandatoryConfigurationParameter named: 'Public URL'
				    describedBy: 'Public URL where the API is deployed. Used to create hypermedia links'
				    inside: self sectionsForStargateConfiguration
				    convertingWith: #asUrl );
		  add: ( MandatoryConfigurationParameter named: 'Port'
				    describedBy: 'Listening port'
				    inside: self sectionsForStargateConfiguration
				    convertingWith: #asNumber );
		  add: ( MandatoryConfigurationParameter named: 'Operations Secret'
				    describedBy: 'Secret key for checking JWT signatures'
				    inside: self sectionsForStargateConfiguration
				    convertingWith: #asByteArray ) asSensitive;
		  add: ( OptionalConfigurationParameter
				    named: 'Enable HTTP Server logging'
				    describedBy: 'Boolean that indicates whether to log all the HTTP Server requests'
				    inside: self sectionsForStargateConfiguration
				    defaultingTo: false
				    convertingWith: [ :value | value = 'true' ] );
		  add: ( OptionalConfigurationParameter
				    named: 'Enable HTTP Client logging'
				    describedBy: 'Boolean that indicates whether to log all the HTTP Clients requests'
				    inside: self sectionsForStargateConfiguration
				    defaultingTo: false
				    convertingWith: [ :value | value = 'true' ] );
		  yourself
]

{ #category : #accessing }
StargateApplication class >> version [

	^ Version
]

{ #category : #'private - accessing' }
StargateApplication >> apiConfiguration [

	^ Array with: #serverUrl -> self stargateConfiguration publicURL
		  with: #port -> self stargateConfiguration port
		  with: #debugMode -> self isDebugModeEnabled
		  with: #operations -> self operationsConfiguration
]

{ #category : #'private - accessing' }
StargateApplication >> applicationConfigurationConfiguration [

	^ Dictionary new
		  at: #enabled put: true;
		  at: #definitions put: self class configurationParameters;
		  at: #provider put: [ self configuration ];
		  yourself
]

{ #category : #'private - accessing' }
StargateApplication >> applicationControlCommandsToEnable [

	"This method must return an array of application control command names to be enabled"

	^ #(  )
]

{ #category : #'private - accessing' }
StargateApplication >> applicationControlConfiguration [

	^ Dictionary new
		  at: #enabled put: true;
		  at: #commands put: #( 'shutdown' ) , self applicationControlCommandsToEnable;
		  yourself
]

{ #category : #'private - accessing' }
StargateApplication >> applicationInfoConfiguration [

	^ Dictionary new
		at: #enabled put: true;
		at: #'info-providers' put: ApplicationInformationProvider allProviderNames;
		yourself
]

{ #category : #'private - accessing' }
StargateApplication >> authAlgorithm [

	^ JWAHMACSHA256 parameterValue
]

{ #category : #'private - activation/deactivation' }
StargateApplication >> basicStartWithin: context [

	| api |
	self logAPIVersion.
	self
		configureHTTPClientLogging;
		configureHTTPServerLogging.
	api := self createAPI.
	self
		configureGlobalErrorHandlerIn: api;
		installAndStart: api.
	apiOptional := Optional containing: api
]

{ #category : #'private - activation/deactivation' }
StargateApplication >> basicStop [

	apiOptional withContentDo: [ :api | api stop ].
	ZnLogEvent announcer unsubscribe: self.
	super basicStop
]

{ #category : #'private - activation/deactivation' }
StargateApplication >> configureGlobalErrorHandlerIn: api [

	[ 
	LaunchpadLogRecord emitInfo: 'Configuring error handlers' during: [ 
		api
			on: Error addErrorHandler: [ :error | 
				LaunchpadLogRecord emitError: error messageText.
				self stackTraceDumper dumpStackTraceFor: error.
				TeaResponse serverError
					body: error messageText;
					yourself
				];
			on: Exit addErrorHandler: [ :exit | 
			exit isSuccess then: [ self stop ].
			exit pass
			]
		]
	] unless: self isDebugModeEnabled
]

{ #category : #'private - activation/deactivation' }
StargateApplication >> configureHTTPClientLogging [

	self stargateConfiguration enableHTTPClientLogging then: [ 
		ZnLogEvent announcer when: ZnClientTransactionEvent do: [ :event | 
			LaunchpadLogRecord
				emitStructuredDebuggingInfo: 'HTTP Client event received'
				with: [ :data | self dumpDataOf: event on: data ] ] ]
]

{ #category : #'private - activation/deactivation' }
StargateApplication >> configureHTTPServerLogging [

	self stargateConfiguration enableHTTPServerLogging then: [ 
		ZnLogEvent announcer
			when: ZnServerTransactionEvent , ZnSimplifiedServerTransactionEvent
			do: [ :event | 
				LaunchpadLogRecord
					emitStructuredDebuggingInfo: 'HTTP Server event received'
					with: [ :data | self dumpDataOf: event on: data ] ] ].

	ZnLogEvent announcer
		when: ZnServerHandlerErrorEvent
		do: [ :event | LaunchpadLogRecord emitError: event exception messageText ]
]

{ #category : #'private - accessing' }
StargateApplication >> controllersToInstall [

	^ self subclassResponsibility
]

{ #category : #'private - activation/deactivation' }
StargateApplication >> createAPI [

	| api |

	LaunchpadLogRecord emitInfo: 'Creating API' during: [ 
		api := HTTPBasedRESTfulAPI configuredBy: self apiConfiguration
			       installing: self controllersToInstall ].
	^ api
]

{ #category : #'private - activation/deactivation' }
StargateApplication >> dumpDataOf: aZincEvent on: aLogRecordJson [

	| eventJson |
	eventJson := NeoJSONObject fromString:
		             (String streamContents: [ :stream | 
			              (NeoJSONWriter on: stream)
				              mapZincEvent;
				              nextPut: aZincEvent ]).
	aLogRecordJson
		at: #summary put: eventJson summary;
		at: #request put: eventJson request;
		at: #response put: eventJson response
]

{ #category : #initialization }
StargateApplication >> initialize [

	super initialize.
	apiOptional := Optional unused
]

{ #category : #'private - activation/deactivation' }
StargateApplication >> installAndStart: api [

	LaunchpadLogRecord
		emitInfo: 'Installing API' during: [ api install ];
		emitInfo: 'Starting API' during: [ api start ]
]

{ #category : #'private - activation/deactivation' }
StargateApplication >> logAPIVersion [

	BasicApplicationInformationProvider new applicationNamed: self class commandName
		describedBy: self class description
		version: self class version.
	LaunchpadLogRecord emitInfo: ( 'API Version: <1s>' expandMacrosWith: self class version )
]

{ #category : #'private - accessing' }
StargateApplication >> loggersConfiguration [

	^ Dictionary new
		  at: #enabled put: true;
		  yourself
]

{ #category : #'private - accessing' }
StargateApplication >> metricsConfiguration [

	^ Dictionary new
		  at: #enabled put: true;
		  at: #metrics put: MetricProvider allProviderNames;
		  at: HTTPMetrics providerName put: ( Dictionary new
				    at: #breakdownCategories put: #( http_method response_code url_template );
				    yourself );
		  yourself
]

{ #category : #'private - accessing' }
StargateApplication >> operationsConfiguration [

	^ Dictionary new
		  at: #authSchema put: 'jwt';
		  at: #authAlgorithm put: self authAlgorithm;
		  at: #authSecret put: self stargateConfiguration operationsSecret;
		  at: MetricsPlugin endpoint put: self metricsConfiguration;
		  at: ApplicationInfoPlugin endpoint put: self applicationInfoConfiguration;
		  at: ApplicationConfigurationPlugin endpoint put: self applicationConfigurationConfiguration;
		  at: ApplicationControlPlugin endpoint put: self applicationControlConfiguration;
		  at: LoggersPlugin endpoint put: self loggersConfiguration;
		  yourself
]

{ #category : #'error handling' }
StargateApplication >> stackTraceDumper [

	^ StackTraceBinarySerializer on: [ :dumpAction | 
		  self class fileReferenceToDumpStackTrace binaryWriteStreamDo: dumpAction ]
]

{ #category : #'private - accessing' }
StargateApplication >> stargateConfiguration [

	^ self configuration stargate
]
