"
I'm an example RESTful Web Service specification implementing Pet resource management
"
Class {
	#name : #PetsRESTfulControllerSpecification,
	#superclass : #ResourceRESTfulControllerSpecification,
	#category : #'Stargate-Examples'
}

{ #category : #'mapping rules' }
PetsRESTfulControllerSpecification >> addJsonDecoderVersion1dot0dot0MappingIn: aBuilder [

	aBuilder
		addDefaultRuleToDecode: self petVersion1dot0dot0MediaType
		to: self petMappingKey
		using: [ :json | NeoJSONObject fromString: json ]
]

{ #category : #'mapping rules' }
PetsRESTfulControllerSpecification >> addJsonEncoderVersion1dot0dot0MappingIn: aBuilder [

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
								mapHypermediaControlsIn: context ];
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
								mapHypermediaControlsIn: context ];
						nextPut: pet ] ];
		addDefaultRuleToEncode: self petsMappingKey
			to: self petSummaryVersion1dot0dot0MediaType
			using: [ :pets :context | 
			String
				streamContents: [ :stream | 
					(NeoJSONWriter on: stream)
						for: Pet
							do: [ :mapping | 
							mapping
								mapInstVar: #name;
								mapAsHypermediaControls: [ :pet | context hypermediaControlsFor: pet ] ];
						nextPut:
							{('items' -> pets).
							('links' -> (context hypermediaControls collect: [ :assoc  | assoc key  -> assoc value printString ]) asDictionary)} asDictionary ] ]
]

{ #category : #routes }
PetsRESTfulControllerSpecification >> createPetRoute [

	^ RouteSpecification handling: #POST at: self endpoint evaluating: [ :service :httpRequest :context | service createPetBasedOn: httpRequest within: context ]
]

{ #category : #routes }
PetsRESTfulControllerSpecification >> deletePetRoute [

	^ RouteSpecification handling: #DELETE at: self idTemplate evaluating: [ :service :httpRequest :context | service deletePetBasedOn: httpRequest within: context ]
]

{ #category : #'private - accessing' }
PetsRESTfulControllerSpecification >> endpoint [

	^ '/pets'
]

{ #category : #routes }
PetsRESTfulControllerSpecification >> getPetRoute [

	^ RouteSpecification handling: #GET at: self idTemplate evaluating: [ :service :httpRequest :context | service getPetBasedOn: httpRequest within: context ]
]

{ #category : #routes }
PetsRESTfulControllerSpecification >> getPetsRoute [

	^ RouteSpecification handling: #GET at: self endpoint evaluating: [ :service :httpRequest :context | service getPetsBasedOn: httpRequest within: context ]
]

{ #category : #'private - accessing' }
PetsRESTfulControllerSpecification >> idTemplate [

	^ '<1s>/%<<2s>:IsInteger>' expandMacrosWith: self endpoint with: self identifierKey
]

{ #category : #accessing }
PetsRESTfulControllerSpecification >> identifierKey [

	^ #identifier
]

{ #category : #accessing }
PetsRESTfulControllerSpecification >> petMappingKey [

	^ #pet
]

{ #category : #'accessing - media types' }
PetsRESTfulControllerSpecification >> petSummaryVersion1dot0dot0MediaType [

	^ 'application/vnd.stargate.pet.summary+json;version=1.0.0' asMediaType 
]

{ #category : #'accessing - media types' }
PetsRESTfulControllerSpecification >> petVersion1dot0dot0MediaType [

	^ 'application/vnd.stargate.pet+json;version=1.0.0' asMediaType 
]

{ #category : #accessing }
PetsRESTfulControllerSpecification >> petsMappingKey [

	^ #pets
]

{ #category : #routes }
PetsRESTfulControllerSpecification >> updatePetRoute [

	^ RouteSpecification handling: #PATCH at: self idTemplate evaluating: [ :service :httpRequest :context | service updatePetBasedOn: httpRequest within: context ]
]
