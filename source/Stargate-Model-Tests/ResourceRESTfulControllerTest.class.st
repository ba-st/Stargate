"
I'm an abstract Test Case providing facililties to test RESTfulWebServices
"
Class {
	#name : #ResourceRESTfulControllerTest,
	#superclass : #TestCase,
	#instVars : [
		'resourceController'
	],
	#category : #'Stargate-Model-Tests-Services'
}

{ #category : #testing }
ResourceRESTfulControllerTest class >> isAbstract [

	^ self name = #ResourceRESTfulControllerTest
]

{ #category : #'private - asserting' }
ResourceRESTfulControllerTest >> assertUrl: aStringOrUrl equals: anotherStringOrUrl [

	self assert: aStringOrUrl asZnUrl equals: anotherStringOrUrl asZnUrl
]

{ #category : #'private - support' }
ResourceRESTfulControllerTest >> baseUrl [

	^ self subclassResponsibility
]

{ #category : #'private - support' }
ResourceRESTfulControllerTest >> newHttpRequestContext [

	^ HttpRequestContext new
]

{ #category : #'private - support' }
ResourceRESTfulControllerTest >> requestToGetResourceIdentifiedBy: anIdentifier accepting: anAcceptHeader [

	^ TeaRequest
		fromZnRequest:
			((ZnRequest get: (self urlForResourceIdentifiedBy: anIdentifier))
				setAccept: anAcceptHeader;
				yourself)
		pathParams: {(#identifier -> anIdentifier)} asDictionary
]

{ #category : #'private - support' }
ResourceRESTfulControllerTest >> requestToGetResourceIdentifiedBy: anIdentifier accepting: anAcceptHeader conditionalTo: anETag [

	^ TeaRequest
		fromZnRequest:
			((ZnRequest get: (self urlForResourceIdentifiedBy: anIdentifier))
				setAccept: anAcceptHeader;
				setIfNoneMatchTo: anETag;
				yourself)
		pathParams: {(#identifier -> anIdentifier)} asDictionary
]

{ #category : #'private - support' }
ResourceRESTfulControllerTest >> requestToPOST: content as: aMediaType [

	^ TeaRequest
		fromZnRequest:
			((ZnRequest post: self resourceUrl)
				entity: (ZnEntity with: content type: aMediaType);
				yourself)
]

{ #category : #'private - support' }
ResourceRESTfulControllerTest >> resourceUrl [

	^ self baseUrl / resourceController specification endpoint
]

{ #category : #running }
ResourceRESTfulControllerTest >> setUp [

	super setUp.
	self setUpResourceController.
	resourceController serverUrl: self baseUrl asZnUrl
]

{ #category : #running }
ResourceRESTfulControllerTest >> setUpResourceController [

	self subclassResponsibility
]

{ #category : #'private - support' }
ResourceRESTfulControllerTest >> urlForResourceIdentifiedBy: anIdentifier [

	^ self resourceUrl / anIdentifier printString asZnUrl
]

{ #category : #'private - support' }
ResourceRESTfulControllerTest >> withJsonFromContentsIn: httpResponse do: aBlock [

	aBlock value: (NeoJSONObject fromString: httpResponse contents)
]
