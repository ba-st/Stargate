"
I'm a Test Case for AcceptNegotiator
"
Class {
	#name : #RESTfulWebServiceAcceptNegotiatorTest,
	#superclass : #TestCase,
	#instVars : [
		'apiMediaTypes'
	],
	#category : #'Stargate-REST-API-Tests-Model'
}

{ #category : #'private - asserting' }
RESTfulWebServiceAcceptNegotiatorTest >> assertPreferredMediaTypeFor: anAcceptHeaderContent given: theAvailableMediaTypes isEqualTo: aMediaType [

	self assert: (self preferredMediaTypeFor: anAcceptHeaderContent given: theAvailableMediaTypes) equals: aMediaType
]

{ #category : #'private - accessing' }
RESTfulWebServiceAcceptNegotiatorTest >> pearAcceptHeader [

	^ 'text/html,application/xhtml+xml,application/xml;q=0.9,text/*;q=0.7,*/*,image/gif; q=0.8, image/jpeg; q=0.6, image/*'
]

{ #category : #'private - accessing' }
RESTfulWebServiceAcceptNegotiatorTest >> preferredMediaTypeFor: anAcceptHeaderContent given: theAvailableMediaTypes [

	^ (RESTfulWebServiceAcceptNegotiator basedOn: theAvailableMediaTypes)
		preferredMediaTypeFor:
			((ZnRequest get: '/example' asZnUrl)
				setAccept: anAcceptHeaderContent;
				yourself)
]

{ #category : #'private - accessing' }
RESTfulWebServiceAcceptNegotiatorTest >> rfcHeader [

	^ 'text/*;q=0.3, text/html;q=0.7, text/html;level=1, text/html;level=2;q=0.4, */*;q=0.5'
]

{ #category : #tests }
RESTfulWebServiceAcceptNegotiatorTest >> setUp [

	super setUp.
	apiMediaTypes := Array
		with: 'application/vnd.stargate.pet+json;version=1.0.0' asMediaType
		with: 'application/vnd.stargate.pet+json;version=1.1.0' asMediaType
		with: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType
		with: 'application/vnd.stargate.pet.summary+json;version=1.0.0' asMediaType
]

{ #category : #tests }
RESTfulWebServiceAcceptNegotiatorTest >> testAPIExactMatch [

	self
		assertPreferredMediaTypeFor: 'application/vnd.stargate.pet+json;version=1.0.0' given: apiMediaTypes isEqualTo: 'application/vnd.stargate.pet+json;version=1.0.0' asMediaType;
		assertPreferredMediaTypeFor: 'application/vnd.stargate.pet.summary+json;version=1.0.0' given: apiMediaTypes isEqualTo: 'application/vnd.stargate.pet.summary+json;version=1.0.0' asMediaType
]

{ #category : #tests }
RESTfulWebServiceAcceptNegotiatorTest >> testMissingVersionSelectsTheNewOne [

	self
		assertPreferredMediaTypeFor: 'application/vnd.stargate.pet+json' given: apiMediaTypes isEqualTo: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType;
		assertPreferredMediaTypeFor: 'application/vnd.stargate.pet.summary+json' given: apiMediaTypes isEqualTo: 'application/vnd.stargate.pet.summary+json;version=1.0.0' asMediaType
]

{ #category : #tests }
RESTfulWebServiceAcceptNegotiatorTest >> testRFC2616Sec14 [

	self
		assertPreferredMediaTypeFor: self rfcHeader given: {'text/html;level=1' asMediaType} isEqualTo: 'text/html;level=1' asMediaType;
		assertPreferredMediaTypeFor: self pearAcceptHeader
			given:
			{'application/xml' asMediaType.
			'text/plain' asMediaType}
			isEqualTo: 'application/xml' asMediaType
]

{ #category : #tests }
RESTfulWebServiceAcceptNegotiatorTest >> testSemanticVersioning [

	self
		assertPreferredMediaTypeFor: 'application/vnd.stargate.pet+json;version=2' given: apiMediaTypes isEqualTo: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType;
		assertPreferredMediaTypeFor: 'application/vnd.stargate.pet+json;version=1' given: apiMediaTypes isEqualTo: 'application/vnd.stargate.pet+json;version=1.1.0' asMediaType;
		assertPreferredMediaTypeFor: 'application/vnd.stargate.pet+json;version=1.1' given: apiMediaTypes isEqualTo: 'application/vnd.stargate.pet+json;version=1.1.0' asMediaType;
		assertPreferredMediaTypeFor: 'application/vnd.stargate.pet+json;version=1.0' given: apiMediaTypes isEqualTo: 'application/vnd.stargate.pet+json;version=1.0.0' asMediaType;
		assertPreferredMediaTypeFor: 'application/vnd.stargate.pet.summary+json;version=1' given: apiMediaTypes isEqualTo: 'application/vnd.stargate.pet.summary+json;version=1.0.0' asMediaType;
		assertPreferredMediaTypeFor: 'application/vnd.stargate.pet+json;version=2,application/vnd.stargate.pet+json;version=1.1'
			given: apiMediaTypes
			isEqualTo: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType;
		assertPreferredMediaTypeFor: 'application/vnd.stargate.pet+json;version=1.0,application/vnd.stargate.pet+json;version=1.1'
			given: apiMediaTypes
			isEqualTo: 'application/vnd.stargate.pet+json;version=1.1.0' asMediaType.

	self
		assertPreferredMediaTypeFor: 'application/json;version=2' given: apiMediaTypes isEqualTo: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType;
		assertPreferredMediaTypeFor: 'application/json' given: apiMediaTypes isEqualTo: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType.

	self
		assertPreferredMediaTypeFor: 'application/vnd.stargate.pet+json;version=1.0.0;q=0.9,application/vnd.stargate.pet.summary+json;version=1.0.0'
		given: apiMediaTypes
		isEqualTo: 'application/vnd.stargate.pet.summary+json;version=1.0.0' asMediaType.

	self
		should: [ self preferredMediaTypeFor: 'application/vnd.stargate.pet+json;version=3' given: apiMediaTypes ] raise: HTTPClientError;
		should: [ self preferredMediaTypeFor: 'application/vnd.stargate.pet+json;version=2.3.0' given: apiMediaTypes ] raise: HTTPClientError;
		should: [ self preferredMediaTypeFor: 'application/vnd.stargate.pet+xml' given: apiMediaTypes ] raise: HTTPClientError
]
