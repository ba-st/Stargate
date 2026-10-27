"
I'm a test case for RESTfulRequestHandlerBehavior >> from:within:get:thenConditionallyDo:, checking its preconditions are required and evaluated before the action, against the negotiated representation. The action under test is a deletion, the most common one without content
"
Class {
	#name : 'ConditionalActionTest',
	#superclass : 'TestCase',
	#instVars : [
		'requestHandler',
		'thing',
		'wasDeleted'
	],
	#category : 'Stargate-Model-Tests-Controllers',
	#package : 'Stargate-Model-Tests',
	#tag : 'Controllers'
}

{ #category : 'private' }
ConditionalActionTest >> assertDeletionIsRefused: aRequest code: aStatusCode [

  self
    should: [ self delete: aRequest ]
    raise: HTTPClientError
    withExceptionDo: [ :error | self assert: error code equals: aStatusCode ].
  self deny: wasDeleted
]

{ #category : 'private' }
ConditionalActionTest >> assertDeletionSucceeds: aRequest [

  | response |
  response := self delete: aRequest.

  self
    assert: response code equals: 204;
    assert: wasDeleted.
  ^ response
]

{ #category : 'private' }
ConditionalActionTest >> delete: aRequest [

  ^ self
      delete: aRequest
      finding: [ :identifier | thing ]
      thenDo: [ :resource | wasDeleted := true ]
]

{ #category : 'private' }
ConditionalActionTest >> delete: aRequest finding: aQueryBlock thenDo: anActionBlock [

  ^ requestHandler
      from: ( TeaRequest fromZnRequest: aRequest pathParams: Dictionary new )
      within: HttpRequestContext new
      get: aQueryBlock
      thenConditionallyDo: anActionBlock
]

{ #category : 'private' }
ConditionalActionTest >> entityTagAccepting: aMediaType [

  ^ ( self get: ( self requestToGetThing
            setAccept: aMediaType;
            yourself ) ) entityTag
]

{ #category : 'private' }
ConditionalActionTest >> entityTagAcceptingLanguage: aLanguageRange [

  | request |
  request := self requestToGetThing.
  request headers at: 'Accept-Language' put: aLanguageRange.
  ^ ( self get: request ) entityTag
]

{ #category : 'private' }
ConditionalActionTest >> get: aRequest [

  ^ requestHandler
      from: ( TeaRequest fromZnRequest: aRequest pathParams: Dictionary new )
      within: HttpRequestContext new
      get: [ :identifier | thing ]
]

{ #category : 'private' }
ConditionalActionTest >> requestToDeleteThing [

  ^ ZnRequest delete: 'https://api.example.com/things/1'
]

{ #category : 'private' }
ConditionalActionTest >> requestToDeleteThingConditionalTo: anEntityTag [

  ^ self requestToDeleteThing
      setIfMatchTo: anEntityTag;
      yourself
]

{ #category : 'private' }
ConditionalActionTest >> requestToGetThing [

  ^ ZnRequest get: 'https://api.example.com/things/1'
]

{ #category : 'running' }
ConditionalActionTest >> setUp [

  super setUp.
  thing := 'thing'.
  wasDeleted := false.
  requestHandler := RESTfulRequestHandlerBuilder new
                      handling: 'things' extractingIdentifierWith: [ :httpRequest | 1 ];
                      whenResponding: self thingVersion1MediaType
                      encodeApplying: [ :resource | resource ];
                      whenResponding: self thingVersion2MediaType
                      encodeApplying: [ :resource | resource , ' (v2)' ];
                      addAsSupportedLanguage: 'en';
                      addAsSupportedLanguage: 'es';
                      createEntityTagHashing: [ :hasher :resource | hasher include: resource ];
                      build
]

{ #category : 'tests' }
ConditionalActionTest >> testDeletionConflicting [

  self
    should: [
        self
          delete:
          ( self requestToDeleteThingConditionalTo: ( self get: self requestToGetThing ) entityTag )
          finding: [ :identifier | thing ]
          thenDo: [ :resource | ConflictingObjectFound signal: 'Already deleted.' ]
      ]
    raise: HTTPClientError
    withExceptionDo: [ :error |
        self
          assert: error code equals: 409;
          assert: error messageText equals: 'Already deleted.'
      ]
]

{ #category : 'tests' }
ConditionalActionTest >> testDeletionIsComparedInTheLanguageItAccepts [

  | request |
  request := self requestToDeleteThingConditionalTo: ( self entityTagAcceptingLanguage: 'es' ).
  request headers at: 'Accept-Language' put: 'en'.

  self assertDeletionIsRefused: request code: 412.

  request setIfMatchTo: ( self entityTagAcceptingLanguage: 'en' ).
  self assertDeletionSucceeds: request
]

{ #category : 'tests' }
ConditionalActionTest >> testDeletionIsComparedInTheMediaTypeItAccepts [

  | request |
  request := self requestToDeleteThingConditionalTo:
               ( self entityTagAccepting: self thingVersion1MediaType ).
  request setAccept: self thingVersion2MediaType.

  self assertDeletionIsRefused: request code: 412.

  request setAccept: self thingVersion1MediaType.
  self assertDeletionSucceeds: request
]

{ #category : 'tests' }
ConditionalActionTest >> testDeletionMatchingAnyEntityTag [

  self assertDeletionSucceeds: ( self requestToDeleteThingConditionalTo: '*' )
]

{ #category : 'tests' }
ConditionalActionTest >> testDeletionMatchingEntityTag [
  "The request has no content nor Content-Type, and none is needed"

  | response |
  response := self assertDeletionSucceeds:
                ( self requestToDeleteThingConditionalTo:
                    ( self get: self requestToGetThing ) entityTag ).

  self
    deny: response hasEntity;
    assert: ( response varyHeaderNames includes: 'Accept' );
    assert: ( response varyHeaderNames includes: 'Accept-Language' );
    assert: response contentLanguageTags isEmpty
]

{ #category : 'tests' }
ConditionalActionTest >> testDeletionMatchingOneOfSeveralEntityTags [

  self assertDeletionSucceeds: ( self requestToDeleteThingConditionalTo:
        '"stale", ' , ( self get: self requestToGetThing ) entityTag asString )
]

{ #category : 'tests' }
ConditionalActionTest >> testDeletionNotAcceptable [

  self
    assertDeletionIsRefused: ( ( self requestToDeleteThingConditionalTo: '*' )
          setAccept: 'application/xml' asMediaType;
          yourself )
    code: 406
]

{ #category : 'tests' }
ConditionalActionTest >> testDeletionOfMissingResource [

  self
    should: [
        self
          delete: ( self requestToDeleteThingConditionalTo: '*' )
          finding: [ :identifier | ObjectNotFound signal ]
          thenDo: [ :resource | wasDeleted := true ]
      ]
    raise: HTTPClientError
    withExceptionDo: [ :error | self assert: error code equals: 404 ].
  self deny: wasDeleted
]

{ #category : 'tests' }
ConditionalActionTest >> testDeletionWithInvalidIfMatch [

  self assertDeletionIsRefused: ( self requestToDeleteThingConditionalTo: 'stale' ) code: 400
]

{ #category : 'tests' }
ConditionalActionTest >> testDeletionWithMatchingIfNoneMatch [

  | entityTag |
  entityTag := ( self get: self requestToGetThing ) entityTag.

  self
    assertDeletionIsRefused: ( ( self requestToDeleteThingConditionalTo: entityTag )
          setIfNoneMatchTo: entityTag;
          yourself )
    code: 412
]

{ #category : 'tests' }
ConditionalActionTest >> testDeletionWithStaleIfMatch [

  | entityTag |
  entityTag := ( self get: self requestToGetThing ) entityTag.
  thing := 'changed thing'.

  self assertDeletionIsRefused: ( self requestToDeleteThingConditionalTo: entityTag ) code: 412
]

{ #category : 'tests' }
ConditionalActionTest >> testDeletionWithoutAcceptIsComparedInTheDefaultMediaType [
  "Without Accept the default representation is the version 2.0.0 one, so a tag read in
  version 1.0.0 does not match it"

  self
    assertDeletionIsRefused:
    ( self requestToDeleteThingConditionalTo:
        ( self entityTagAccepting: self thingVersion1MediaType ) )
    code: 412.

  self assertDeletionSucceeds:
    ( self requestToDeleteThingConditionalTo:
        ( self entityTagAccepting: self thingVersion2MediaType ) )
]

{ #category : 'tests' }
ConditionalActionTest >> testDeletionWithoutIfMatch [

  self assertDeletionIsRefused: self requestToDeleteThing code: 428
]

{ #category : 'private' }
ConditionalActionTest >> thingVersion1MediaType [

  ^ 'application/vnd.example.thing+json;version=1.0.0' asMediaType
]

{ #category : 'private' }
ConditionalActionTest >> thingVersion2MediaType [

  ^ 'application/vnd.example.thing+json;version=2.0.0' asMediaType
]
