"
I'm one of the operational plugins.
I provide information of the running system.
"
Class {
	#name : #ApplicationInfoPlugin,
	#superclass : #OperationalPlugin,
	#instVars : [
		'informationProviders'
	],
	#category : #'Stargate-Application-Info'
}

{ #category : #'instance creation' }
ApplicationInfoPlugin class >> configureMediaControlsIn: builder within: requestContext [

	builder
		addRelativeLink: ( 'operations/<1s>' expandMacrosWith: self endpoint ) asUrl
		relatedTo: 'info'
]

{ #category : #'instance creation' }
ApplicationInfoPlugin class >> configuredBy: configuration [

	| selfConfiguration |

	selfConfiguration := self pluginConfigurationOn: configuration.

	^ self new
		initializeGatheringAll: ( selfConfiguration at: #'info-providers' ifAbsent: [ self defaultProviderNames ] )
]

{ #category : #accessing }
ApplicationInfoPlugin class >> endpoint [

	^ 'application-info'
]

{ #category : #accessing }
ApplicationInfoPlugin class >> pluginName [

	^ 'Application Information'
]

{ #category : #accessing }
ApplicationInfoPlugin >> gatherInformation [

	^ informationProviders
		inject: OrderedDictionary new
		into: [ :information :provider | 
			information
				at: provider name put: provider gatherInformation;
				yourself
			]
]

{ #category : #configuring }
ApplicationInfoPlugin >> includeControllersIn: api [

	api
		addController: ( ApplicationInfoRESTfulController over: self configuredBy: api operationsConfiguration )
]

{ #category : #initialization }
ApplicationInfoPlugin >> initializeGatheringAll: enabledInformationProviderNames [

	informationProviders := ApplicationInformationProvider allSubclasses
		select: [ :provider | enabledInformationProviderNames includes: provider providerName ]
		thenCollect: [ :providerClass | providerClass new ]
]
