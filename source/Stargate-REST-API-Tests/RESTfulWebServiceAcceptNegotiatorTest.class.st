"
I'm a Test Case for AcceptNegotiator
"
Class {
	#name : #RESTfulWebServiceAcceptNegotiatorTest,
	#superclass : #TestCase,
	#category : #'Stargate-REST-API-Tests'
}

{ #category : #'private - asserting' }
RESTfulWebServiceAcceptNegotiatorTest >> assertPreferredMediaTypeFor: anAcceptHeaderContent given: theAvailableMediaTypes isEqualTo: aMediaType [

	self
		assert:
			((RESTfulWebServiceAcceptNegotiator basedOn: theAvailableMediaTypes)
				preferredMediaTypeFor:
					((ZnRequest get: '/example' asZnUrl)
						setAccept: anAcceptHeaderContent;
						yourself))
		equals: aMediaType
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
RESTfulWebServiceAcceptNegotiatorTest >> testRFC2616Sec14 [

	self
		assertPreferredMediaTypeFor: self rfcHeader given: {'text/html;level=1' asMediaType} isEqualTo: 'text/html;level=1' asMediaType;
		assertPreferredMediaTypeFor: self pearAcceptHeader
			given:
			{'application/xml' asMediaType.
			'text/plain' asMediaType}
			isEqualTo: 'application/xml' asMediaType
]
