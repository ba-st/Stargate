"
I represent a RESTful handler, and provide the base support to easily create specific controllers.
I provide the standard machinery to handle REST requests, and I'm supposed to be used from a controller.
"
Class {
	#name : 'RESTfulRequestHandlerBehavior',
	#superclass : 'Object',
	#instVars : [
		'paginationPolicy',
		'decodingRules',
		'encodingRules',
		'entityTagCalculator',
		'resourceLocator',
		'acceptNegotiator',
		'cachingDirectives'
	],
	#category : 'Stargate-Model-Controllers',
	#package : 'Stargate-Model',
	#tag : 'Controllers'
}

{ #category : 'encoding' }
RESTfulRequestHandlerBehavior class >> encode: resource toJsonUsing: writer as: schema within: requestContext [

  self subclassResponsibility
]

{ #category : 'encoding' }
RESTfulRequestHandlerBehavior class >> encode: resource toJsonUsing: writer within: requestContext [

  self subclassResponsibility
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> applyCachingDirectivesFor: aResource to: response within: requestContext [

	cachingDirectives
		do: [ :directive | directive cull: response cull: requestContext cull: aResource ]
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> assert: etag matchesEntityTagOf: entity encodedAs: httpRequest within: requestContext [

  | calculatedEtag entityTagCalculation |
  entityTagCalculation := [
                            self
                              entityTagOf: entity
                              encodedAs: httpRequest contentType
                              within: requestContext ].

  "The request content can be in another language that the one requested
	in the Accept header, so in that case we need to calculated the etag
	of the entity with this language as the current one"
  calculatedEtag := httpRequest contentLanguageTags
                      ifEmpty: entityTagCalculation
                      ifNotEmpty: [ :languages |
                        CurrentLocale use: languages first during: entityTagCalculation ].

  etag = calculatedEtag ifFalse: [ HTTPClientError preconditionFailed signal ]
]

{ #category : 'decoding/encoding' }
RESTfulRequestHandlerBehavior >> decode: httpRequest within: requestContext [

	| decodingRule |

	decodingRule := decodingRules
		at: httpRequest contentType
		ifAbsent: [ HTTPClientError unsupportedMediaType signal: 'Decoder not found for given media type' ].

	^ self exceptionHandler
		handleDecodingFailedDuring: [ decodingRule cull: httpRequest contents cull: requestContext ]
]

{ #category : 'decoding/encoding' }
RESTfulRequestHandlerBehavior >> encode: resource as: targetMediaType within: requestContext [

	| encodingRule |
	encodingRule := encodingRules at: targetMediaType ifAbsent: [ 
		                HTTPClientError unsupportedMediaType signal:
			                'Encoder not found for given media type' ].

	^ encodingRule encode: resource within: requestContext
]

{ #category : 'decoding/encoding' }
RESTfulRequestHandlerBehavior >> encode: resource within: requestContext [

	^ self
		  encode: resource
		  as: requestContext targetMediaType
		  within: requestContext
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> encodeResource: resource as: mediaType within: requestContext [

	^ self encode: resource as: mediaType within: requestContext
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> encodeResource: resource within: requestContext [

	^ self
		  encodeResource: resource
		  as: requestContext targetMediaType
		  within: requestContext
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> encodeResourceCollection: resourceCollection basedOn: httpRequest within: requestContext [

	^ self encode: resourceCollection within: requestContext
]

{ #category : 'accessing' }
RESTfulRequestHandlerBehavior >> endpoint [

	^ resourceLocator endpoint
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> entityTagOf: resource encodedAs: mediaType within: requestContext [

	^ EntityTag with: (entityTagCalculator
			   value: resource
			   value: mediaType
			   value: requestContext
			   value: self)
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> entityTagToMatchBasedOn: httpRequest [

  ^ self parseEntityTag: ( httpRequest headers
          at: 'If-Match'
          ifAbsent: [ HTTPClientError preconditionRequired signal: 'Missing If-Match header.' ] )
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> evaluateCollectionQuery: aQueryEvaluationBlock basedOn: httpRequest within: requestContext [

	^ self exceptionHandler handleMissingQueryParametersDuring: aQueryEvaluationBlock
]

{ #category : 'accessing' }
RESTfulRequestHandlerBehavior >> exceptionHandler [

	^ resourceLocator exceptionHandler
]

{ #category : 'API' }
RESTfulRequestHandlerBehavior >> from: httpRequest within: requestContext get: aQueryEvaluationBlock [

  self holdTargetMediaTypeAndLanguageFrom: httpRequest within: requestContext.
  ^ self useTargetLanguageTagIn: requestContext asCurrentLocaleDuring: [
        | resource response |
        resource := resourceLocator
                      lookupResourceIdentifiedBy: httpRequest
                      evaluating: aQueryEvaluationBlock.
        self ifNoneMatchHeaderPresentIn: httpRequest do: [ :etag |
            | calculatedEtag |
            calculatedEtag := self
                                entityTagOf: resource
                                encodedAs: requestContext targetMediaType
                                within: requestContext.
            etag = calculatedEtag ifTrue: [
                response := ZnResponse notModified.
                response
                  setEntityTag: etag;
                  addToVary: 'Accept'.
                self
                  applyCachingDirectivesFor: resource to: response within: requestContext;
                  putLanguageContentTagIn: response within: requestContext.
                ^ response
              ]
          ].
        response := ZnResponse ok: ( self encodeResource: resource within: requestContext ).
        self putEntityTagOf: resource in: response within: requestContext.
        self
          applyCachingDirectivesFor: resource to: response within: requestContext;
          putLanguageContentTagIn: response within: requestContext.
        response
      ]
]

{ #category : 'API' }
RESTfulRequestHandlerBehavior >> from: httpRequest within: requestContext get: aQueryEvaluationBlock thenDo: actionBlock [

  self holdTargetLanguageFrom: httpRequest within: requestContext.

  ^ self useTargetLanguageTagIn: requestContext asCurrentLocaleDuring: [
        | resource |
        resource := resourceLocator
                      lookupResourceIdentifiedBy: httpRequest
                      evaluating: aQueryEvaluationBlock.
        self exceptionHandler handleConflictsDuring: [ actionBlock value: resource ].
        ZnResponse noContent
      ]
]

{ #category : 'API' }
RESTfulRequestHandlerBehavior >> from: httpRequest within: requestContext get: findBlock thenUpdateWith: updateBlock [

  | etag |

  etag := self entityTagToMatchBasedOn: httpRequest.

  ^ self from: httpRequest within: requestContext get: [ :id |
        | resourceToUpdate updatedResource |

        resourceToUpdate := findBlock cull: id.
        self
          assert: etag
          matchesEntityTagOf: resourceToUpdate
          encodedAs: httpRequest
          within: requestContext.

        updatedResource := self decode: httpRequest within: requestContext.
        self exceptionHandler handleConflictsDuring: [
            self exceptionHandler handleDecodingFailedDuring: [
                updateBlock value: resourceToUpdate value: updatedResource ]
          ]
      ]
]

{ #category : 'API' }
RESTfulRequestHandlerBehavior >> from: httpRequest within: requestContext getCollection: aQueryEvaluationBlock [

  self holdTargetMediaTypeAndLanguageFrom: httpRequest within: requestContext.
  ^ self useTargetLanguageTagIn: requestContext asCurrentLocaleDuring: [
        | resourceCollection encodedResourceCollection response |
        resourceCollection := paginationPolicy
                                evaluateQuery: aQueryEvaluationBlock
                                basedOn: httpRequest
                                within: requestContext.
        encodedResourceCollection := self
                                       encodeResourceCollection: resourceCollection
                                       basedOn: httpRequest
                                       within: requestContext.
        response := ZnResponse ok: encodedResourceCollection.
        response addToVary: 'Accept'.
        self paginationPolicy affect: response within: requestContext.
        self
          applyCachingDirectivesFor: resourceCollection to: response within: requestContext;
          putLanguageContentTagIn: response within: requestContext.
        response
      ]
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> holdTargetLanguageFrom: httpRequest within: requestContext [

  httpRequest hasLanguageProrityList then: [
      requestContext targetLanguageTag: ( acceptNegotiator bestLanguageFor: httpRequest ) ]
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> holdTargetMediaTypeAndLanguageFrom: httpRequest within: requestContext [

  self holdTargetLanguageFrom: httpRequest within: requestContext.

  ^ requestContext targetMediaType: ( acceptNegotiator bestRepresentationFor: httpRequest )
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> ifNoneMatchHeaderPresentIn: httpRequest do: aMonadycBlock [

  httpRequest headers
    at: 'If-None-Match'
    ifPresent: [ :ifNoneMatchHeader |
      aMonadycBlock value: ( self parseEntityTag: ifNoneMatchHeader ) ]
]

{ #category : 'initialization' }
RESTfulRequestHandlerBehavior >> initializeResourceLocator: aResouceLocator
	paginationPolicy: aPaginationPolicy
	decodingRules: theDecodingRules
	encodingRules: theEncodingRules
	calculateEntityTagsWith: anEntityTagCalculator
	cachingDirectives: theCachingDirectives
	allowedLanguageTags: allowedLanguageTags
	handleErrorsWith: anExceptionHandler [

	resourceLocator := aResouceLocator.
	resourceLocator handleExceptionsWith: anExceptionHandler.
	paginationPolicy := aPaginationPolicy cull: self.
	decodingRules := theDecodingRules.
	encodingRules := theEncodingRules.
	acceptNegotiator := RESTfulControllerAcceptNegotiator accepting: encodingRules keys inAnyOf: allowedLanguageTags.
	entityTagCalculator := anEntityTagCalculator.
	cachingDirectives := theCachingDirectives
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> locationOf: resource within: requestContext [

	^ resourceLocator locationOf: resource within: requestContext
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> paginationPolicy [

	^ paginationPolicy
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> parseEntityTag: string [

  ^ [ string asEntityTag ]
      on: InstanceCreationFailed
      do: [ :error | HTTPClientError badRequest signal: error messageText ]
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> putEntityTagOf: resource in: response within: requestContext [

	response
		setEntityTag: ( self entityTagOf: resource encodedAs: requestContext targetMediaType within: requestContext );
		addToVary: 'Accept'
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> putLanguageContentTagIn: response within: requestContext [

	requestContext
		withTargetLanguageTagDo: [ :languageTag | 
			response
				addContentLanguage: languageTag;
				addToVary: 'Accept-Language'
			]
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> resourceCreationPolicyBasedOn: httpRequest within: requestContext [

	^ httpRequest
		  withAcceptHeaderDo: [ 
			  self holdTargetMediaTypeAndLanguageFrom: httpRequest within: requestContext.
			  RESTfulControllerRespondCreatedEntityPolicy for: self
			  ]
		  ifAbsent: [ RESTfulControllerDoNotRespondCreatedEntityPolicy for: self ]
]

{ #category : 'accessing' }
RESTfulRequestHandlerBehavior >> resourceLocator [

	^ resourceLocator
]

{ #category : 'accessing' }
RESTfulRequestHandlerBehavior >> serverUrl: aServerUrl [

	resourceLocator baseUrl: aServerUrl
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> useTargetLanguageTagIn: httpRequestContext asCurrentLocaleDuring: aBlock [

  ^ httpRequestContext
      withTargetLanguageTagDo: [ :language | CurrentLocale use: language during: aBlock ]
      ifNone: aBlock
]

{ #category : 'API' }
RESTfulRequestHandlerBehavior >> withRepresentationIn: httpRequest within: requestContext createResourceWith: aCreationBlock thenDo: aBlock [

	^ self
		withResourceCreatedFrom: httpRequest
		within: requestContext
		do: [ :representation | 
			aBlock
				value: ( self exceptionHandler handleDecodingFailedDuring: [ aCreationBlock value: representation ] )
			]
]

{ #category : 'API' }
RESTfulRequestHandlerBehavior >> withResourceCreatedFrom: httpRequest within: requestContext do: aBlock [

  | creationPolicy |
  creationPolicy := self resourceCreationPolicyBasedOn: httpRequest within: requestContext.
  ^ self useTargetLanguageTagIn: requestContext asCurrentLocaleDuring: [
        | decodedRepresentation newResource |
        decodedRepresentation := self decode: httpRequest within: requestContext.
        newResource := self exceptionHandler handleConflictsDuring: [
                           aBlock value: decodedRepresentation ].
        creationPolicy responseFor: newResource basedOn: httpRequest within: requestContext
      ]
]
