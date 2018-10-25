"
I'm an abstract Test Case providing facililties to test RESTfulWebServices
"
Class {
	#name : #RESTfulWebServiceTest,
	#superclass : #TestCase,
	#instVars : [
		'webService'
	],
	#category : #'Stargate-REST-API-Tests-Services'
}

{ #category : #testing }
RESTfulWebServiceTest class >> isAbstract [

	^ self name = #RESTfulWebServiceTest
]

{ #category : #'private - asserting' }
RESTfulWebServiceTest >> assertUrl: aStringOrUrl equals: anotherStringOrUrl [

	self assert: aStringOrUrl asZnUrl equals: anotherStringOrUrl asZnUrl
]

{ #category : #'private - support' }
RESTfulWebServiceTest >> baseUrl [

	^ self subclassResponsibility
]

{ #category : #'private - support' }
RESTfulWebServiceTest >> newHttpRequestContext [

	^ HttpRequestContext new
]

{ #category : #'private - support' }
RESTfulWebServiceTest >> requestToGetResourceIdentifiedBy: anIdentifier accepting: anAcceptHeader [

	^ TeaRequest
		fromZnRequest:
			((ZnRequest get: (self urlForResourceIdentifiedBy: anIdentifier))
				setAccept: anAcceptHeader;
				yourself)
		pathParams: {(#identifier -> anIdentifier)} asDictionary
]

{ #category : #'private - support' }
RESTfulWebServiceTest >> requestToPOST: content type: aMediaType [

	^ TeaRequest
		fromZnRequest:
			((ZnRequest post: self resourceUrl)
				entity: (ZnEntity with: content type: aMediaType);
				yourself)
]

{ #category : #'private - support' }
RESTfulWebServiceTest >> resourceUrl [

	^ self baseUrl / webService specification endpoint
]

{ #category : #running }
RESTfulWebServiceTest >> setUp [

	super setUp.
	self setUpWebService.
	webService serverUrl: self baseUrl asZnUrl
]

{ #category : #running }
RESTfulWebServiceTest >> setUpWebService [

	self subclassResponsibility
]

{ #category : #'private - support' }
RESTfulWebServiceTest >> urlForResourceIdentifiedBy: anIdentifier [

	^ self resourceUrl / anIdentifier printString asZnUrl
]

{ #category : #'private - support' }
RESTfulWebServiceTest >> withJsonFromContentsIn: httpResponse do: aBlock [

	aBlock value: (NeoJSONObject fromString: httpResponse contents)
]
