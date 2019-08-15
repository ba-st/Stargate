"
I'm an encoding rule. 
I'm responsible of generating an Entity with the provided media type encoding a resource into it's representation.
"
Class {
	#name : #ResourceEncodingRule,
	#superclass : #Object,
	#instVars : [
		'mediaType',
		'encodingBlock'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #'instance creation' }
ResourceEncodingRule class >> encoding: aMediaType using: aWriter [

	^ self new initializeMapping: aMediaType using: aWriter
]

{ #category : #encoding }
ResourceEncodingRule >> encode: resource within: requestContext [

	^ ZnEntity with: ( encodingBlock cull: resource cull: requestContext ) ofType: mediaType
]

{ #category : #initialization }
ResourceEncodingRule >> initializeMapping: aMediaType using: anEncodingBlock [

	encodingBlock := anEncodingBlock.
	mediaType := aMediaType
]
