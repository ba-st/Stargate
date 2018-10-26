"
I'm a Test Case for AcceptNegotiator
"
Class {
	#name : #RESTfulWebServiceAcceptNegotiatorTest,
	#superclass : #TestCase,
	#instVars : [
		'apiMediaTypes'
	],
	#category : #'Stargate-Model-Tests-Services'
}

{ #category : #'private - asserting' }
RESTfulWebServiceAcceptNegotiatorTest >> assertBestRepresentationFor: anAcceptHeaderContent given: theAvailableMediaTypes is: aMediaType [

	self assert: (self bestRepresentationFor: anAcceptHeaderContent given: theAvailableMediaTypes) equals: aMediaType
]

{ #category : #'private - accessing' }
RESTfulWebServiceAcceptNegotiatorTest >> bestRepresentationFor: anAcceptHeaderContent given: theAvailableMediaTypes [

	^ (RESTfulWebServiceAcceptNegotiator basedOn: theAvailableMediaTypes)
		bestRepresentationFor:
			((ZnRequest get: '/example' asZnUrl)
				setAccept: anAcceptHeaderContent;
				yourself)
]

{ #category : #'private - accessing' }
RESTfulWebServiceAcceptNegotiatorTest >> pearAcceptHeader [

	^ 'text/html,application/xhtml+xml,application/xml;q=0.9,text/*;q=0.7,*/*,image/gif; q=0.8, image/jpeg; q=0.6, image/*'
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
		assertBestRepresentationFor: 'application/vnd.stargate.pet+json;version=1.0.0' given: apiMediaTypes is: 'application/vnd.stargate.pet+json;version=1.0.0' asMediaType;
		assertBestRepresentationFor: 'application/vnd.stargate.pet.summary+json;version=1.0.0' given: apiMediaTypes is: 'application/vnd.stargate.pet.summary+json;version=1.0.0' asMediaType
]

{ #category : #tests }
RESTfulWebServiceAcceptNegotiatorTest >> testMissingVersionSelectsTheNewOne [

	self
		assertBestRepresentationFor: 'application/vnd.stargate.pet+json' given: apiMediaTypes is: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType;
		assertBestRepresentationFor: 'application/vnd.stargate.pet.summary+json' given: apiMediaTypes is: 'application/vnd.stargate.pet.summary+json;version=1.0.0' asMediaType
]

{ #category : #tests }
RESTfulWebServiceAcceptNegotiatorTest >> testRFC2616Sec14 [

	self
		assertBestRepresentationFor: self rfcHeader given: {'text/html;level=1' asMediaType} is: 'text/html;level=1' asMediaType;
		assertBestRepresentationFor: self pearAcceptHeader
			given:
			{'application/xml' asMediaType.
			'text/plain' asMediaType}
			is: 'application/xml' asMediaType
]

{ #category : #tests }
RESTfulWebServiceAcceptNegotiatorTest >> testSemanticVersioning [

	self
		assertBestRepresentationFor: 'application/vnd.stargate.pet+json;version=2' given: apiMediaTypes is: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType;
		assertBestRepresentationFor: 'application/vnd.stargate.pet+json;version=1' given: apiMediaTypes is: 'application/vnd.stargate.pet+json;version=1.1.0' asMediaType;
		assertBestRepresentationFor: 'application/vnd.stargate.pet+json;version=1.1' given: apiMediaTypes is: 'application/vnd.stargate.pet+json;version=1.1.0' asMediaType;
		assertBestRepresentationFor: 'application/vnd.stargate.pet+json;version=1.0' given: apiMediaTypes is: 'application/vnd.stargate.pet+json;version=1.0.0' asMediaType;
		assertBestRepresentationFor: 'application/vnd.stargate.pet.summary+json;version=1' given: apiMediaTypes is: 'application/vnd.stargate.pet.summary+json;version=1.0.0' asMediaType;
		assertBestRepresentationFor: 'application/vnd.stargate.pet+json;version=2,application/vnd.stargate.pet+json;version=1.1'
			given: apiMediaTypes
			is: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType;
		assertBestRepresentationFor: 'application/vnd.stargate.pet+json;version=1.0,application/vnd.stargate.pet+json;version=1.1'
			given: apiMediaTypes
			is: 'application/vnd.stargate.pet+json;version=1.1.0' asMediaType.

	self
		assertBestRepresentationFor: 'application/json;version=2' given: apiMediaTypes is: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType;
		assertBestRepresentationFor: 'application/json' given: apiMediaTypes is: 'application/vnd.stargate.pet+json;version=2.0.0' asMediaType.

	self
		assertBestRepresentationFor: 'application/vnd.stargate.pet+json;version=1.0.0;q=0.9,application/vnd.stargate.pet.summary+json;version=1.0.0'
		given: apiMediaTypes
		is: 'application/vnd.stargate.pet.summary+json;version=1.0.0' asMediaType.

	self
		should: [ self bestRepresentationFor: 'application/vnd.stargate.pet+json;version=3' given: apiMediaTypes ] raise: HTTPClientError;
		should: [ self bestRepresentationFor: 'application/vnd.stargate.pet+json;version=2.3.0' given: apiMediaTypes ] raise: HTTPClientError;
		should: [ self bestRepresentationFor: 'application/vnd.stargate.pet+xml' given: apiMediaTypes ] raise: HTTPClientError
]
