"
I'm a RESTful controller providing access to the list of available operational plugins and its endpoints
"
Class {
	#name : #OperationalPluginsRESTfulController,
	#superclass : #SingleResourceRESTfulController,
	#instVars : [
		'requestHandler',
		'api'
	],
	#category : #'Stargate-Model-Operations'
}

{ #category : #'instance creation' }
OperationalPluginsRESTfulController class >> on: anHTTPBasedRESTfulAPI [

	^ self new initializeOn: anHTTPBasedRESTfulAPI
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
	requestHandler := RESTfulRequestHandlerBuilder new
		handling: 'operations'
			locatingResourcesWith: [ :plugin | plugin endpoint ]
			extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ];
		beHypermediaDriven;
		whenResponding: self operationalPluginVersion1dot0dot0MediaType
			encodeToJsonApplying: [ :resource :requestContext :writer | 
			OperationalPlugin availablePlugins
				do: [ :pluginClass | 
					writer
						for: pluginClass class
						do: [ :mapping | 
							mapping
								mapProperty: #name getter: [ :plugin | plugin pluginName asString ];
								mapProperty: #status getter: [ :plugin | self statusOf: plugin ];
								mapAsHypermediaControls: [ :plugin | requestContext hypermediaControlsFor: plugin ]
							]
					]
			];
		createEntityTagHashing: [ :hasher :plugin :requestContext | 
			hasher
				include: plugin pluginName;
				include: ( self statusOf: plugin )
			];
		build
]

{ #category : #private }
OperationalPluginsRESTfulController >> operationalPluginVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'operational-plugin' vendoredBy: 'stargate' version: '1.0.0'
]

{ #category : #API }
OperationalPluginsRESTfulController >> operationalPluginsBasedOn: httpRequest within: requestContext [

	^ requestHandler
		from: httpRequest
		within: requestContext
		getCollection: [ OperationalPlugin availablePlugins ]
]

{ #category : #private }
OperationalPluginsRESTfulController >> requestHandler [

	^ requestHandler
]

{ #category : #querying }
OperationalPluginsRESTfulController >> statusOf: aPlugin [

	^ ( api isEnabled: aPlugin ) then: [ 'ENABLED' ] otherwise: [ 'DISABLED' ]
]

{ #category : #private }
OperationalPluginsRESTfulController >> typeIdConstraint [

	^ IsObject
]
