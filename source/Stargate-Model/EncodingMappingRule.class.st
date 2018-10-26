Class {
	#name : #EncodingMappingRule,
	#superclass : #MappingRule,
	#category : #'Stargate-Model-Mapping'
}

{ #category : #'instance creation' }
EncodingMappingRule class >> encoding: anObjectType to: aMediaType using: aWriter [

	^ self between: anObjectType and: aMediaType using: aWriter
]

{ #category : #applying }
EncodingMappingRule >> applyOn: anObjectToEncode within: aContext [

	^ ZnEntity with: (mapper cull: anObjectToEncode cull: aContext) ofType: mediaType
]
