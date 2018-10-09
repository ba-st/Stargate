Class {
	#name : #PetsWebServiceSpecification,
	#superclass : #WebServiceSpecification,
	#category : #'Stargate-REST-API-Tests'
}

{ #category : #'mapping rules' }
PetsWebServiceSpecification >> addJsonEncoderVersion1dot0dot0MappingIn: aBuilder [

	aBuilder 	
		addDefaultRuleToEncode: #pets
		to: self applicationJsonVersion1dot0dot0
		using: self petJsonEncoderVersion1dot0dot0
]

{ #category : #'accessing - media types' }
PetsWebServiceSpecification >> applicationJsonVersion1dot0dot0 [

	^ ZnMimeType fromString: 'application/json;version=1.0.0'
]

{ #category : #routes }
PetsWebServiceSpecification >> createPetRoute [

	^ RouteSpecification handling: #POST at: '/pets' sending: #createPetBasedOn:within:
]

{ #category : #routes }
PetsWebServiceSpecification >> getPetsRoute [

	| route |

	route := RouteSpecification handling: #GET at: '/pets' sending: #getPetsBasedOn:within:.

	^ route asCorsAware
]

{ #category : #'mapping rules' }
PetsWebServiceSpecification >> petJsonEncoderVersion1dot0dot0 [

	^ [ :point | 
	String
		streamContents: [ :stream | 
			(NeoJSONWriter on: stream)
				for: Point
					do: [ :mapping | 
					mapping
						mapAccessor: #x;
						mapAccessor: #y ];
				nextPut: point ] ]
]
