Class {
	#name : #PetsRESTfulWebServiceSpecification,
	#superclass : #RESTFulWebServiceSpecification,
	#category : #'Stargate-Examples'
}

{ #category : #'mapping rules' }
PetsRESTfulWebServiceSpecification >> addJsonDecoderVersion1dot0dot0MappingIn: aBuilder [

	aBuilder
		addDefaultRuleToDecode: self petVersion1dot0dot0MediaType to: self petMappingKey using: [ :json | NeoJSONObject fromString: json ]
]

{ #category : #'mapping rules' }
PetsRESTfulWebServiceSpecification >> addJsonEncoderVersion1dot0dot0MappingIn: aBuilder [

	aBuilder
		addDefaultRuleToEncode: self petMappingKey
			to: self petVersion1dot0dot0MediaType
			using: [ :pet :context | 
			String
				streamContents: [ :stream | 
					(NeoJSONWriter on: stream)
						for: Pet
							do: [ :mapping | 
							mapping
								mapInstVars;
								mapProperty: #links getter: [ :thePet | (self mediaControlsIn: context) asDictionary ] setter: [ :object :value |  ] ];
						nextPut: pet ] ];
		addRuleToEncode: self petMappingKey
			to: self petSummaryVersion1dot0dot0MediaType
			using: [ :pet :context | 
			String
				streamContents: [ :stream | 
					(NeoJSONWriter on: stream)
						for: Pet
							do: [ :mapping | 
							mapping
								mapInstVar: #name;
								mapProperty: #links getter: [ :thePet | (self mediaControlsIn: context) asDictionary ] setter: [ :object :value |  ] ];
						nextPut: pet ] ];
		addDefaultRuleToEncode: self petsMappingKey
			to: self petSummaryVersion1dot0dot0MediaType
			using: [ :pets :context | 
			String
				streamContents: [ :stream | 
					| individualMediaControls |

					individualMediaControls := context objectUnder: #individualMediaControls ifNone: [ #() ].
					(NeoJSONWriter on: stream)
						for: Pet
							do: [ :mapping | 
							mapping
								mapInstVar: #name;
								mapProperty: #links getter: [ :pet | (individualMediaControls at: pet) asDictionary ] setter: [ :object :value |  ] ];
						nextPut:
							{('items' -> pets).
							('links' -> (self mediaControlsIn: context) asDictionary)} asDictionary ] ]
]

{ #category : #routes }
PetsRESTfulWebServiceSpecification >> createPetRoute [

	^ RouteSpecification handling: #POST at: self endpoint evaluating: [ :service :httpRequest :context | service createPetBasedOn: httpRequest within: context ]
]

{ #category : #routes }
PetsRESTfulWebServiceSpecification >> deletePet [

	^ RouteSpecification handling: #DELETE at: self idTemplate evaluating: [ :service :httpRequest :context | service deletePetBasedOn: httpRequest within: context ]
]

{ #category : #'private - accessing' }
PetsRESTfulWebServiceSpecification >> endpoint [

	^ '/pets'
]

{ #category : #routes }
PetsRESTfulWebServiceSpecification >> getPetRoute [

	^ RouteSpecification handling: #GET at: self idTemplate evaluating: [ :service :httpRequest :context | service getPetBasedOn: httpRequest within: context ]
]

{ #category : #routes }
PetsRESTfulWebServiceSpecification >> getPetsRoute [

	^ RouteSpecification handling: #GET at: '/pets' evaluating: [ :service :httpRequest :context | service getPetsBasedOn: httpRequest within: context ]
]

{ #category : #'private - accessing' }
PetsRESTfulWebServiceSpecification >> idTemplate [

	^ '<1s>/<2s:IsInteger>' expandMacrosWith: self endpoint with: self identifierKey
]

{ #category : #accessing }
PetsRESTfulWebServiceSpecification >> identifierKey [

	^ #identifier
]

{ #category : #'mapping rules' }
PetsRESTfulWebServiceSpecification >> mediaControlsIn: context [

	^ context objectUnder: #mediaControls ifNone: [ #() ]
]

{ #category : #accessing }
PetsRESTfulWebServiceSpecification >> petMappingKey [

	^ #pet
]

{ #category : #'accessing - media types' }
PetsRESTfulWebServiceSpecification >> petSummaryVersion1dot0dot0MediaType [

	^ 'application/vnd.stargate.pet.summary+json;version=1.0.0' asZnMimeType 
]

{ #category : #'accessing - media types' }
PetsRESTfulWebServiceSpecification >> petVersion1dot0dot0MediaType [

	^ 'application/vnd.stargate.pet+json;version=1.0.0' asZnMimeType 
]

{ #category : #accessing }
PetsRESTfulWebServiceSpecification >> petsMappingKey [

	^ #pets
]

{ #category : #routes }
PetsRESTfulWebServiceSpecification >> updatePetRoute [

	^ RouteSpecification handling: #PUT at: self endpoint evaluating: [ :service :httpRequest :context | service updatePetBasedOn: httpRequest within: context ]
]

{ #category : #routes }
PetsRESTfulWebServiceSpecification >> updatePetStatusRoute [

	^ RouteSpecification handling: #PATCH at: self idTemplate evaluating: [ :service :httpRequest :context | service updatePetStatusBasedOn: httpRequest within: context ]
]
