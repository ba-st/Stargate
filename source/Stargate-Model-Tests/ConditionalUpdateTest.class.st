"
I'm a test case for the preconditions of updates, checking they are evaluated against the negotiated representation and not against the one of the request content
"
Class {
	#name : 'ConditionalUpdateTest',
	#superclass : 'TestCase',
	#instVars : [
		'requestHandler',
		'thing'
	],
	#category : 'Stargate-Model-Tests-Controllers',
	#package : 'Stargate-Model-Tests',
	#tag : 'Controllers'
}

{ #category : 'private' }
ConditionalUpdateTest >> buildRequestHandlerCreatingEntityTagsWith: aConfigurationBlock [

  | builder |
  builder := RESTfulRequestHandlerBuilder new
               handling: 'things' extractingIdentifierWith: [ :httpRequest | 1 ];
               whenAccepting: self submissionMediaType decodeApplying: [ :content | content ];
               whenAccepting: self thingVersion1MediaType decodeApplying: [ :content | content ];
               whenResponding: self thingVersion1MediaType encodeApplying: [ :resource | resource ];
               whenResponding: self thingVersion2MediaType
               encodeApplying: [ :resource | resource , ' (v2)' ];
               yourself.
  aConfigurationBlock value: builder.
  requestHandler := builder build
]

{ #category : 'private' }
ConditionalUpdateTest >> get: aRequest [

  ^ requestHandler
      from: ( TeaRequest fromZnRequest: aRequest pathParams: Dictionary new )
      within: HttpRequestContext new
      get: [ :identifier | thing ]
]

{ #category : 'private' }
ConditionalUpdateTest >> getAccepting: aMediaType [

  ^ self get: ( self requestToGetThing
          setAccept: aMediaType;
          yourself )
]

{ #category : 'private' }
ConditionalUpdateTest >> requestToGetThing [

  ^ ZnRequest get: 'https://api.example.com/things/1'
]

{ #category : 'private' }
ConditionalUpdateTest >> requestToUpdateThingWith: aContent in: aMediaType conditionalTo: anEntityTag [

  ^ ( ZnRequest put: 'https://api.example.com/things/1' )
      setIfMatchTo: anEntityTag;
      entity: ( ZnEntity with: aContent type: aMediaType );
      yourself
]

{ #category : 'running' }
ConditionalUpdateTest >> setUp [

  super setUp.
  thing := 'thing'.
  self buildRequestHandlerCreatingEntityTagsWith: [ :builder |
      builder createEntityTagHashing: [ :hasher :resource | hasher include: resource ] ]
]

{ #category : 'private' }
ConditionalUpdateTest >> submissionMediaType [

  ^ 'application/vnd.example.submission+json;version=1.0.0' asMediaType
]

{ #category : 'tests' }
ConditionalUpdateTest >> testSubmissionIsComparedInTheNegotiatedMediaType [

  | response |
  response := self
                update: ( self
                      requestToUpdateThingWith: 'new thing'
                      in: self submissionMediaType
                      conditionalTo: ( self getAccepting: self thingVersion1MediaType ) entityTag )
                accepting: self thingVersion1MediaType.

  self
    assert: response code equals: 200;
    assert: response contentType equals: self thingVersion1MediaType;
    assert: response entityTag equals: ( self getAccepting: self thingVersion1MediaType ) entityTag
]

{ #category : 'tests' }
ConditionalUpdateTest >> testSubmissionIsComparedInTheNegotiatedMediaTypeHashingTheEncodedResource [

  | response |
  self buildRequestHandlerCreatingEntityTagsWith: [ :builder |
      builder createEntityTagHashingEncodedResource ].

  response := self
                update: ( self
                      requestToUpdateThingWith: 'new thing'
                      in: self submissionMediaType
                      conditionalTo: ( self getAccepting: self thingVersion1MediaType ) entityTag )
                accepting: self thingVersion1MediaType.

  self
    assert: response code equals: 200;
    assert: response contentType equals: self thingVersion1MediaType
]

{ #category : 'tests' }
ConditionalUpdateTest >> testSubmissionWithoutAcceptIsComparedInTheDefaultMediaType [

  | response |
  response := self update: ( self
                    requestToUpdateThingWith: 'new thing'
                    in: self submissionMediaType
                    conditionalTo: ( self get: self requestToGetThing ) entityTag ).

  self
    assert: response code equals: 200;
    assert: response contentType equals: self thingVersion2MediaType.

  response := self update: ( self
                    requestToUpdateThingWith: 'newer thing'
                    in: self submissionMediaType
                    conditionalTo: response entityTag ).

  self
    assert: response code equals: 200;
    assert: thing equals: 'newer thing'
]

{ #category : 'tests' }
ConditionalUpdateTest >> testUpdateIsComparedInTheMediaTypeItAccepts [

  | readEntityTag |
  readEntityTag := ( self getAccepting: self thingVersion1MediaType ) entityTag.

  self
    should: [
        self
          update: ( self
                requestToUpdateThingWith: 'new thing'
                in: self thingVersion1MediaType
                conditionalTo: readEntityTag )
          accepting: self thingVersion2MediaType
      ]
    raise: HTTPClientError
    withExceptionDo: [ :error | self assert: error code equals: 412 ].

  self assert: thing equals: 'thing'
]

{ #category : 'tests' }
ConditionalUpdateTest >> testUpdateWithoutAcceptIsComparedInItsContentMediaType [
  "Without Accept the default representation is the version 2.0.0 one, but the content's
  media type is chosen since it is also offered"

  | response |
  response := self update: ( self
                    requestToUpdateThingWith: 'new thing'
                    in: self thingVersion1MediaType
                    conditionalTo: ( self getAccepting: self thingVersion1MediaType ) entityTag ).

  self
    assert: response code equals: 200;
    assert: response contentType equals: self thingVersion1MediaType
]

{ #category : 'private' }
ConditionalUpdateTest >> thingVersion1MediaType [

  ^ 'application/vnd.example.thing+json;version=1.0.0' asMediaType
]

{ #category : 'private' }
ConditionalUpdateTest >> thingVersion2MediaType [

  ^ 'application/vnd.example.thing+json;version=2.0.0' asMediaType
]

{ #category : 'private' }
ConditionalUpdateTest >> update: aRequest [

  ^ requestHandler
      from: ( TeaRequest fromZnRequest: aRequest pathParams: Dictionary new )
      within: HttpRequestContext new
      get: [ :identifier | thing ]
      thenUpdateWith: [ :resource :update | thing := update ]
]

{ #category : 'private' }
ConditionalUpdateTest >> update: aRequest accepting: aMediaType [

  aRequest setAccept: aMediaType.
  ^ self update: aRequest
]
