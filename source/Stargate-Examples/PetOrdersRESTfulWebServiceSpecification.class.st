Class {
	#name : #PetOrdersRESTfulWebServiceSpecification,
	#superclass : #RESTFulWebServiceSpecification,
	#category : #'Stargate-Examples'
}

{ #category : #'mapping rules' }
PetOrdersRESTfulWebServiceSpecification >> addJsonDecoderVersion1dot0dot0MappingIn: aBuilder [

	aBuilder
		addDefaultRuleToDecode: self orderVersion1dot0dot0MediaType
		to: self orderMappingKey
		using: [ :json | 
			(NeoJSONReader on: json readStream)
				for: PetOrder
					do: [ :mapping | 
					mapping
						mapInstVar: #date;
						mapProperty: #pet getter: [ :order |  ] setter: [ :order :url | order instVarNamed: 'pet' put: url asUrl ] ];
				nextAs: PetOrder ]
]

{ #category : #'mapping rules' }
PetOrdersRESTfulWebServiceSpecification >> addJsonEncoderVersion1dot0dot0MappingIn: aBuilder [

	aBuilder
		addDefaultRuleToEncode: self orderMappingKey
		to: self orderVersion1dot0dot0MediaType
		using: [ :order :context | 
			String
				streamContents: [ :stream | 
					(NeoJSONWriter on: stream)
						for: ZnUrl customDo: [ :mapping | mapping encoder: [ :url | url printString ] ];
						for: PetOrder
							do: [ :mapping | 
							mapping
								mapInstVars;
								mapProperty: #status getter: [ :object | context objectUnder: #status ifNone: [ '' ] ] setter: [ :object :value |  ];
								mapHypermediaControlsIn: context ];
						nextPut: order ] ]
]

{ #category : #routes }
PetOrdersRESTfulWebServiceSpecification >> cancelOrderRoute [

	^ RouteSpecification handling: #POST at: self cancelTemplate evaluating: [ :service :httpRequest :context | service cancelOrderBasedOn: httpRequest within: context ]
]

{ #category : #'private - accessing' }
PetOrdersRESTfulWebServiceSpecification >> cancelTemplate [

	^ '<1s>/<2s:IsInteger>/cancel' expandMacrosWith: self endpoint with: self identifierKey
]

{ #category : #routes }
PetOrdersRESTfulWebServiceSpecification >> completeOrderRoute [

	^ RouteSpecification handling: #POST at: self completeTemplate evaluating: [ :service :httpRequest :context | service completeOrderBasedOn: httpRequest within: context ]
]

{ #category : #'private - accessing' }
PetOrdersRESTfulWebServiceSpecification >> completeTemplate [

	^ '<1s>/<2s:IsInteger>/complete' expandMacrosWith: self endpoint with: self identifierKey
]

{ #category : #routes }
PetOrdersRESTfulWebServiceSpecification >> createOrderRoute [

	^ RouteSpecification handling: #POST at: self endpoint evaluating: [ :service :httpRequest :context | service createOrderBasedOn: httpRequest within: context ]
]

{ #category : #'private - accessing' }
PetOrdersRESTfulWebServiceSpecification >> endpoint [

	^ '/orders'
]

{ #category : #routes }
PetOrdersRESTfulWebServiceSpecification >> getOrderRoute [

	^ RouteSpecification handling: #GET at: self idTemplate evaluating: [ :service :httpRequest :context | service getOrderBasedOn: httpRequest within: context ]
]

{ #category : #'private - accessing' }
PetOrdersRESTfulWebServiceSpecification >> idTemplate [

	^ '<1s>/<2s:IsInteger>' expandMacrosWith: self endpoint with: self identifierKey
]

{ #category : #accessing }
PetOrdersRESTfulWebServiceSpecification >> identifierKey [

	^ #identifier
]

{ #category : #accessing }
PetOrdersRESTfulWebServiceSpecification >> orderMappingKey [

	^ #order
]

{ #category : #accessing }
PetOrdersRESTfulWebServiceSpecification >> orderVersion1dot0dot0MediaType [

	^ 'application/vnd.stargate.order+json;version=1.0.0' asMediaType 
]
