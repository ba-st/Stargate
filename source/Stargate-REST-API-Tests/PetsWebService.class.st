Class {
	#name : #PetsWebService,
	#superclass : #Object,
	#instVars : [
		'mappingRuleSet',
		'pets'
	],
	#category : #'Stargate-REST-API-Tests'
}

{ #category : #'instance creation' }
PetsWebService class >> managing: aPetSet [ 
	
	^ self new initializeManaging: aPetSet 
]

{ #category : #'encoding and decoding' }
PetsWebService >> decode: aJSON encodedAs: aMediaType to: aKeyRepresentingObjectType within: aContext [

	^ (mappingRuleSet ruleToDecode: aMediaType to: aKeyRepresentingObjectType)
		applyOn: aJSON
		within: aContext
]

{ #category : #'encoding and decoding' }
PetsWebService >> encode: anObject of: aKeyRepresentingObjectType to: aMediaType within: aContext [

	^ (mappingRuleSet ruleToEncode: aKeyRepresentingObjectType to: aMediaType)
		applyOn: anObject
		within: aContext
]

{ #category : #initialization }
PetsWebService >> initializeManaging: aPetSet [

	pets := aPetSet.
	mappingRuleSet := (ReflectiveMappingRuleSetBuilder for: self specification) build
]

{ #category : #accessing }
PetsWebService >> specification [

	^ PetsWebServiceSpecification new
]
