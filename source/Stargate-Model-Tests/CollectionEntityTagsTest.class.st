"
I'm a test case for the collection entity tags calculated by RESTfulRequestHandlerBuilder >> createCollectionEntityTagWith: and createCollectionEntityTagHashing:
"
Class {
	#name : 'CollectionEntityTagsTest',
	#superclass : 'TestCase',
	#instVars : [
		'encodings'
	],
	#category : 'Stargate-Model-Tests-Controllers',
	#package : 'Stargate-Model-Tests',
	#tag : 'Controllers'
}

{ #category : 'private' }
CollectionEntityTagsTest >> get: aRequest acceptingLanguage: aLanguageRange from: aRequestHandler [

  aRequest setAcceptLanguage: aLanguageRange.
  ^ self get: aRequest from: aRequestHandler
]

{ #category : 'private' }
CollectionEntityTagsTest >> get: aRequest from: aRequestHandler [

  ^ aRequestHandler
      from: ( TeaRequest fromZnRequest: aRequest pathParams: Dictionary new )
      within: HttpRequestContext new
      getCollection: [ #( 'thing' 'other thing' ) ]
]

{ #category : 'private' }
CollectionEntityTagsTest >> requestHandlerConfiguredBy: aBlock [

  | builder |
  builder := RESTfulRequestHandlerBuilder new
               handling: 'things';
               whenResponding: ZnMimeType applicationJson encodeApplying: [ :collection |
                   encodings := encodings + 1.
                   ', ' join: collection
                 ];
               createEntityTagHashingEncodedResource;
               yourself.
  aBlock value: builder.
  ^ builder build
]

{ #category : 'private' }
CollectionEntityTagsTest >> requestToGetThings [

  ^ ( ZnRequest get: 'https://api.example.com/things' )
      setAccept: ZnMimeType applicationJson;
      yourself
]

{ #category : 'private' }
CollectionEntityTagsTest >> requestToGetThingsUnlessMatching: theEntityTagsNotToMatch [

  ^ self requestToGetThings
      setIfNoneMatchTo: theEntityTagsNotToMatch;
      yourself
]

{ #category : 'running' }
CollectionEntityTagsTest >> setUp [

  super setUp.
  encodings := 0
]

{ #category : 'tests' }
CollectionEntityTagsTest >> testCalculatedEntityTagKeepsItsStrength [

  | requestHandler response |
  requestHandler := self requestHandlerConfiguredBy: [ :builder |
                        builder createCollectionEntityTagWith: [
                          :collection
                          :mediaType
                          :requestContext
                          :handler | EntityTag weakWith: collection size printString ]
                      ].

  response := self get: self requestToGetThings from: requestHandler.

  self
    assert: response status equals: 200;
    assert: ( response headers at: 'ETag' ) equals: 'W/"2"'
]

{ #category : 'tests' }
CollectionEntityTagsTest >> testCalculatedStringIsAStrongEntityTag [

  | requestHandler response |
  requestHandler := self requestHandlerConfiguredBy: [ :builder |
                        builder createCollectionEntityTagWith: [
                          :collection
                          :mediaType
                          :requestContext
                          :handler | collection size printString ]
                      ].

  response := self get: self requestToGetThings from: requestHandler.

  self
    assert: response status equals: 200;
    assert: ( response headers at: 'ETag' ) equals: '"2"'
]

{ #category : 'tests' }
CollectionEntityTagsTest >> testHashingCoversTheMediaTypeAndLanguage [

  | requestHandler englishEntityTag spanishEntityTag |
  requestHandler := self requestHandlerConfiguredBy: [ :builder |
                        builder
                          addAsSupportedLanguage: 'en';
                          addAsSupportedLanguage: 'es';
                          createCollectionEntityTagHashing: [ :hasher :collection |
                              hasher include: collection size ]
                      ].

  englishEntityTag := ( self
                          get: self requestToGetThings
                          acceptingLanguage: 'en'
                          from: requestHandler ) entityTag.
  spanishEntityTag := ( self
                          get: self requestToGetThings
                          acceptingLanguage: 'es'
                          from: requestHandler ) entityTag.

  self
    assert: englishEntityTag isStrong;
    assert: englishEntityTag equals: ( EntityTag with: ( EntityTagHasher new
                include: 2;
                include: ZnMimeType applicationJson;
                include: 'en' asLanguageTag;
                calculateHash ) );
    deny: ( englishEntityTag matchesWeakly: spanishEntityTag )
]

{ #category : 'tests' }
CollectionEntityTagsTest >> testHashingCoversTheMediaTypeWhenNoLanguageIsNegotiated [

  | requestHandler response |
  requestHandler := self requestHandlerConfiguredBy: [ :builder |
                        builder createCollectionEntityTagHashing: [ :hasher :collection |
                            hasher include: collection size ] ].

  response := self get: self requestToGetThings from: requestHandler.

  self assert: response entityTag equals: ( EntityTag with: ( EntityTagHasher new
            include: 2;
            include: ZnMimeType applicationJson;
            calculateHash ) )
]

{ #category : 'tests' }
CollectionEntityTagsTest >> testHashingNotModifiedDoesNotEncode [

  | requestHandler entityTag response |
  requestHandler := self requestHandlerConfiguredBy: [ :builder |
                        builder createCollectionEntityTagHashing: [ :hasher :collection |
                            hasher include: collection size ] ].
  entityTag := ( self get: self requestToGetThings from: requestHandler ) entityTag.

  response := self get: ( self requestToGetThingsUnlessMatching: entityTag ) from: requestHandler.

  self
    assert: response code equals: 304;
    assert: response entityTag equals: entityTag;
    assert: encodings equals: 1
]

{ #category : 'tests' }
CollectionEntityTagsTest >> testNotModifiedDoesNotEncode [

  | requestHandler response |
  requestHandler := self requestHandlerConfiguredBy: [ :builder |
                        builder createCollectionEntityTagWith: [
                          :collection
                          :mediaType
                          :requestContext
                          :handler | 'things' ] ].

  response := self get: ( self requestToGetThingsUnlessMatching: '"things"' ) from: requestHandler.

  self
    assert: response code equals: 304;
    deny: response hasEntity;
    assert: ( response headers at: 'ETag' ) equals: '"things"';
    assert: encodings equals: 0
]

{ #category : 'tests' }
CollectionEntityTagsTest >> testOkEncodesOnce [

  | requestHandler response |
  requestHandler := self requestHandlerConfiguredBy: [ :builder |
                        builder createCollectionEntityTagWith: [
                          :collection
                          :mediaType
                          :requestContext
                          :handler | 'things' ] ].

  response := self get: ( self requestToGetThingsUnlessMatching: '"others"' ) from: requestHandler.

  self
    assert: response status equals: 200;
    assert: response contents equals: 'thing, other thing';
    assert: encodings equals: 1
]
