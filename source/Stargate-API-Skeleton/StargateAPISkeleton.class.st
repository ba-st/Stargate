Class {
	#name : #StargateAPISkeleton,
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
StargateAPISkeleton class >> applicationBaselineName [

	^ self subclassResponsibility
]

{ #category : #accessing }
StargateAPISkeleton class >> configurationParameters [

	^ self stargateConfigurationParameters
]

{ #category : #private }
StargateAPISkeleton class >> fileReferenceToDumpStackTrace [

	^ self logsDirectory / ( '<1s>-<2s>.fuel' expandMacrosWith: self commandName
		    with: ( ( ZTimestampFormat fromString: '2001-02-03_16-05-06.07' ) format: ZTimestamp now ) )
]

{ #category : #initialization }
StargateAPISkeleton class >> initializeVersion [

	<ignoreForCoverage>
	Version := VersionFromRepositoryResolver new valueFor: self applicationBaselineName
]

{ #category : #testing }
StargateAPISkeleton class >> isAbstract [

	^ self = StargateAPISkeleton
]

{ #category : #private }
StargateAPISkeleton class >> logsDirectory [

	^ FileLocator workingDirectory / 'logs'
]

{ #category : #private }
StargateAPISkeleton class >> sectionsForStargateConfiguration [

	^ #('Stargate')
]

{ #category : #private }
StargateAPISkeleton class >> stargateConfigurationParameters [

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
StargateAPISkeleton class >> version [

	^ Version
]

{ #category : #'private - accessing' }
StargateAPISkeleton >> apiConfiguration [

	^ Array with: #serverUrl -> self stargateConfiguration publicURL
		  with: #port -> self stargateConfiguration port
		  with: #debugMode -> self isDebugModeEnabled
		  with: #operations -> self operationsConfiguration
]

{ #category : #'private - accessing' }
StargateAPISkeleton >> applicationConfigurationConfiguration [

	^ Dictionary new
		  at: #enabled put: true;
		  at: #definitions put: self class configurationParameters;
		  at: #provider put: [ self configuration ];
		  yourself
]

{ #category : #'private - accessing' }
StargateAPISkeleton >> applicationControlCommandsToEnable [

	"This method must return an array of application control command names to be enabled"

	^ #(  )
]

{ #category : #'private - accessing' }
StargateAPISkeleton >> applicationControlConfiguration [

	^ Dictionary new
		  at: #enabled put: true;
		  at: #commands put: #( 'shutdown' ) , self applicationControlCommandsToEnable;
		  yourself
]

{ #category : #'private - accessing' }
StargateAPISkeleton >> applicationInfoConfiguration [

	^ Dictionary new
		at: #enabled put: true;
		at: #'info-providers' put: ApplicationInformationProvider allProviderNames;
		yourself
]

{ #category : #'private - accessing' }
StargateAPISkeleton >> authAlgorithm [

	^ JWAHMACSHA256 parameterValue
]

{ #category : #'private - activation' }
StargateAPISkeleton >> basicStartWithin: context [

	| api |

	self logAPIVersion.
	api := self createAPI.
	self
		configureGlobalErrorHandlerIn: api;
		installAndStart: api.
	apiOptional := Optional containing: api
]

{ #category : #'private - activation' }
StargateAPISkeleton >> configureGlobalErrorHandlerIn: api [

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
StargateAPISkeleton >> controllersToInstall [

	^ self subclassResponsibility
]

{ #category : #'private - activation' }
StargateAPISkeleton >> createAPI [

	| api |

	LaunchpadLogRecord emitInfo: 'Creating API' during: [ 
		api := HTTPBasedRESTfulAPI configuredBy: self apiConfiguration
			       installing: self controllersToInstall ].
	^ api
]

{ #category : #initialization }
StargateAPISkeleton >> initializeRunningIn: anApplicationMode configuredBy: aConfigurationProvider [

	super initializeRunningIn: anApplicationMode configuredBy: aConfigurationProvider.
	apiOptional := Optional unused
]

{ #category : #'private - activation' }
StargateAPISkeleton >> installAndStart: api [

	LaunchpadLogRecord
		emitInfo: 'Installing API' during: [ api install ];
		emitInfo: 'Starting API' during: [ api start ]
]

{ #category : #'private - activation' }
StargateAPISkeleton >> logAPIVersion [

	BasicApplicationInformationProvider new applicationNamed: self class commandName
		describedBy: self class description
		version: self class version.
	LaunchpadLogRecord emitInfo: ( 'API Version: <1s>' expandMacrosWith: self class version )
]

{ #category : #'private - accessing' }
StargateAPISkeleton >> metricsConfiguration [

	^ Dictionary new
		  at: #enabled put: true;
		  at: #metrics put: MetricProvider allProviderNames;
		  at: HTTPMetrics providerName put: ( Dictionary new
				    at: #breakdownCategories put: #( http_method response_code url_template );
				    yourself );
		  yourself
]

{ #category : #'private - accessing' }
StargateAPISkeleton >> operationsConfiguration [

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
StargateAPISkeleton >> stackTraceDumper [

	^ StackTraceBinarySerializer on: [ :dumpAction | 
		  self class fileReferenceToDumpStackTrace binaryWriteStreamDo: dumpAction ]
]

{ #category : #'private - accessing' }
StargateAPISkeleton >> stargateConfiguration [

	^ self configuration stargate
]

{ #category : #'private - activation' }
StargateAPISkeleton >> stop [

	apiOptional withContentDo: [ :api | api stop ]
]
