"
I'm a RESTful controller providing access to the list of available operational plugins and its endpoints
"
Class {
	#name : #OperationalPluginsRESTfulController,
	#superclass : #OperationsRESTfulController,
	#instVars : [
		'requestHandler',
		'api'
	],
	#category : #'Stargate-Model-Operations'
}

{ #category : #'instance creation' }
OperationalPluginsRESTfulController class >> on: anHTTPBasedRESTfulAPI [

	^ ( self authenticationFilterBasedOn: anHTTPBasedRESTfulAPI operationsConfiguration )
		initializeOn: anHTTPBasedRESTfulAPI
]

{ #category : #private }
OperationalPluginsRESTfulController >> configureOperationalPluginEncodingOn: writer within: requestContext [

	OperationalPlugin availablePlugins
		do: [ :pluginType | 
			writer
				for: pluginType class
				do: [ :mapping | 
					mapping
						mapProperty: #name getter: [ :plugin | plugin pluginName asString ];
						mapProperty: #status getter: [ :plugin | self statusOf: plugin ];
						mapAsHypermediaControls: [ :plugin | requestContext hypermediaControlsFor: plugin ]
					]
			]
]

{ #category : #routes }
OperationalPluginsRESTfulController >> declareGetOperationalPluginRoute [

	^ RouteSpecification
		handling: #GET
		at: self identifierTemplate
		evaluating: [ :httpRequest :requestContext | self operationalPluginBasedOn: httpRequest within: requestContext ]
]

{ #category : #routes }
OperationalPluginsRESTfulController >> declareGetOperationalPluginsRoute [

	^ RouteSpecification
		handling: #GET
		at: self endpoint
		evaluating:
			[ :httpRequest :requestContext | self operationalPluginsBasedOn: httpRequest within: requestContext ]
]

{ #category : #initialization }
OperationalPluginsRESTfulController >> initializeOn: anHTTPBasedRESTfulAPI [

	api := anHTTPBasedRESTfulAPI.
	self initializeRequestHandler
]

{ #category : #initialization }
OperationalPluginsRESTfulController >> initializeRequestHandler [

	requestHandler := RESTfulRequestHandlerBuilder new
		handling: 'operations/plugins'
			locatingResourcesWith: [ :plugin | plugin endpoint ]
			extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ];
		beHypermediaDrivenBy:
				[ :builder :plugin :requestContext :pluginLocation | plugin configureMediaControlsIn: builder within: requestContext ];
		whenResponding: self operationalPluginVersion1dot0dot0MediaType
			encodeToJsonApplying:
				[ :resource :requestContext :writer | self configureOperationalPluginEncodingOn: writer within: requestContext ];
		createEntityTagHashing: [ :hasher :plugin :requestContext | 
			hasher
				include: plugin pluginName;
				include: ( self statusOf: plugin )
			];
		build
]

{ #category : #API }
OperationalPluginsRESTfulController >> operationalPluginBasedOn: httpRequest within: requestContext [

	self assert: httpRequest isAuthorizedWithin: requestContext.

	^ requestHandler
		from: httpRequest
		within: requestContext
		get: [ :endpoint | OperationalPlugin pluginAt: endpoint ]
]

{ #category : #private }
OperationalPluginsRESTfulController >> operationalPluginVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'operational-plugin' vendoredBy: 'stargate' version: '1.0.0'
]

{ #category : #API }
OperationalPluginsRESTfulController >> operationalPluginsBasedOn: httpRequest within: requestContext [

	self assert: httpRequest isAuthorizedWithin: requestContext.

	^ requestHandler
		from: httpRequest
		within: requestContext
		getCollection: [ OperationalPlugin availablePlugins ]
]

{ #category : #private }
OperationalPluginsRESTfulController >> requestHandler [

	^ requestHandler
]

{ #category : #private }
OperationalPluginsRESTfulController >> requiredPermission [

	^ 'read:operations'
]

{ #category : #querying }
OperationalPluginsRESTfulController >> statusOf: aPluginType [

	^ ( api isEnabled: aPluginType ) then: [ 'ENABLED' ] otherwise: [ 'DISABLED' ]
]
