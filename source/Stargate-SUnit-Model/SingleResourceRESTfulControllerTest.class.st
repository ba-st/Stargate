"
I'm an abstract Test Case providing facililties to test RESTfulControllers for single resources
"
Class {
	#name : #SingleResourceRESTfulControllerTest,
	#superclass : #ResourceRESTfulControllerTest,
	#category : #'Stargate-SUnit-Model'
}

{ #category : #testing }
SingleResourceRESTfulControllerTest class >> isAbstract [

	^ self name = #SingleResourceRESTfulControllerTest
]

{ #category : #'private - support' }
SingleResourceRESTfulControllerTest >> endpoint [

	^ resourceController endpoint
]

{ #category : #'private - support' }
SingleResourceRESTfulControllerTest >> parametersWith: anIdentifier [

	^ SmallDictionary new
		at: resourceController identifierKey put: anIdentifier;
		yourself
]

{ #category : #'private - HTTP requests' }
SingleResourceRESTfulControllerTest >> requestToDELETEResourceIdentifiedBy: anIdentifier [

	^ TeaRequest
		fromZnRequest: ( ZnRequest delete: ( self urlForResourceIdentifiedBy: anIdentifier ) )
		pathParams: ( self parametersWith: anIdentifier )
]

{ #category : #'private - HTTP requests' }
SingleResourceRESTfulControllerTest >> requestToGET: aUrl accepting: anAcceptHeader [

	^ TeaRequest
		fromZnRequest:
			((ZnRequest get: aUrl)
				setAccept: anAcceptHeader;
				yourself)
]

{ #category : #'private - HTTP requests' }
SingleResourceRESTfulControllerTest >> requestToGETResourceIdentifiedBy: anIdentifier accepting: anAcceptHeader [

	^ TeaRequest
		fromZnRequest:
			( ( ZnRequest get: ( self urlForResourceIdentifiedBy: anIdentifier ) )
				setAccept: anAcceptHeader;
				yourself )
		pathParams: ( self parametersWith: anIdentifier )
]

{ #category : #'private - HTTP requests' }
SingleResourceRESTfulControllerTest >> requestToGETResourceIdentifiedBy: anIdentifier accepting: anAcceptHeader conditionalTo: anETag [

	^ TeaRequest
		fromZnRequest:
			( ( ZnRequest get: ( self urlForResourceIdentifiedBy: anIdentifier ) )
				setAccept: anAcceptHeader;
				setIfNoneMatchTo: anETag;
				yourself )
		pathParams: ( self parametersWith: anIdentifier )
]

{ #category : #'private - HTTP requests' }
SingleResourceRESTfulControllerTest >> requestToGETSubresource: aSubresourceUrl identifiedBy: anIdentifier accepting: anAcceptHeader [

	^ TeaRequest
		fromZnRequest:
			( ( ZnRequest get: aSubresourceUrl )
				setAccept: anAcceptHeader;
				yourself )
		pathParams: ( self parametersWith: anIdentifier )
]

{ #category : #'private - HTTP requests' }
SingleResourceRESTfulControllerTest >> requestToPATCHResourceIdentifiedBy: anIdentifier with: aRequestBody accepting: anAcceptHeader conditionalTo: anETag [

	^ TeaRequest
		fromZnRequest:
			( ( ZnRequest patch: ( self urlForResourceIdentifiedBy: anIdentifier ) )
				setAccept: anAcceptHeader;
				setIfMatchTo: anETag;
				entity: ( ZnEntity with: aRequestBody type: anAcceptHeader );
				yourself )
		pathParams: ( self parametersWith: anIdentifier )
]

{ #category : #'private - HTTP requests' }
SingleResourceRESTfulControllerTest >> requestToPOST: content as: aMediaType [

	^ TeaRequest
		fromZnRequest:
			((ZnRequest post: self resourceUrl)
				entity: (ZnEntity with: content type: aMediaType);
				yourself)
]

{ #category : #'private - support' }
SingleResourceRESTfulControllerTest >> resourceUrl [

	^ self baseUrl / self endpoint
]

{ #category : #'private - support' }
SingleResourceRESTfulControllerTest >> urlForResourceIdentifiedBy: anIdentifier [

	^ self resourceUrl / anIdentifier asString asUrl
]
