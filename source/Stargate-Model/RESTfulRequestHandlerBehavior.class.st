"
I represent a RESTful handler, and provide the base support to easily create specific controllers.
I provide the standard machinery to handle REST requests, and I'm supposed to be used from a controller.
"
Class {
	#name : 'RESTfulRequestHandlerBehavior',
	#superclass : 'Object',
	#instVars : [
		'paginationPolicy',
		'collectionValidationPolicy',
		'decodingRules',
		'resourceEncodingRules',
		'collectionEncodingRules',
		'entityTagCalculator',
		'resourceLocator',
		'resourceAcceptNegotiator',
		'collectionAcceptNegotiator',
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
RESTfulRequestHandlerBehavior >> acceptedMediaTypes [

  ^ decodingRules keys sorted: [ :mediaType :anotherMediaType |
        mediaType printString <= anotherMediaType printString ]
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> applyCachingDirectivesFor: aResource to: response within: requestContext [

  response isNotModified
    ifTrue: [
      self applyCachingDirectivesFor: aResource toNotModified: response within: requestContext ]
    ifFalse: [ self evaluateCachingDirectivesFor: aResource on: response within: requestContext ]
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> applyCachingDirectivesFor: aResource toNotModified: response within: requestContext [
  "RFC 9110 §15.4.5: a 304 carries the Cache-Control and Expires fields its 200 would have.
  The directives are evaluated on a response standing for that 200, since their conditions
  can select on its content type, and only those fields are copied, so the 304 sends no Content-Type"

  | okResponse |
  okResponse := ZnResponse statusLine: ZnStatusLine ok.
  okResponse headers contentType: requestContext targetMediaType.
  self evaluateCachingDirectivesFor: aResource on: okResponse within: requestContext.
  #( 'Cache-Control' 'Expires' ) do: [ :fieldName |
      okResponse headers
        at: fieldName
        ifPresent: [ :fieldValue | response headers at: fieldName put: fieldValue ]
    ]
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> assertPreconditionsOf: httpRequest matching: entityTags holdFor: entity within: requestContext [
  "RFC 9110 §13.2.2: If-Match is evaluated first, then If-None-Match, and either one failing
  answers 412 on a method other than GET or HEAD, before the request is applied.
  Both are evaluated against the selected representation (RFC 9110 §13.1.1): the negotiated
  media type and language, the latter being the current locale while they are evaluated"

  | calculatedEtag |
  calculatedEtag := self
                      entityTagOf: entity
                      encodedAs: requestContext targetMediaType
                      within: requestContext.
  ( entityTags matchesStrongly: calculatedEtag ) ifFalse: [
      HTTPClientError preconditionFailed signal ].
  self ifNoneMatchHeaderPresentIn: httpRequest do: [ :entityTagsNotToMatch |
      ( entityTagsNotToMatch matchesWeakly: calculatedEtag ) ifTrue: [
          HTTPClientError preconditionFailed signal ]
    ]
]

{ #category : 'decoding/encoding' }
RESTfulRequestHandlerBehavior >> decode: httpRequest within: requestContext [

  | decodingRule |
  decodingRule := httpRequest contentType
                    ifNil: [ self signalMissingMediaType ]
                    ifNotNil: [ :mediaType |
                      decodingRules
                        at: mediaType
                        ifAbsent: [ self signalUnsupportedMediaType: mediaType ] ].

  ^ self exceptionHandler handleDecodingFailedDuring: [
        decodingRule cull: httpRequest contents cull: requestContext ]
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> encode: resource as: targetMediaType using: theEncodingRules within: requestContext [

  | encodingRule |
  encodingRule := theEncodingRules
                    at: targetMediaType
                    ifAbsent: [
                      HTTPClientError unsupportedMediaType signal:
                        'Encoder not found for given media type' ].

  ^ encodingRule encode: resource within: requestContext
]

{ #category : 'decoding/encoding' }
RESTfulRequestHandlerBehavior >> encode: resource as: targetMediaType within: requestContext [

  ^ self
      encode: resource
      as: targetMediaType
      using: resourceEncodingRules
      within: requestContext
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

  ^ self
      encode: resourceCollection
      as: requestContext targetMediaType
      using: collectionEncodingRules
      within: requestContext
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
RESTfulRequestHandlerBehavior >> entityTagsToMatchBasedOn: httpRequest [

  ^ self parseEntityTags: ( httpRequest headers
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

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> evaluateCachingDirectivesFor: aResource on: response within: requestContext [

  cachingDirectives do: [ :directive |
      directive cull: response cull: requestContext cull: aResource ]
]

{ #category : 'API' }
RESTfulRequestHandlerBehavior >> from: httpRequest within: requestContext get: aQueryEvaluationBlock [

  self holdTargetMediaTypeAndLanguageFrom: httpRequest within: requestContext.
  ^ self useTargetLanguageTagIn: requestContext asCurrentLocaleDuring: [
        | resource response |
        resource := resourceLocator
                      lookupResourceIdentifiedBy: httpRequest
                      evaluating: aQueryEvaluationBlock.
        self ifNoneMatchHeaderPresentIn: httpRequest do: [ :entityTags |
            | calculatedEtag |
            calculatedEtag := self
                                entityTagOf: resource
                                encodedAs: requestContext targetMediaType
                                within: requestContext.
            ( entityTags matchesWeakly: calculatedEtag ) ifTrue: [
                response := ZnResponse notModified.
                response
                  setEntityTag: calculatedEtag;
                  addToVary: 'Accept'.
                self
                  applyCachingDirectivesFor: resource to: response within: requestContext;
                  putLanguageContentTagIn: response within: requestContext.
                ^ response
              ]
          ].
        self responseRepresenting: resource within: requestContext
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

  | entityTags |
  entityTags := self entityTagsToMatchBasedOn: httpRequest.

  self holdTargetMediaTypeAndLanguageOfUpdate: httpRequest within: requestContext.
  ^ self useTargetLanguageTagIn: requestContext asCurrentLocaleDuring: [
        | resource |
        resource := resourceLocator lookupResourceIdentifiedBy: httpRequest evaluating: [ :id |
                        | resourceToUpdate updatedResource |
                        resourceToUpdate := findBlock cull: id.
                        self
                          assertPreconditionsOf: httpRequest
                          matching: entityTags
                          holdFor: resourceToUpdate
                          within: requestContext.

                        updatedResource := self decode: httpRequest within: requestContext.
                        self exceptionHandler handleConflictsDuring: [
                            self exceptionHandler handleDecodingFailedDuring: [
                                updateBlock value: resourceToUpdate value: updatedResource ]
                          ]
                      ].
        self responseRepresenting: resource within: requestContext
      ]
]

{ #category : 'API' }
RESTfulRequestHandlerBehavior >> from: httpRequest within: requestContext getCollection: aQueryEvaluationBlock [

  self
    holdTargetMediaTypeAndLanguageFrom: httpRequest
    negotiatingWith: collectionAcceptNegotiator
    within: requestContext.
  ^ self useTargetLanguageTagIn: requestContext asCurrentLocaleDuring: [
        | resourceCollection response |
        resourceCollection := paginationPolicy
                                evaluateQuery: aQueryEvaluationBlock
                                basedOn: httpRequest
                                within: requestContext.
        response := collectionValidationPolicy
                      responseFor: resourceCollection
                      encodedBy: [
                        self
                          encodeResourceCollection: resourceCollection
                          basedOn: httpRequest
                          within: requestContext ]
                      basedOn: httpRequest
                      within: requestContext.
        response addToVary: 'Accept'.
        self paginationPolicy affect: response within: requestContext.
        self
          applyCachingDirectivesFor: resourceCollection to: response within: requestContext;
          putLanguageContentTagIn: response within: requestContext.
        response
      ]
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> holdTargetLanguageFrom: httpRequest negotiatingWith: anAcceptNegotiator within: requestContext [

  self
    holdTargetLanguageNegotiatedBy: [ anAcceptNegotiator bestLanguageFor: httpRequest ]
    for: httpRequest
    within: requestContext
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> holdTargetLanguageFrom: httpRequest within: requestContext [

  self
    holdTargetLanguageFrom: httpRequest
    negotiatingWith: resourceAcceptNegotiator
    within: requestContext
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> holdTargetLanguageNegotiatedBy: aNegotiationBlock for: httpRequest within: requestContext [
  "A handler offering languages always negotiates one, taking the first when the request
  has no preference. One offering none still rejects requests asking for a language.
  Resources and collections offer the same languages"

  ( resourceAcceptNegotiator offersLanguages or: [ httpRequest hasLanguageProrityList ] ) then: [
      requestContext targetLanguageTag: aNegotiationBlock value ]
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> holdTargetMediaTypeAndLanguageFrom: httpRequest negotiatingWith: anAcceptNegotiator within: requestContext [

  self
    holdTargetLanguageFrom: httpRequest
    negotiatingWith: anAcceptNegotiator
    within: requestContext.

  ^ requestContext targetMediaType: ( anAcceptNegotiator bestRepresentationFor: httpRequest )
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> holdTargetMediaTypeAndLanguageFrom: httpRequest within: requestContext [

  ^ self
      holdTargetMediaTypeAndLanguageFrom: httpRequest
      negotiatingWith: resourceAcceptNegotiator
      within: requestContext
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> holdTargetMediaTypeAndLanguageOfUpdate: httpRequest within: requestContext [
  "When the request leaves the choice to the server (RFC 9110 §12.5.1), an update is answered,
  and its preconditions evaluated, in the media type and language of its content if offered"

  self
    holdTargetLanguageNegotiatedBy: [
        httpRequest contentLanguageTags
          ifEmpty: [ resourceAcceptNegotiator bestLanguageFor: httpRequest ]
          ifNotEmpty: [ :languageTags |
              resourceAcceptNegotiator bestLanguageFor: httpRequest preferring: languageTags first ]
      ]
    for: httpRequest
    within: requestContext.

  ^ requestContext targetMediaType: ( httpRequest hasEntity
          then: [
            resourceAcceptNegotiator
              bestRepresentationFor: httpRequest
              preferring: httpRequest contentType ]
          otherwise: [ resourceAcceptNegotiator bestRepresentationFor: httpRequest ] )
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> ifNoneMatchHeaderPresentIn: httpRequest do: aMonadycBlock [

  httpRequest headers
    at: 'If-None-Match'
    ifPresent: [ :ifNoneMatchHeader |
      aMonadycBlock value: ( self parseEntityTags: ifNoneMatchHeader ) ]
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> ifNoneMatchIn: httpRequest matchesWeakly: anEntityTag [
  "Answers false when there is no If-None-Match"

  self
    ifNoneMatchHeaderPresentIn: httpRequest
    do: [ :entityTags | ^ entityTags matchesWeakly: anEntityTag ].
  ^ false
]

{ #category : 'initialization' }
RESTfulRequestHandlerBehavior >> initializeResourceLocator: aResouceLocator paginationPolicy: aPaginationPolicy collectionValidationPolicy: aCollectionValidationPolicy decodingRules: theDecodingRules resourceEncodingRules: theResourceEncodingRules collectionEncodingRules: theCollectionEncodingRules calculateEntityTagsWith: anEntityTagCalculator cachingDirectives: theCachingDirectives allowedLanguageTags: allowedLanguageTags handleErrorsWith: anExceptionHandler [

  resourceLocator := aResouceLocator.
  resourceLocator handleExceptionsWith: anExceptionHandler.
  paginationPolicy := aPaginationPolicy cull: self.
  collectionValidationPolicy := aCollectionValidationPolicy cull: self.
  decodingRules := theDecodingRules.
  resourceEncodingRules := theResourceEncodingRules.
  collectionEncodingRules := theCollectionEncodingRules.
  resourceAcceptNegotiator := RESTfulControllerAcceptNegotiator
                                accepting: resourceEncodingRules keys
                                inAnyOf: allowedLanguageTags.
  collectionAcceptNegotiator := RESTfulControllerAcceptNegotiator
                                  accepting: collectionEncodingRules keys
                                  inAnyOf: allowedLanguageTags.
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
RESTfulRequestHandlerBehavior >> parseEntityTags: fieldValue [
  "fieldValue is a String, or an Array when the header field is repeated"

  ^ [ fieldValue asEntityTagList ]
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
  "The response depends on Accept-Language even when no language was negotiated,
  since asking for one is not acceptable then. Content-Language describes content,
  so a response without any, such as a 304, carries none (RFC 9110 §15.4.5)"

  response addToVary: 'Accept-Language'.
  response hasEntity ifTrue: [
      requestContext withTargetLanguageTagDo: [ :languageTag |
          response addContentLanguage: languageTag ] ]
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

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> responseRepresenting: resource within: requestContext [

  | response |
  response := ZnResponse ok: ( self encodeResource: resource within: requestContext ).
  self putEntityTagOf: resource in: response within: requestContext.
  self
    applyCachingDirectivesFor: resource to: response within: requestContext;
    putLanguageContentTagIn: response within: requestContext.
  ^ response
]

{ #category : 'accessing' }
RESTfulRequestHandlerBehavior >> serverUrl: aServerUrl [

	resourceLocator baseUrl: aServerUrl
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> signalMissingMediaType [

  ^ self signalUnsupportedMediaTypeDescribedAs: 'The request body has no media type.'
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> signalUnsupportedMediaType: mediaType [

  ^ self signalUnsupportedMediaTypeDescribedAs:
      ( 'Cannot decode a request body of media type <1p>.' expandMacrosWith: mediaType )
]

{ #category : 'private' }
RESTfulRequestHandlerBehavior >> signalUnsupportedMediaTypeDescribedAs: aMessageText [

  ^ HTTPClientError unsupportedMediaType
      additionalDataAt: #acceptedMediaTypes put: self acceptedMediaTypes;
      signal: aMessageText
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
