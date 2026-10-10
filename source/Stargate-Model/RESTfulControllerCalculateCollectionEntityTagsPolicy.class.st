"
I'm the policy indicating a RESTful controller to answer collections with an ETag calculated by a block, from the collection, the media type, the request context and the request handler. The block answers an EntityTag, keeping its strength, or a string, used as the opaque value of a strong one.
The ETag is calculated before encoding, so answering a 304 Not Modified never encodes the collection.
"
Class {
	#name : 'RESTfulControllerCalculateCollectionEntityTagsPolicy',
	#superclass : 'RESTfulControllerCollectionValidationPolicy',
	#instVars : [
		'requestHandler',
		'entityTagCalculator'
	],
	#category : 'Stargate-Model-Controllers',
	#package : 'Stargate-Model',
	#tag : 'Controllers'
}

{ #category : 'instance creation' }
RESTfulControllerCalculateCollectionEntityTagsPolicy class >> for: aRequestHandler calculatingWith: anEntityTagCalculator [

  ^ self new initializeFor: aRequestHandler calculatingWith: anEntityTagCalculator
]

{ #category : 'private' }
RESTfulControllerCalculateCollectionEntityTagsPolicy >> entityTagOf: resourceCollection within: requestContext [

  ^ ( entityTagCalculator
        value: resourceCollection
        value: requestContext targetMediaType
        value: requestContext
        value: requestHandler ) asOpaqueEntityTag
]

{ #category : 'initialization' }
RESTfulControllerCalculateCollectionEntityTagsPolicy >> initializeFor: aRequestHandler calculatingWith: anEntityTagCalculator [

  requestHandler := aRequestHandler.
  entityTagCalculator := anEntityTagCalculator
]

{ #category : 'applying' }
RESTfulControllerCalculateCollectionEntityTagsPolicy >> responseFor: resourceCollection encodedBy: anEncodingBlock basedOn: httpRequest within: requestContext [

  | entityTag response |
  entityTag := self entityTagOf: resourceCollection within: requestContext.
  response := ( requestHandler ifNoneMatchIn: httpRequest matchesWeakly: entityTag )
                ifTrue: [ ZnResponse notModified ]
                ifFalse: [ ZnResponse ok: anEncodingBlock value ].
  response setEntityTag: entityTag.
  ^ response
]
