"
I'm the policy indicating a RESTful controller to answer collections with an ETag hashing the encoded collection, so it covers whatever the representation depends on: the media type, the language, the query, the page and, in a hypermedia-driven controller, the controls.
Answering a 304 Not Modified still encodes the collection, to hash it.
"
Class {
	#name : 'RESTfulControllerHashEncodedCollectionsPolicy',
	#superclass : 'RESTfulControllerCollectionValidationPolicy',
	#instVars : [
		'requestHandler'
	],
	#category : 'Stargate-Model-Controllers',
	#package : 'Stargate-Model',
	#tag : 'Controllers'
}

{ #category : 'instance creation' }
RESTfulControllerHashEncodedCollectionsPolicy class >> for: aRequestHandler [

  ^ self new initializeFor: aRequestHandler
]

{ #category : 'private' }
RESTfulControllerHashEncodedCollectionsPolicy >> entityTagOf: encodedCollection [
  "The content type is printed, and the contents hashed explicitly, since asString of an entity
  does not answer its contents in every dialect"

  ^ EntityTag with: ( EntityTagHasher new
          include: encodedCollection contentType printString;
          include: encodedCollection contents;
          calculateHash )
]

{ #category : 'initialization' }
RESTfulControllerHashEncodedCollectionsPolicy >> initializeFor: aRequestHandler [

  requestHandler := aRequestHandler
]

{ #category : 'applying' }
RESTfulControllerHashEncodedCollectionsPolicy >> responseFor: resourceCollection encodedBy: anEncodingBlock basedOn: httpRequest within: requestContext [

  | encodedCollection entityTag response |
  encodedCollection := anEncodingBlock value.
  entityTag := self entityTagOf: encodedCollection.
  response := ( requestHandler ifNoneMatchIn: httpRequest matchesWeakly: entityTag )
                ifTrue: [ ZnResponse notModified ]
                ifFalse: [ ZnResponse ok: encodedCollection ].
  response setEntityTag: entityTag.
  ^ response
]
