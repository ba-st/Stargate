"
I'm an example RESTful Web Service specification implementing Pet Order resource management
"
Class {
	#name : #PetOrdersRESTfulControllerSpecification,
	#superclass : #ResourceRESTfulControllerSpecification,
	#category : #'Stargate-Examples'
}

{ #category : #'mapping rules' }
PetOrdersRESTfulControllerSpecification >> addJsonDecoderVersion1dot0dot0MappingIn: aBuilder [

	aBuilder
		addDefaultRuleToDecode: self orderVersion1dot0dot0MediaType
		to: self orderMappingKey
		using: [ :json | 
			(NeoJSONReader on: json readStream)
				for: PetOrder
					do: [ :mapping | 
					mapping
						mapInstVar: #date;
						mapProperty: #pet setter: [ :order :url | order instVarNamed: 'pet' put: url asUrl ] ];
				nextAs: PetOrder ]
]

{ #category : #'mapping rules' }
PetOrdersRESTfulControllerSpecification >> addJsonEncoderVersion1dot0dot0MappingIn: aBuilder [

	aBuilder
		addDefaultRuleToEncode: self orderMappingKey
		to: self orderVersion1dot0dot0MediaType
		using: [ :order :context | 
			String
				streamContents: [ :stream | 
					( NeoJSONWriter on: stream )
						for: ZnUrl customDo: [ :mapping | mapping encoder: [ :url | url printString ] ];
						for: PetOrder
							do: [ :mapping | 
							mapping
								mapInstVars;
								mapProperty: #status getter: [ :object | context objectUnder: #status ];
								mapHypermediaControlsIn: context
							];
						nextPut: order
					]
			]
]

{ #category : #routes }
PetOrdersRESTfulControllerSpecification >> cancelOrderRoute [

	^ RouteSpecification
		handling: #POST
		at: self cancelTemplate
		evaluating: [ :controller :httpRequest :context | controller cancelOrderBasedOn: httpRequest within: context ]
]

{ #category : #'private - accessing' }
PetOrdersRESTfulControllerSpecification >> cancelTemplate [

	^ '<1s>/%<<2s>:IsInteger>/cancel' expandMacrosWith: self endpoint with: self identifierKey
]

{ #category : #routes }
PetOrdersRESTfulControllerSpecification >> completeOrderRoute [

	^ RouteSpecification
		handling: #POST
		at: self completeTemplate
		evaluating: [ :controller :httpRequest :context | controller completeOrderBasedOn: httpRequest within: context ]
]

{ #category : #'private - accessing' }
PetOrdersRESTfulControllerSpecification >> completeTemplate [

	^ '<1s>/%<<2s>:IsInteger>/complete' expandMacrosWith: self endpoint with: self identifierKey
]

{ #category : #routes }
PetOrdersRESTfulControllerSpecification >> createOrderRoute [

	^ RouteSpecification
		handling: #POST
		at: self endpoint
		evaluating: [ :controller :httpRequest :context | controller createOrderBasedOn: httpRequest within: context ]
]

{ #category : #'private - accessing' }
PetOrdersRESTfulControllerSpecification >> endpoint [

	^ '/orders'
]

{ #category : #routes }
PetOrdersRESTfulControllerSpecification >> getOrderRoute [

	^ RouteSpecification
		handling: #GET
		at: self idTemplate
		evaluating: [ :controller :httpRequest :context | controller getOrderBasedOn: httpRequest within: context ]
]

{ #category : #'private - accessing' }
PetOrdersRESTfulControllerSpecification >> idTemplate [

	^ '<1s>/%<<2s>:IsInteger>' expandMacrosWith: self endpoint with: self identifierKey
]

{ #category : #accessing }
PetOrdersRESTfulControllerSpecification >> identifierKey [

	^ #identifier
]

{ #category : #accessing }
PetOrdersRESTfulControllerSpecification >> orderMappingKey [

	^ #order
]

{ #category : #accessing }
PetOrdersRESTfulControllerSpecification >> orderVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'order' vendoredBy: 'stargate' version: '1.0.0'
]
