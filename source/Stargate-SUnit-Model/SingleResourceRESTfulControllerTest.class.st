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

{ #category : #'private - support' }
SingleResourceRESTfulControllerTest >> requestToDELETEResourceIdentifiedBy: anIdentifier [

	^ TeaRequest
		fromZnRequest: ( ZnRequest delete: ( self urlForResourceIdentifiedBy: anIdentifier ) )
		pathParams: ( self parametersWith: anIdentifier )
]

{ #category : #'private - support' }
SingleResourceRESTfulControllerTest >> requestToGet: aUrl accepting: anAcceptHeader [

	^ TeaRequest
		fromZnRequest:
			((ZnRequest get: aUrl)
				setAccept: anAcceptHeader;
				yourself)
]

{ #category : #'private - support' }
SingleResourceRESTfulControllerTest >> requestToGetResourceIdentifiedBy: anIdentifier accepting: anAcceptHeader [

	^ TeaRequest
		fromZnRequest:
			( ( ZnRequest get: ( self urlForResourceIdentifiedBy: anIdentifier ) )
				setAccept: anAcceptHeader;
				yourself )
		pathParams: ( self parametersWith: anIdentifier )
]

{ #category : #'private - support' }
SingleResourceRESTfulControllerTest >> requestToGetResourceIdentifiedBy: anIdentifier accepting: anAcceptHeader conditionalTo: anETag [

	^ TeaRequest
		fromZnRequest:
			( ( ZnRequest get: ( self urlForResourceIdentifiedBy: anIdentifier ) )
				setAccept: anAcceptHeader;
				setIfNoneMatchTo: anETag;
				yourself )
		pathParams: ( self parametersWith: anIdentifier )
]

{ #category : #'private - support' }
SingleResourceRESTfulControllerTest >> requestToGetSubresource: aSubResourceUrl identifiedBy: anIdentifier accepting: anAcceptHeader [

	^ TeaRequest
		fromZnRequest:
			( ( ZnRequest get: aSubResourceUrl )
				setAccept: anAcceptHeader;
				yourself )
		pathParams: ( self parametersWith: anIdentifier )
]

{ #category : #'private - support' }
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

{ #category : #'private - support' }
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

	^ self resourceUrl / anIdentifier asString asZnUrl
]
