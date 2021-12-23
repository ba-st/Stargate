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

	^ JWAHMACSHA256 parameterValue
]

{ #category : #'private - activation' }
StargateApplication >> basicStartWithin: context [

	| api |

	self logAPIVersion.
	api := self createAPI.
	self
		configureGlobalErrorHandlerIn: api;
		installAndStart: api.
	apiOptional := Optional containing: api
]

{ #category : #'private - activation' }
StargateApplication >> configureGlobalErrorHandlerIn: api [

	[ 
	LaunchpadLogRecord emitInfo: 'Configuring error handlers' during: [ 
		api
			on: Error addErrorHandler: [ :error | 
				self stackTraceDumper dumpStackTraceFor: error.
				TeaResponse serverError
					body: error messageText;
					yourself
				];
			on: Exit addErrorHandler: [ :exit | 
			exit isSuccess then: [ api stop ].
			exit pass
			]
		]
	] unless: self isDebugModeEnabled
]

{ #category : #'private - accessing' }
StargateApplication >> controllersToInstall [

	^ self subclassResponsibility
]

{ #category : #'private - activation' }
StargateApplication >> createAPI [

	| api |

	LaunchpadLogRecord emitInfo: 'Creating API' during: [ 
		api := HTTPBasedRESTfulAPI configuredBy: self apiConfiguration
			       installing: self controllersToInstall ].
	^ api
]

{ #category : #initialization }
StargateApplication >> initializeRunningIn: anApplicationMode configuredBy: aConfigurationProvider [

	super initializeRunningIn: anApplicationMode configuredBy: aConfigurationProvider.
	apiOptional := Optional unused
]

{ #category : #'private - activation' }
StargateApplication >> installAndStart: api [

	LaunchpadLogRecord
		emitInfo: 'Installing API' during: [ api install ];
		emitInfo: 'Starting API' during: [ api start ]
]

{ #category : #'private - activation' }
StargateApplication >> logAPIVersion [

	BasicApplicationInformationProvider new applicationNamed: self class commandName
		describedBy: self class description
		version: self class version.
	LaunchpadLogRecord emitInfo: ( 'API Version: <1s>' expandMacrosWith: self class version )
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

{ #category : #'private - activation' }
StargateApplication >> stop [

	apiOptional withContentDo: [ :api | api stop ]
]
