"
I'm a test case for the entity tags calculated by RESTfulRequestHandlerBuilder >> createEntityTagHashing:, checking they cover the language of the representation
"
Class {
	#name : 'EntityTagHashingTest',
	#superclass : 'TestCase',
	#instVars : [
		'requestHandler'
	],
	#category : 'Stargate-Model-Tests-Controllers',
	#package : 'Stargate-Model-Tests',
	#tag : 'Controllers'
}

{ #category : 'private' }
EntityTagHashingTest >> entityTagAcceptingLanguage: aLanguageRange [

  ^ ( self getAcceptingLanguage: aLanguageRange ) entityTag
]

{ #category : 'private' }
EntityTagHashingTest >> get: aRequest [

  ^ requestHandler
      from: ( TeaRequest fromZnRequest: aRequest pathParams: Dictionary new )
      within: HttpRequestContext new
      get: [ :identifier | 'thing' ]
]

{ #category : 'private' }
EntityTagHashingTest >> get: aRequest acceptingLanguage: aLanguageRange [

  aRequest headers at: 'Accept-Language' put: aLanguageRange.
  ^ self get: aRequest
]

{ #category : 'private' }
EntityTagHashingTest >> getAcceptingLanguage: aLanguageRange [

  ^ self get: self requestToGetThing acceptingLanguage: aLanguageRange
]

{ #category : 'private' }
EntityTagHashingTest >> requestToGetThing [

  ^ ( ZnRequest get: 'https://api.example.com/things/1' )
      setAccept: ZnMimeType applicationJson;
      yourself
]

{ #category : 'running' }
EntityTagHashingTest >> setUp [

  super setUp.
  requestHandler := RESTfulRequestHandlerBuilder new
                      handling: 'things' extractingIdentifierWith: [ :httpRequest | 1 ];
                      whenResponding: ZnMimeType applicationJson
                      encodeApplying: [ :resource | resource ];
                      whenAccepting: ZnMimeType applicationJson decodeApplying: [ :json | json ];
                      addAsSupportedLanguage: 'en';
                      addAsSupportedLanguage: 'es';
                      createEntityTagHashing: [ :hasher :resource | hasher include: resource ];
                      build
]

{ #category : 'tests' }
EntityTagHashingTest >> testEntityTagWithoutAcceptLanguageIsTheDefaultLanguageOne [

  self
    assert: ( self get: self requestToGetThing ) entityTag
    equals: ( self entityTagAcceptingLanguage: 'en' )
]

{ #category : 'tests' }
EntityTagHashingTest >> testEntityTagsAreUnchangedWhenNoLanguageIsNegotiated [

  | response |
  requestHandler := RESTfulRequestHandlerBuilder new
                      handling: 'things' extractingIdentifierWith: [ :httpRequest | 1 ];
                      whenResponding: ZnMimeType applicationJson
                      encodeApplying: [ :resource | resource ];
                      createEntityTagHashing: [ :hasher :resource | hasher include: resource ];
                      build.

  response := self get: self requestToGetThing.

  self assert: response entityTag equals: ( EntityTag with: ( EntityTagHasher new
            include: 'thing';
            include: ZnMimeType applicationJson;
            calculateHash ) )
]

{ #category : 'tests' }
EntityTagHashingTest >> testEntityTagsDifferPerNegotiatedLanguage [

  | englishEntityTag spanishEntityTag |
  englishEntityTag := self entityTagAcceptingLanguage: 'en'.
  spanishEntityTag := self entityTagAcceptingLanguage: 'es'.

  self
    assert: englishEntityTag isStrong;
    assert: spanishEntityTag isStrong;
    deny: ( englishEntityTag matchesWeakly: spanishEntityTag )
]

{ #category : 'tests' }
EntityTagHashingTest >> testSwitchingLanguageIsNotAnsweredNotModified [

  | englishEntityTag response |
  englishEntityTag := self entityTagAcceptingLanguage: 'en'.

  response := self
                get: ( self requestToGetThing
                      setIfNoneMatchTo: englishEntityTag;
                      yourself )
                acceptingLanguage: 'es'.

  self
    assert: response code equals: 200;
    assert: response entityTag equals: ( self entityTagAcceptingLanguage: 'es' )
]

{ #category : 'tests' }
EntityTagHashingTest >> testUpdateIsComparedInItsContentLanguage [
  "The update is in Spanish and has no Accept-Language, so the negotiated language is English"

  self
    assert: ( self updateInSpanishConditionalTo: ( self entityTagAcceptingLanguage: 'es' ) ) code
    equals: 200.
  self
    should: [ self updateInSpanishConditionalTo: ( self entityTagAcceptingLanguage: 'en' ) ]
    raise: HTTPClientError
    withExceptionDo: [ :error | self assert: error code equals: 412 ]
]

{ #category : 'private' }
EntityTagHashingTest >> updateInSpanishConditionalTo: anEntityTag [

  | request |
  request := ( ZnRequest patch: 'https://api.example.com/things/1' )
               setAccept: ZnMimeType applicationJson;
               setIfMatchTo: anEntityTag;
               entity: ( ZnEntity with: '"cosa"' type: ZnMimeType applicationJson );
               yourself.
  request headers at: 'Content-Language' put: 'es'.

  ^ requestHandler
      from: ( TeaRequest fromZnRequest: request pathParams: Dictionary new )
      within: HttpRequestContext new
      get: [ :identifier | 'thing' ]
      thenUpdateWith: [ :resource :update | update ]
]
