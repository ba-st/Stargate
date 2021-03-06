"
I'm a controller exposing the API of ApplicationInfoPlugin
"
Class {
	#name : #ApplicationConfigurationRESTfulController,
	#superclass : #OperationsRESTfulController,
	#instVars : [
		'requestHandler',
		'plugin'
	],
	#category : #'Stargate-Application-Configuration'
}

{ #category : #'instance creation' }
ApplicationConfigurationRESTfulController class >> over: aPlugin configuredBy: configuration [

	^ ( self authenticationFilterBasedOn: configuration ) initializeOver: aPlugin
]

{ #category : #private }
ApplicationConfigurationRESTfulController >> configureConfigurationEncodingOn: writer [

	CommandLineArgument
		subclassesDo: [ :subclass | 
			writer
				for: subclass
				do: [ :mapper | 
					mapper
						mapAccessor: #name;
						mapProperty: #'current-value'
							getter: [ :definition | self currentValueOrMaskFor: definition ]
					]
			].

	writer
		for: MandatoryArgument
			do: [ :mapper | mapper mapProperty: #type getter: [ :definition | 'mandatory' ] ];
		for: FlagArgument do: [ :mapper | mapper mapProperty: #type getter: [ :definition | 'flag' ] ];
		for: OptionalArgument
			do: [ :mapper | 
			mapper
				mapProperty: #type getter: [ :definition | 'optional' ];
				mapAccessor: #default
			];
		for: SensitiveArgument
			do: [ :mapper | mapper mapProperty: #type getter: [ :definition | 'sensitive' ] ];
		for: ZnUrl customDo: [ :mapping | mapping encoder: [ :url | url printString ] ]
]

{ #category : #private }
ApplicationConfigurationRESTfulController >> currentValueOrMaskFor: definition [

	^ ( definition isA: SensitiveArgument )
		then: [ '********' ]
		otherwise: [ plugin currentValueFor: definition ]
]

{ #category : #routes }
ApplicationConfigurationRESTfulController >> declareGetApplicationConfigurationRoute [

	^ RouteSpecification
		handling: #GET
		at: self endpoint
		evaluating:
			[ :httpRequest :requestContext | self getApplicationConfigurationBasedOn: httpRequest within: requestContext ]
]

{ #category : #private }
ApplicationConfigurationRESTfulController >> encodeConfigurationInTextFormat: configurationDefinitions [

	^ String
		streamContents: [ :stream | 
			configurationDefinitions
				do: [ :definition | 
					stream
						nextPutAll: definition name;
						space;
						nextPut: $=;
						space;
						nextPutAll: ( self currentValueOrMaskFor: definition ) asString
					]
				separatedBy: [ stream crlf ]
			]
]

{ #category : #API }
ApplicationConfigurationRESTfulController >> getApplicationConfigurationBasedOn: httpRequest within: requestContext [

	self assert: httpRequest isAuthorizedWithin: requestContext.

	^ requestHandler
		from: httpRequest
		within: requestContext
		getCollection: [ plugin configurationDefinitions ]
]

{ #category : #initialization }
ApplicationConfigurationRESTfulController >> initializeOver: aPlugin [

	plugin := aPlugin.
	self initializeRequestHandler
]

{ #category : #initialization }
ApplicationConfigurationRESTfulController >> initializeRequestHandler [

	requestHandler := RESTfulRequestHandlerBuilder new
		handling: ( 'operations/<1s>' expandMacrosWith: self pluginEndpoint );
		whenResponding: self operationalApplicationConfigurationVersion1dot0dot0MediaType
			encodeToJsonApplying: [ :resource :requestContext :writer | self configureConfigurationEncodingOn: writer ];
		whenResponding: self plainTextVersion1dot0dot0MediaType
			encodeApplying: [ :resource | self encodeConfigurationInTextFormat: resource ];
		createEntityTagHashingEncodedResource;
		build
]

{ #category : #private }
ApplicationConfigurationRESTfulController >> operationalApplicationConfigurationVersion1dot0dot0MediaType [

	^ self
		jsonMediaType: 'operational-application-configuration'
		vendoredBy: 'stargate'
		version: '1.0.0'
]

{ #category : #private }
ApplicationConfigurationRESTfulController >> plainTextVersion1dot0dot0MediaType [

	^ ZnMimeType textPlain version: '1.0.0'
]

{ #category : #private }
ApplicationConfigurationRESTfulController >> pluginEndpoint [

	^ plugin class endpoint
]

{ #category : #private }
ApplicationConfigurationRESTfulController >> requestHandler [

	^ requestHandler
]

{ #category : #private }
ApplicationConfigurationRESTfulController >> requiredPermission [

	^ 'read:<1s>' expandMacrosWith: self pluginEndpoint
]
