"
I'm a test case for the encoding rules a RESTfulRequestHandlerBuilder configures separately for single resources and for collections
"
Class {
	#name : 'ResourceAndCollectionEncodingTest',
	#superclass : 'TestCase',
	#instVars : [
		'requestHandler'
	],
	#category : 'Stargate-Model-Tests-Controllers',
	#package : 'Stargate-Model-Tests',
	#tag : 'Controllers'
}

{ #category : 'private' }
ResourceAndCollectionEncodingTest >> assertNotAcceptable: aBlock allowing: theMediaTypes [

  self
    should: aBlock
    raise: HTTPNotAcceptable
    withExceptionDo: [ :error |
      self assertCollection: error allowedMediaTypes hasSameElements: theMediaTypes ]
]

{ #category : 'private' }
ResourceAndCollectionEncodingTest >> csvMediaType [

  ^ 'text/csv' asMediaType
]

{ #category : 'private' }
ResourceAndCollectionEncodingTest >> getCollection: aRequest [

  ^ requestHandler
      from: ( TeaRequest fromZnRequest: aRequest pathParams: Dictionary new )
      within: HttpRequestContext new
      getCollection: [ #( 'thing' 'other thing' ) ]
]

{ #category : 'private' }
ResourceAndCollectionEncodingTest >> getCollectionAccepting: aMediaType [

  ^ self getCollection: ( self requestToGetThingsAccepting: aMediaType )
]

{ #category : 'private' }
ResourceAndCollectionEncodingTest >> getResource: aRequest [

  ^ requestHandler
      from: ( TeaRequest fromZnRequest: aRequest pathParams: Dictionary new )
      within: HttpRequestContext new
      get: [ :identifier | 'thing' ]
]

{ #category : 'private' }
ResourceAndCollectionEncodingTest >> getResourceAccepting: aMediaType [

  ^ self getResource: ( self requestToGetThingAccepting: aMediaType )
]

{ #category : 'private' }
ResourceAndCollectionEncodingTest >> requestToGetThingAccepting: aMediaType [

  ^ ( ZnRequest get: 'https://api.example.com/things/1' )
      setAccept: aMediaType;
      yourself
]

{ #category : 'private' }
ResourceAndCollectionEncodingTest >> requestToGetThingsAccepting: aMediaType [

  ^ ( ZnRequest get: 'https://api.example.com/things' )
      setAccept: aMediaType;
      yourself
]

{ #category : 'running' }
ResourceAndCollectionEncodingTest >> setUp [

  super setUp.
  requestHandler := RESTfulRequestHandlerBuilder new
                      handling: 'things' extractingIdentifierWith: [ :httpRequest | 1 ];
                      whenResponding: ZnMimeType textPlain
                      encodeApplying: [ :resourceOrCollection | 'plain text' ];
                      whenResponding: self csvMediaType
                      encodeCollectionApplying: [ :collection | ', ' join: collection ];
                      whenResponding: self thingVersion2MediaType
                      encodeResourceApplying: [ :resource | 'version 2 of ' , resource ];
                      whenResponding: self thingVersion1MediaType
                      encodeResourceApplying: [ :resource | 'version 1 of ' , resource ];
                      whenResponding: self thingVersion1MediaType
                      encodeCollectionApplying: [ :collection | 'version 1 of all things' ];
                      addAsSupportedLanguage: 'en';
                      createEntityTagHashingEncodedResource;
                      createEntityTagHashingEncodedCollection;
                      build
]

{ #category : 'tests' }
ResourceAndCollectionEncodingTest >> testCollectionMediaTypesAreNotAcceptableForResources [

  self
    assertNotAcceptable: [ self getResourceAccepting: self csvMediaType ]
    allowing: { ZnMimeType textPlain . self thingVersion1MediaType . self thingVersion2MediaType }
]

{ #category : 'tests' }
ResourceAndCollectionEncodingTest >> testCollectionMediaTypesAreServedForCollections [

  | response |
  response := self getCollectionAccepting: self csvMediaType.

  self
    assert: response code equals: 200;
    assert: response contentType equals: self csvMediaType;
    assert: response contents equals: 'thing, other thing'
]

{ #category : 'tests' }
ResourceAndCollectionEncodingTest >> testCollectionsAreRevalidatedInTheirOwnMediaTypes [

  | entityTag response |
  entityTag := ( self getCollectionAccepting: self csvMediaType ) entityTag.

  response := self getCollection: ( ( self requestToGetThingsAccepting: self csvMediaType )
                    setIfNoneMatchTo: entityTag;
                    yourself ).

  self
    assert: response code equals: 304;
    assert: response entityTag equals: entityTag
]

{ #category : 'tests' }
ResourceAndCollectionEncodingTest >> testConfiguringAMediaTypeTwiceForTheSameCaseFails [

  | builder |
  builder := RESTfulRequestHandlerBuilder new
               whenResponding: ZnMimeType textPlain encodeApplying: [ :resource | resource ];
               whenResponding: self csvMediaType
               encodeCollectionApplying: [ :collection | collection ];
               whenResponding: self thingVersion1MediaType
               encodeResourceApplying: [ :resource | resource ];
               yourself.

  self
    should: [
        builder
          whenResponding: ZnMimeType textPlain
          encodeResourceApplying: [ :resource | resource ] ]
    raise: AssertionFailed
    withMessageText: 'Encoding rule for media type already configured';
    should: [
        builder
          whenResponding: ZnMimeType textPlain
          encodeCollectionApplying: [ :collection | collection ] ]
    raise: AssertionFailed withMessageText: 'Encoding rule for media type already configured';
    should: [ builder whenResponding: self csvMediaType encodeApplying: [ :resource | resource ] ]
    raise: AssertionFailed
    withMessageText: 'Encoding rule for media type already configured';
    should: [
        builder whenResponding: self thingVersion1MediaType encodeApplying: [ :resource | resource ] ]
    raise: AssertionFailed
    withMessageText: 'Encoding rule for media type already configured'
]

{ #category : 'tests' }
ResourceAndCollectionEncodingTest >> testHypermediaDrivenHandlerEncodesCollectionsWithTheirOwnRules [

  | collectionMediaType response |
  collectionMediaType := 'application/vnd.example.things+json' asMediaType.
  requestHandler := RESTfulRequestHandlerBuilder new
                      handling: 'things'
                      locatingResourcesWith: [ :resource :requestContext | resource ]
                      extractingIdentifierWith: [ :httpRequest | 1 ];
                      beHypermediaDriven;
                      whenResponding: self thingVersion1MediaType
                      encodeResourceToJsonApplying: [ :resource :requestContext :writer |  ];
                      whenResponding: collectionMediaType
                      encodeCollectionToJsonApplying: [ :resource :requestContext :writer |  ];
                      createEntityTagHashingEncodedResource;
                      build.

  response := self getCollectionAccepting: collectionMediaType.

  self
    assert: response code equals: 200;
    assert: response contentType equals: collectionMediaType;
    assert: ( NeoJSONObject fromString: response contents ) items asArray
    equals: #( 'thing' 'other thing' );
    assertNotAcceptable: [ self getResourceAccepting: collectionMediaType ]
    allowing: { self thingVersion1MediaType };
    assertNotAcceptable: [ self getCollectionAccepting: self thingVersion1MediaType ]
    allowing: { collectionMediaType }
]

{ #category : 'tests' }
ResourceAndCollectionEncodingTest >> testHypermediaDrivenHandlerKeepsWorkingWithASingleRuleSet [

  | response |
  requestHandler := HypermediaDrivenRESTfulRequestHandler
                      resourceLocator: ( ResourceLocator
                            handling: 'things'
                            calculatingLocationWith: [ :resource :requestContext | resource ]
                            andIdentifierBy: [ :httpRequest | 1 ] )
                      paginationPolicy: [ :handler |
                        RESTfulControllerDoNotPaginateCollectionsPolicy for: handler ]
                      collectionValidationPolicy: [ :handler |
                        RESTfulControllerDoNotValidateCollectionsPolicy for: handler ]
                      decodingRules: Dictionary new
                      encodingRules: ( Dictionary new
                            at: self csvMediaType
                            put:
                              ( ResourceEncodingRule
                                  encoding: self csvMediaType
                                  using: [ :resourceOrCollection | 'CSV' ] );
                            yourself )
                      calculateEntityTagsWith: [ :resource :mediaType :requestContext :handler |
                        resource ]
                      cachingDirectives: #(  )
                      allowedLanguageTags: #(  )
                      drivenBy: [ :builder | builder build ]
                      handleErrorsWith: RESTfulRequestExceptionHandler new.

  response := self getCollectionAccepting: self csvMediaType.
  self assert: response contents equals: 'CSV'.

  response := self getResourceAccepting: self csvMediaType.
  self assert: response contents equals: 'CSV'
]

{ #category : 'tests' }
ResourceAndCollectionEncodingTest >> testMediaTypesConfiguredForBothCasesAreServedForBoth [

  self
    assert: ( self getResourceAccepting: ZnMimeType textPlain ) contents equals: 'plain text';
    assert: ( self getCollectionAccepting: ZnMimeType textPlain ) contents equals: 'plain text'
]

{ #category : 'tests' }
ResourceAndCollectionEncodingTest >> testNotAcceptableLanguageListsTheMediaTypesOfEachCase [

  self
    assertNotAcceptable: [
        self getResource: ( ( self requestToGetThingAccepting: self csvMediaType )
                setAcceptLanguage: 'fr';
                yourself )
      ]
    allowing: { ZnMimeType textPlain . self thingVersion1MediaType . self thingVersion2MediaType };
    assertNotAcceptable: [
        self getCollection: ( ( self requestToGetThingsAccepting: self csvMediaType )
              setAcceptLanguage: 'fr';
              yourself )
      ]
    allowing: { ZnMimeType textPlain . self csvMediaType . self thingVersion1MediaType }
]

{ #category : 'tests' }
ResourceAndCollectionEncodingTest >> testRequestHandlerKeepsWorkingWithASingleRuleSet [

  | response |
  requestHandler := RESTfulRequestHandler
                      resourceLocator:
                      ( ResourceLocator
                          handling: 'things'
                          extractingIdentifierWith: [ :httpRequest | 1 ] )
                      paginationPolicy: [ :handler |
                        RESTfulControllerDoNotPaginateCollectionsPolicy for: handler ]
                      collectionValidationPolicy: [ :handler |
                        RESTfulControllerDoNotValidateCollectionsPolicy for: handler ]
                      decodingRules: Dictionary new
                      encodingRules: ( Dictionary new
                            at: self csvMediaType
                            put:
                              ( ResourceEncodingRule
                                  encoding: self csvMediaType
                                  using: [ :resourceOrCollection | 'CSV' ] );
                            yourself )
                      calculateEntityTagsWith: [ :resource :mediaType :requestContext :handler |
                        resource ]
                      cachingDirectives: #(  )
                      allowedLanguageTags: #(  )
                      handleErrorsWith: RESTfulRequestExceptionHandler new.

  response := self getCollectionAccepting: self csvMediaType.
  self assert: response contents equals: 'CSV'.

  response := self getResourceAccepting: self csvMediaType.
  self assert: response contents equals: 'CSV'
]

{ #category : 'tests' }
ResourceAndCollectionEncodingTest >> testResourceMediaTypesAreNotAcceptableForCollections [

  self
    assertNotAcceptable: [ self getCollectionAccepting: self thingVersion2MediaType ]
    allowing: { ZnMimeType textPlain . self csvMediaType . self thingVersion1MediaType }
]

{ #category : 'tests' }
ResourceAndCollectionEncodingTest >> testResourceMediaTypesAreServedForResources [

  | response |
  response := self getResourceAccepting: self thingVersion2MediaType.

  self
    assert: response code equals: 200;
    assert: response contentType equals: self thingVersion2MediaType;
    assert: response contents equals: 'version 2 of thing'
]

{ #category : 'tests' }
ResourceAndCollectionEncodingTest >> testResourcesAreRevalidatedInTheirOwnMediaTypes [

  | entityTag response |
  entityTag := ( self getResourceAccepting: self thingVersion2MediaType ) entityTag.

  response := self getResource: ( ( self requestToGetThingAccepting: self thingVersion2MediaType )
                    setIfNoneMatchTo: entityTag;
                    yourself ).

  self
    assert: response code equals: 304;
    assert: response entityTag equals: entityTag
]

{ #category : 'tests' }
ResourceAndCollectionEncodingTest >> testSameMediaTypeIsEncodedPerCase [

  self
    assert: ( self getResourceAccepting: self thingVersion1MediaType ) contents
    equals: 'version 1 of thing';
    assert: ( self getCollectionAccepting: self thingVersion1MediaType ) contents
    equals: 'version 1 of all things'
]

{ #category : 'private' }
ResourceAndCollectionEncodingTest >> thingVersion1MediaType [

  ^ 'application/vnd.example.thing+json;version=1.0.0' asMediaType
]

{ #category : 'private' }
ResourceAndCollectionEncodingTest >> thingVersion2MediaType [

  ^ 'application/vnd.example.thing+json;version=2.0.0' asMediaType
]
