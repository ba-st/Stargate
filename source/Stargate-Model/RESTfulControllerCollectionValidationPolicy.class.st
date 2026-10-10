"
I'm the policy deciding whether a RESTful controller answers collections with a validator: an ETag, honouring If-None-Match with a 304 Not Modified.
I'm handed the collection and a block that encodes it. My subclasses evaluate that block at most once, so a response that needs no body need not encode it.
"
Class {
	#name : 'RESTfulControllerCollectionValidationPolicy',
	#superclass : 'Object',
	#category : 'Stargate-Model-Controllers',
	#package : 'Stargate-Model',
	#tag : 'Controllers'
}

{ #category : 'applying' }
RESTfulControllerCollectionValidationPolicy >> responseFor: resourceCollection encodedBy: anEncodingBlock basedOn: httpRequest within: requestContext [

  ^ self subclassResponsibility
]
