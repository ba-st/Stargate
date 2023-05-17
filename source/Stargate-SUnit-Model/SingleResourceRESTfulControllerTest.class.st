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

	^ self
		  requestToGET: aUrl
		  applying: [ :request | request setAccept: anAcceptHeader ]
]

{ #category : #'private - HTTP requests' }
SingleResourceRESTfulControllerTest >> requestToGET: aUrl applying: aConfiguration [

	^ self
		  requestToGET: aUrl
		  withPathParams: Dictionary new
		  applying: aConfiguration
]

{ #category : #'private - HTTP requests' }
SingleResourceRESTfulControllerTest >> requestToGET: aUrl withPathParams: aDictionary applying: aConfiguration [
	
	| request | 
	
	request := ZnRequest get: aUrl.
	
	aConfiguration value: request.
	
	^ TeaRequest
		fromZnRequest: request
		pathParams: aDictionary.
]

{ #category : #'private - HTTP requests' }
SingleResourceRESTfulControllerTest >> requestToGETResourceFrom: aLocation identifiedBy: anIdentifier applying: aConfiguration [

	^ self
		  requestToGET: aLocation
		  withPathParams: (self parametersWith: anIdentifier)
		  applying: aConfiguration
]

{ #category : #'private - HTTP requests' }
SingleResourceRESTfulControllerTest >> requestToGETResourceIdentifiedBy: anIdentifier accepting: anAcceptHeader [

	^ self
		  requestToGETResourceIdentifiedBy: anIdentifier
		  applying: [ :request | request setAccept: anAcceptHeader ]
]

{ #category : #'private - HTTP requests' }
SingleResourceRESTfulControllerTest >> requestToGETResourceIdentifiedBy: anIdentifier accepting: anAcceptHeader conditionalTo: anETag [

	^ self
		  requestToGETResourceIdentifiedBy: anIdentifier
		  applying: [ :request | 
			  request
				  setAccept: anAcceptHeader;
				  setIfNoneMatchTo: anETag ]
]

{ #category : #'private - HTTP requests' }
SingleResourceRESTfulControllerTest >> requestToGETResourceIdentifiedBy: anIdentifier applying: aConfiguration [

	^ self
		  requestToGETResourceFrom:
		  (self urlForResourceIdentifiedBy: anIdentifier)
		  identifiedBy: anIdentifier
		  applying: aConfiguration
]

{ #category : #'private - HTTP requests' }
SingleResourceRESTfulControllerTest >> requestToGETResourceIdentifiedBy: anIdentifier representedAs: aMediaType in: aLanguageTag [

	^ self
		  requestToGETResourceIdentifiedBy: anIdentifier
		  applying: [ :request | 
			  request
				  setAccept: aMediaType;
				  setAcceptLanguage: aLanguageTag ]
]

{ #category : #'private - HTTP requests' }
SingleResourceRESTfulControllerTest >> requestToGETSubresource: aSubresourceUrl identifiedBy: anIdentifier accepting: anAcceptHeader [

	^ self
		  requestToGET: aSubresourceUrl
		  withPathParams: (self parametersWith: anIdentifier)
		  applying: [ :request | request setAccept: anAcceptHeader ]
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
