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

{ #category : #accessing }
StargateApplication class >> configurationParameters [

	^ self stargateConfigurationParameters
]

{ #category : #private }
StargateApplication class >> fileReferenceToDumpStackTrace [

	| logsDirectory stackTraceDumpFile |

	logsDirectory := self logsDirectory.

	[
	| timestamp random |

	random := UUID new asString36.
	timestamp := String streamContents: [ :stream |
		             | now |

		             now := DateAndTime now.
		             now printYMDOn: stream.
		             stream nextPut: $_.
		             now printHMSOn: stream separatedBy: $-
		             ].
	stackTraceDumpFile := logsDirectory / ( '<1s>_<2s>_<3s>.<4s>'
		                        expandMacrosWith: self commandName
		                        with: timestamp
		                        with: random
		                        with: self stackTraceDumpExtension ).
	stackTraceDumpFile exists
	] whileTrue.

	^ stackTraceDumpFile
]

{ #category : #initialization }
StargateApplication class >> initializeVersion [

	<ignoreForCoverage>
	Version := VersionFromRepositoryResolver new valueFor: self projectName
]

{ #category : #testing }
StargateApplication class >> isAbstract [

	^ self = StargateApplication
]

{ #category : #private }
StargateApplication class >> logsDirectory [

	^ ( FileLocator workingDirectory / 'logs' ) ensureCreateDirectory
]

{ #category : #private }
StargateApplication class >> projectName [

	^ self subclassResponsibility
]

{ #category : #private }
StargateApplication class >> sectionsForStargateConfiguration [

	^ #('Stargate')
]

{ #category : #private }
StargateApplication class >> stackTraceDumpExtension [

	^ 'dump'
]

{ #category : #private }
StargateApplication class >> stargateConfigurationParameters [

	^ Array
		  with: ( MandatoryConfigurationParameter named: 'Public URL'
				    describedBy: 'Public URL where the API is deployed. Used to create hypermedia links'
				    inside: self sectionsForStargateConfiguration
				    convertingWith: #asUrl )
		  with: ( MandatoryConfigurationParameter named: 'Port'
				    describedBy: 'Listening port'
				    inside: self sectionsForStargateConfiguration
				    convertingWith: #asNumber )
		  with: ( MandatoryConfigurationParameter named: 'Operations Secret'
				    describedBy: 'Secret key for checking JWT signatures'
				    inside: self sectionsForStargateConfiguration
				    convertingWith: #asByteArray ) asSensitive
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
	"The signing algorithm identifier as defined in https://datatracker.ietf.org/doc/html/rfc7518#section-3.1.
	Used for securing operational plugins, by default HMAC using SHA-256"

	^ 'HS256'
]

{ #category : #'private - activation/deactivation' }
StargateApplication >> basicStartWithin: context [

	| api |

	self logAPIVersion.
	api := self createAPI.
	self
		configureGlobalErrorHandlerIn: api;
		installAndStart: api.
	apiOptional := Optional containing: api
]

{ #category : #'private - activation/deactivation' }
StargateApplication >> basicStop [

	apiOptional withContentDo: [ :api | api stop ].
	super basicStop
]

{ #category : #'private - activation/deactivation' }
StargateApplication >> configureGlobalErrorHandlerIn: api [
	 
	[
	LogRecord emitInfo: 'Configuring error handlers' during: [
		api
			on: Error addErrorHandler: [ :error |
				LogRecord emitError: ( 'Unexpected error: "<1s>"' expandMacrosWith: error messageText ).
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

{ #category : #'private - accessing' }
StargateApplication >> controllersToInstall [

	^ self subclassResponsibility
]

{ #category : #'private - activation/deactivation' }
StargateApplication >> createAPI [

	| api |

	LogRecord emitInfo: 'Creating API' during: [ 
		api := HTTPBasedRESTfulAPI configuredBy: self apiConfiguration
			       installing: self controllersToInstall ].
	^ api
]

{ #category : #initialization }
StargateApplication >> initialize [

	super initialize.
	apiOptional := Optional unused
]

{ #category : #'private - activation/deactivation' }
StargateApplication >> installAndStart: api [

	LogRecord
		emitInfo: 'Installing API' during: [ api install ];
		emitInfo: 'Starting API' during: [ api start ]
]

{ #category : #'private - activation/deactivation' }
StargateApplication >> logAPIVersion [

	BasicApplicationInformationProvider new applicationNamed: self class commandName
		describedBy: self class description
		version: self class version.
	LogRecord emitInfo: ( 'API Version: <1s>' expandMacrosWith: self class version )
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

	^ StackTraceTextDumper on: [ :dumpAction |
		  self class fileReferenceToDumpStackTrace writeStreamDo: [ :stream |
			  dumpAction value: ( ZnNewLineWriterStream on: stream ) ]
		  ]
]

{ #category : #'private - accessing' }
StargateApplication >> stargateConfiguration [

	^ self configuration stargate
]
