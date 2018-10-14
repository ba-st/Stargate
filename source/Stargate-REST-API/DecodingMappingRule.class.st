Class {
	#name : #DecodingMappingRule,
	#superclass : #MappingRule,
	#category : #'Stargate-REST-API'
}

{ #category : #'instance creation' }
DecodingMappingRule class >> decoding: aMediaType to: anObjectType using: aReader [

	^ self between: anObjectType and: aMediaType using: aReader
]

{ #category : #applying }
DecodingMappingRule >> applyOn: anObjectToDecode within: aContext [

	^ mapper cull: anObjectToDecode cull: aContext
]
