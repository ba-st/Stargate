Class {
	#name : #CrossOriginResourceSharingHandler,
	#superclass : #Object,
	#instVars : [
		'headers'
	],
	#category : #'Stargate-Model-CORS'
}

{ #category : #configuring }
CrossOriginResourceSharingHandler >> add: aValue toHeaderNamed: aName [

	headers
		at: aName
		ifPresent: [ :values | values add: aValue ]
		ifAbsentPut: ( OrderedCollection with: aValue )
]

{ #category : #evaluating }
CrossOriginResourceSharingHandler >> applyHeadersTo: aResponse [

	headers
		keysAndValuesDo:
			[ :header :values | aResponse headers at: header put: ( ( CollectionFormatter separatingWith: ', ' ) format: values ) ]
]

{ #category : #configuring }
CrossOriginResourceSharingHandler >> set: aValue toHeaderNamed: aName [

	headers
		at: aName
		put: ( OrderedCollection with: aValue )
]
