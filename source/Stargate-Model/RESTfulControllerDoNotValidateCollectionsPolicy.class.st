"
I'm the policy indicating a RESTful controller to answer collections without a validator: no ETag, and If-None-Match is ignored.
"
Class {
	#name : 'RESTfulControllerDoNotValidateCollectionsPolicy',
	#superclass : 'RESTfulControllerCollectionValidationPolicy',
	#category : 'Stargate-Model-Controllers',
	#package : 'Stargate-Model',
	#tag : 'Controllers'
}

{ #category : 'instance creation' }
RESTfulControllerDoNotValidateCollectionsPolicy class >> for: aRequestHandler [

  ^ self new
]

{ #category : 'applying' }
RESTfulControllerDoNotValidateCollectionsPolicy >> responseFor: resourceCollection encodedBy: anEncodingBlock basedOn: httpRequest within: requestContext [

  ^ ZnResponse ok: anEncodingBlock value
]
