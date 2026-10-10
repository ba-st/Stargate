"
I'm a user stoty test testing the service providing the Pet resource, in the classic Pet Store example
"
Class {
	#name : 'PetsRESTfulControllerTest',
	#superclass : 'SingleResourceRESTfulControllerTest',
	#instVars : [
		'petRepository'
	],
	#category : 'Stargate-Examples-Tests-PetStore',
	#package : 'Stargate-Examples-Tests',
	#tag : 'PetStore'
}

{ #category : 'private - support' }
PetsRESTfulControllerTest >> assert: anObject equals: aSecondObject or: aThirdObject [

	self assert: ( anObject = aSecondObject or: [ anObject = aThirdObject ] )
]

{ #category : 'private - support' }
PetsRESTfulControllerTest >> baseUrl [

	^ 'https://pets.example.com' asUrl 
]

{ #category : 'private - support' }
PetsRESTfulControllerTest >> createPet [

	self
		assert:
			(resourceController
				createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}')
				within: self newHttpRequestContext) isSuccess
]

{ #category : 'private - support' }
PetsRESTfulControllerTest >> createSixPets [

	resourceController
		createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}') within: self newHttpRequestContext;
		createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Lassie","type":"dog"}') within: self newHttpRequestContext;
		createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Garfield","type":"cat"}') within: self newHttpRequestContext;
		createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Rin Tin Tin","type":"dog"}') within: self newHttpRequestContext;
		createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Babe","type":"pig"}') within: self newHttpRequestContext;
		createPetBasedOn: (self requestToCreatePetFrom: '{"name":"Beethoven","type":"dog"}') within: self newHttpRequestContext.

	self assert: petRepository count equals: 6
]

{ #category : 'private - support' }
PetsRESTfulControllerTest >> defaultPetMediaType [

	^ resourceController petVersion1dot0dot0MediaType
]

{ #category : 'private - support' }
PetsRESTfulControllerTest >> entityTagOfPetIdentifiedBy: anIdentifier [

	| getResponse |

	getResponse := resourceController
		getPetBasedOn: ( self requestToGETResourceIdentifiedBy: anIdentifier accepting: self defaultPetMediaType )
		within: self newHttpRequestContext.
	self assert: getResponse isSuccess.
	^ getResponse entityTag
]

{ #category : 'private - support' }
PetsRESTfulControllerTest >> getPetsAt: aUrl [

  ^ resourceController
      getPetsBasedOn:
      ( self requestToGET: aUrl accepting: resourceController petSummaryVersion1dot0dot0MediaType )
      within: self newHttpRequestContext
]

{ #category : 'private - support' }
PetsRESTfulControllerTest >> getPetsAt: aUrl conditionalTo: theEntityTagsNotToMatch [

  ^ resourceController
      getPetsBasedOn: ( self requestToGET: aUrl applying: [ :request |
              request
                setAccept: resourceController petSummaryVersion1dot0dot0MediaType;
                setIfNoneMatchTo: theEntityTagsNotToMatch
            ] )
      within: self newHttpRequestContext
]

{ #category : 'private - support' }
PetsRESTfulControllerTest >> requestMissingIfMatchHeaderToUpdatePetIdentifiedBy: anIdentifier nameTo: aName [

	^ TeaRequest
		fromZnRequest:
			( ( ZnRequest patch: ( self urlForResourceIdentifiedBy: anIdentifier ) )
				setAccept: self defaultPetMediaType;
				entity: ( ZnEntity with: ( '{"name":"<1s>"}' expandMacrosWith: aName ) type: self defaultPetMediaType );
				yourself )
		pathParams: ( self parametersWith: anIdentifier )
]

{ #category : 'private - support' }
PetsRESTfulControllerTest >> requestToCreatePetFrom: json [

	^ self requestToPOST: json as: self defaultPetMediaType
]

{ #category : 'private - support' }
PetsRESTfulControllerTest >> requestToGetPetsAccepting: anAcceptHeader [

	^ self requestToGET: self resourceUrl accepting: anAcceptHeader
]

{ #category : 'private - support' }
PetsRESTfulControllerTest >> requestToUpdatePetIdentifiedBy: anIdentifier nameTo: aName [

	^ self requestToUpdatePetIdentifiedBy: anIdentifier nameTo: aName using: (self entityTagOfPetIdentifiedBy: anIdentifier)
]

{ #category : 'private - support' }
PetsRESTfulControllerTest >> requestToUpdatePetIdentifiedBy: anIdentifier nameTo: aName repeatingIfMatchWith: fieldValues [

  | request |
  request := ( ZnRequest patch: ( self urlForResourceIdentifiedBy: anIdentifier ) )
               setAccept: self defaultPetMediaType;
               entity:
                 ( ZnEntity
                     with: ( '{"name":"<1s>"}' expandMacrosWith: aName )
                     type: self defaultPetMediaType );
               yourself.
  fieldValues do: [ :fieldValue | request headers at: 'If-Match' add: fieldValue ].
  ^ TeaRequest fromZnRequest: request pathParams: ( self parametersWith: anIdentifier )
]

{ #category : 'private - support' }
PetsRESTfulControllerTest >> requestToUpdatePetIdentifiedBy: anIdentifier nameTo: aName using: anETag [

	^ self
		requestToPATCHResourceIdentifiedBy: anIdentifier
		with: ( '{"name":"<1s>"}' expandMacrosWith: aName )
		accepting: self defaultPetMediaType
		conditionalTo: anETag
]

{ #category : 'private - support' }
PetsRESTfulControllerTest >> requestToUpdatePetIdentifiedBy: anIdentifier nameTo: aName using: anETag unlessMatching: theETagsNotToMatch [

  ^ TeaRequest
      fromZnRequest: ( ( ZnRequest patch: ( self urlForResourceIdentifiedBy: anIdentifier ) )
            setAccept: self defaultPetMediaType;
            setIfMatchTo: anETag;
            setIfNoneMatchTo: theETagsNotToMatch;
            entity:
              ( ZnEntity
                  with: ( '{"name":"<1s>"}' expandMacrosWith: aName )
                  type: self defaultPetMediaType );
            yourself )
      pathParams: ( self parametersWith: anIdentifier )
]

{ #category : 'private - support' }
PetsRESTfulControllerTest >> requestToUpdatePetIdentifiedBy: anIdentifier statusTo: aStatus [

	^ self
		requestToPATCHResourceIdentifiedBy: anIdentifier
		with: ( '{"status":"<1s>"}' expandMacrosWith: aStatus )
		accepting: self defaultPetMediaType
		conditionalTo: ( self entityTagOfPetIdentifiedBy: anIdentifier )
]

{ #category : 'running' }
PetsRESTfulControllerTest >> setUp [

	petRepository := InMemoryPetRepository new.
	super setUp.
	self assert: petRepository findAll isEmpty
]

{ #category : 'running' }
PetsRESTfulControllerTest >> setUpResourceController [

	resourceController := PetsRESTfulController persistingTo: petRepository
]

{ #category : 'tests - delete' }
PetsRESTfulControllerTest >> testCantDeleteInvalidPet [

	self
		should: [ resourceController deletePetBasedOn: (self requestToDELETEResourceIdentifiedBy: 1) within: self newHttpRequestContext ]
		raise: HTTPClientError
		withExceptionDo: [ :signal | self assert: signal code equals: 404 ]
]

{ #category : 'tests - get individual' }
PetsRESTfulControllerTest >> testCantGetPetSpecifyingLanguageRange [

	self
		assert: ( resourceController
				  createPetBasedOn: ( self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}' )
				  within: self newHttpRequestContext ) isSuccess;
		assert: petRepository count equals: 1.

	self
		should: [ 
			resourceController
				getPetBasedOn: ( self
						  requestToGETResourceIdentifiedBy: 1
						  acceptingContentMatching: self defaultPetMediaType
						  inAnyOf: '*' )
				within: self newHttpRequestContext
			]
		raise: HTTPNotAcceptable
		withExceptionDo: [ :error | 
			self
				assert: error messageText
				equals: 'Cannot generate a response entity with acceptable characteristics.';
				assert: error code equals: 406;
				assert: error allowedLanguageTags isEmpty
			]
]

{ #category : 'tests - get individual' }
PetsRESTfulControllerTest >> testCantGetPetWhenEveryMediaTypeIsExcluded [

	self
		assert: ( resourceController
				  createPetBasedOn: ( self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}' )
				  within: self newHttpRequestContext ) isSuccess;
		assert: petRepository count equals: 1.

	self
		should: [
			resourceController
				getPetBasedOn: ( self requestToGETResourceIdentifiedBy: 1 accepting: 'application/json;q=0, */*' )
				within: self newHttpRequestContext
			]
		raise: HTTPNotAcceptable
		withExceptionDo: [ :error |
			self
				assert: error messageText
				equals: 'Cannot generate a response entity with acceptable characteristics.';
				assert: error code equals: 406
			]
]

{ #category : 'tests - update' }
PetsRESTfulControllerTest >> testCantUpdatePetIfMissingETag [

	self
		createPet;
		should: [ resourceController updatePetBasedOn: (self requestMissingIfMatchHeaderToUpdatePetIdentifiedBy: 1 nameTo: 'Mendieta') within: self newHttpRequestContext ]
			raise: HTTPClientError
			withExceptionDo: [ :error | self assert: error code equals: 428 ]
]

{ #category : 'tests - update' }
PetsRESTfulControllerTest >> testCantUpdatePetNameWhenEmpty [

	self
		createPet;
		assert: petRepository findAll first name equals: 'Firulais'.

	self
		should: [ 
			resourceController
				updatePetBasedOn: ( self requestToUpdatePetIdentifiedBy: 1 nameTo: '' )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError unprocessableEntity
]

{ #category : 'tests - update' }
PetsRESTfulControllerTest >> testCantUpdatePetWhenETagDoesNotMatch [

	self
		createPet;
		should: [ resourceController updatePetBasedOn: (self requestToUpdatePetIdentifiedBy: 1 nameTo: 'Mendieta' using: '"Frula"') within: self newHttpRequestContext ]
			raise: HTTPClientError
			withExceptionDo: [ :error | self assert: error code equals: 412 ]
]

{ #category : 'tests - update' }
PetsRESTfulControllerTest >> testCantUpdatePetWhenETagIsWeak [

  | entityTag |
  self createPet.
  entityTag := self entityTagOfPetIdentifiedBy: 1.

  self
    should: [
        resourceController
          updatePetBasedOn: ( self
                requestToUpdatePetIdentifiedBy: 1
                nameTo: 'Mendieta'
                using: ( EntityTag weakWith: entityTag value ) )
          within: self newHttpRequestContext
      ]
    raise: HTTPClientError
    withExceptionDo: [ :error | self assert: error code equals: 412 ].
  self assert: petRepository findAll first name equals: 'Firulais'
]

{ #category : 'tests - update' }
PetsRESTfulControllerTest >> testCantUpdatePetWhenIfNoneMatchIsWildcard [

  | entityTag |
  self createPet.
  entityTag := self entityTagOfPetIdentifiedBy: 1.

  self
    should: [
        resourceController
          updatePetBasedOn: ( self
                requestToUpdatePetIdentifiedBy: 1
                nameTo: 'Mendieta'
                using: entityTag
                unlessMatching: EntityTagList wildcard )
          within: self newHttpRequestContext
      ]
    raise: HTTPClientError
    withExceptionDo: [ :error | self assert: error code equals: 412 ].
  self assert: petRepository findAll first name equals: 'Firulais'
]

{ #category : 'tests - update' }
PetsRESTfulControllerTest >> testCantUpdatePetWhenIfNoneMatchMatches [

  | entityTag |
  self createPet.
  entityTag := self entityTagOfPetIdentifiedBy: 1.

  self
    should: [
        resourceController
          updatePetBasedOn: ( self
                requestToUpdatePetIdentifiedBy: 1
                nameTo: 'Mendieta'
                using: entityTag
                unlessMatching: entityTag )
          within: self newHttpRequestContext
      ]
    raise: HTTPClientError
    withExceptionDo: [ :error | self assert: error code equals: 412 ].
  self assert: petRepository findAll first name equals: 'Firulais'
]

{ #category : 'tests - update' }
PetsRESTfulControllerTest >> testCantUpdatePetWhenIfNoneMatchMatchesWeakly [

  | entityTag |
  self createPet.
  entityTag := self entityTagOfPetIdentifiedBy: 1.

  self
    should: [
        resourceController
          updatePetBasedOn: ( self
                requestToUpdatePetIdentifiedBy: 1
                nameTo: 'Mendieta'
                using: entityTag
                unlessMatching: ( EntityTag weakWith: entityTag value ) )
          within: self newHttpRequestContext
      ]
    raise: HTTPClientError
    withExceptionDo: [ :error | self assert: error code equals: 412 ].
  self assert: petRepository findAll first name equals: 'Firulais'
]

{ #category : 'tests - update' }
PetsRESTfulControllerTest >> testCantUpdatePetWhenNoETagInTheListMatches [

  | entityTag |
  self createPet.
  entityTag := self entityTagOfPetIdentifiedBy: 1.

  self
    should: [
        resourceController
          updatePetBasedOn: ( self
                requestToUpdatePetIdentifiedBy: 1
                nameTo: 'Mendieta'
                using:
                ( EntityTagList withAll: { '"Frula"' . EntityTag weakWith: entityTag value } ) )
          within: self newHttpRequestContext
      ]
    raise: HTTPClientError
    withExceptionDo: [ :error | self assert: error code equals: 412 ].
  self assert: petRepository findAll first name equals: 'Firulais'
]

{ #category : 'tests - get collection' }
PetsRESTfulControllerTest >> testComplexPagination [

	| response |

	self createSixPets "Get the 1st page".
	response := resourceController
		            getPetsBasedOn: ( self
				              requestToGET: 'https://pets.example.com/pets?limit=2'
				              accepting: resourceController petSummaryVersion1dot0dot0MediaType )
		            within: self newHttpRequestContext.
	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: resourceController petSummaryVersion1dot0dot0MediaType;
		assert: response links size equals: 2;
		assertUrl: response links first url equals: 'https://pets.example.com/pets?start=3&limit=2';
		assert: response links first relationType equals: 'next';
		assertUrl: response links second url equals: 'https://pets.example.com/pets?start=5&limit=2';
		assert: response links second relationType equals: 'last'.
	self withJsonFromContentsIn: response do: [ :json | 
		self
			assertUrl: json selfLocation equals: 'https://pets.example.com/pets?limit=2';
			assertUrl: json links next equals: 'https://pets.example.com/pets?start=3&limit=2';
			assertUrl: json links last equals: 'https://pets.example.com/pets?start=5&limit=2';
			assert: json items size equals: 2
		] "Get the 2nd page".
	response := resourceController
		            getPetsBasedOn: ( self
				              requestToGET: 'https://pets.example.com/pets?start=3&limit=2'
				              accepting: resourceController petSummaryVersion1dot0dot0MediaType )
		            within: self newHttpRequestContext.
	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: resourceController petSummaryVersion1dot0dot0MediaType;
		assert: response links size equals: 4;
		assertUrl: response links first url equals: 'https://pets.example.com/pets?start=1&limit=2';
		assert: response links first relationType equals: 'first';
		assertUrl: response links second url equals: 'https://pets.example.com/pets?start=1&limit=2';
		assert: response links second relationType equals: 'prev';
		assertUrl: response links third url equals: 'https://pets.example.com/pets?start=5&limit=2';
		assert: response links third relationType equals: 'next';
		assertUrl: response links last url equals: 'https://pets.example.com/pets?start=5&limit=2';
		assert: response links last relationType equals: 'last'.
	self withJsonFromContentsIn: response do: [ :json | 
		self
			assertUrl: json selfLocation asZnUrl equals: 'https://pets.example.com/pets?start=3&limit=2';
			assertUrl: json links first asZnUrl equals: 'https://pets.example.com/pets?start=1&limit=2';
			assertUrl: json links prev asZnUrl equals: 'https://pets.example.com/pets?start=1&limit=2';
			assertUrl: json links next asZnUrl equals: 'https://pets.example.com/pets?start=5&limit=2';
			assertUrl: json links last asZnUrl equals: 'https://pets.example.com/pets?start=5&limit=2';
			assert: json items size equals: 2
		]
]

{ #category : 'tests - delete' }
PetsRESTfulControllerTest >> testDeletePet [

	| response |

	self createPet.

	response := resourceController deletePetBasedOn: (self requestToDELETEResourceIdentifiedBy: 1) within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 204;
		deny: response hasEntity
]

{ #category : 'tests - get individual' }
PetsRESTfulControllerTest >> testGetNotModifiedKeepsCachingFields [

  | response notModifiedResponse |
  self createPet.
  response := resourceController
                getPetBasedOn:
                ( self requestToGETResourceIdentifiedBy: 1 accepting: self defaultPetMediaType )
                within: self newHttpRequestContext.

  notModifiedResponse := resourceController
                           getPetBasedOn: ( self
                                 requestToGETResourceIdentifiedBy: 1
                                 accepting: self defaultPetMediaType
                                 conditionalTo: response entityTag )
                           within: self newHttpRequestContext.

  self
    assert: notModifiedResponse code equals: 304;
    deny: notModifiedResponse headers hasContentType;
    assert: notModifiedResponse cachingDirectives equals: response cachingDirectives.
  self
    assertCachingDirectivesFor: notModifiedResponse
    with: #( 'public' 'no-transform' 'must-revalidate' ).
  self assertExpiresHeaderFor: notModifiedResponse with: 4 hours
]

{ #category : 'tests - get individual' }
PetsRESTfulControllerTest >> testGetNotModifiedWhenAnyETagInTheListMatches [

  | response |
  self createPet.

  response := resourceController
                getPetBasedOn: ( self
                      requestToGETResourceIdentifiedBy: 1
                      accepting: self defaultPetMediaType
                      conditionalTo:
                      ( EntityTagList fromString:
                          '"Frula", W/"c051344b8c92c5ed8a2bd0752070c35ed3de3bab"' ) )
                within: self newHttpRequestContext.

  self
    assert: response code equals: 304;
    assert: ( response headers at: 'ETag' ) equals: '"c051344b8c92c5ed8a2bd0752070c35ed3de3bab"'
]

{ #category : 'tests - get individual' }
PetsRESTfulControllerTest >> testGetNotModifiedWhenIfNoneMatchIsRepeated [

  | response |
  self createPet.

  response := resourceController
                getPetBasedOn: ( self requestToGETResourceIdentifiedBy: 1 applying: [ :request |
                        request setAccept: self defaultPetMediaType.
                        request headers
                          at: 'If-None-Match' add: '"Frula"';
                          at: 'If-None-Match' add: '"c051344b8c92c5ed8a2bd0752070c35ed3de3bab"'
                      ] )
                within: self newHttpRequestContext.

  self
    assert: response code equals: 304;
    assert: ( response headers at: 'ETag' ) equals: '"c051344b8c92c5ed8a2bd0752070c35ed3de3bab"'
]

{ #category : 'tests - get individual' }
PetsRESTfulControllerTest >> testGetNotModifiedWhenIfNoneMatchIsWildcard [

  | response |
  self createPet.

  response := resourceController
                getPetBasedOn: ( self
                      requestToGETResourceIdentifiedBy: 1
                      accepting: self defaultPetMediaType
                      conditionalTo: EntityTagList wildcard )
                within: self newHttpRequestContext.

  self
    assert: response code equals: 304;
    assert: ( response headers at: 'ETag' ) equals: '"c051344b8c92c5ed8a2bd0752070c35ed3de3bab"'
]

{ #category : 'tests - get individual' }
PetsRESTfulControllerTest >> testGetNotModifiedWhenValidETag [

	| response |

	self createPet.

	response := resourceController
		            getPetBasedOn:
		            ( self requestToGETResourceIdentifiedBy: 1 accepting: self defaultPetMediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response entityTag equals: '"c051344b8c92c5ed8a2bd0752070c35ed3de3bab"' asEntityTag.

	response := resourceController
		            getPetBasedOn: ( self
				              requestToGETResourceIdentifiedBy: 1
				              accepting: self defaultPetMediaType
				              conditionalTo: '"c051344b8c92c5ed8a2bd0752070c35ed3de3bab"' asEntityTag )
		            within: self newHttpRequestContext.

	self
		assert: response code equals: 304;
		assert: response entityTag equals: '"c051344b8c92c5ed8a2bd0752070c35ed3de3bab"' asEntityTag
]

{ #category : 'tests - get individual' }
PetsRESTfulControllerTest >> testGetNotModifiedWhenWeakETagMatches [

  | response |
  self createPet.

  response := resourceController
                getPetBasedOn: ( self
                      requestToGETResourceIdentifiedBy: 1
                      accepting: self defaultPetMediaType
                      conditionalTo:
                      ( EntityTag weakWith: 'c051344b8c92c5ed8a2bd0752070c35ed3de3bab' ) )
                within: self newHttpRequestContext.

  self
    assert: response code equals: 304;
    assert: ( response headers at: 'ETag' ) equals: '"c051344b8c92c5ed8a2bd0752070c35ed3de3bab"'
]

{ #category : 'tests - get individual' }
PetsRESTfulControllerTest >> testGetPetJustCreated [

	| response |

	self
		assert: ( resourceController
				  createPetBasedOn: ( self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}' )
				  within: self newHttpRequestContext ) isSuccess;
		assert: petRepository count equals: 1.

	response := resourceController
		            getPetBasedOn:
		            ( self requestToGETResourceIdentifiedBy: 1 accepting: self defaultPetMediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType equals: self defaultPetMediaType;
		assert: response entityTag equals: '"c051344b8c92c5ed8a2bd0752070c35ed3de3bab"' asEntityTag.
	self assertExpiresHeaderFor: response with: 4 hours.
	self assertCachingDirectivesFor: response with: #( 'public' 'no-transform' 'must-revalidate' ).

	self withJsonFromContentsIn: response do: [ :json | 
		self
			assert: json name equals: 'Firulais';
			assert: json type equals: 'dog';
			assert: json status equals: 'new';
			assertUrl: json selfLocation equals: 'https://pets.example.com/pets/1'
		]
]

{ #category : 'tests - get individual' }
PetsRESTfulControllerTest >> testGetPetJustCreatedWhenNoAcceptHeaderPresentInRequest [

	| getRequest response |

	self
		assert: ( resourceController
				  createPetBasedOn: ( self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}' )
				  within: self newHttpRequestContext ) isSuccess;
		assert: petRepository count equals: 1.

	getRequest := ZnRequest get: ( self urlForResourceIdentifiedBy: 1 ).
	getRequest headers removeKey: 'Accept'.

	response := resourceController
		            getPetBasedOn:
		            ( TeaRequest fromZnRequest: getRequest pathParams: ( self parametersWith: 1 ) )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: self defaultPetMediaType
		or: resourceController petSummaryVersion1dot0dot0MediaType;
		assert: response entityTag
		equals: '"c051344b8c92c5ed8a2bd0752070c35ed3de3bab"' asEntityTag
		or: '"1323cdfb8bb0f9011fbd480c5a87c17d05883214"' asEntityTag.

	self withJsonFromContentsIn: response do: [ :json |
		self
			assert: json name equals: 'Firulais';
			assertUrl: json selfLocation equals: 'https://pets.example.com/pets/1'
		]
]

{ #category : 'tests - get individual' }
PetsRESTfulControllerTest >> testGetPetNotFoundShouldFail [

	self
		should: [ resourceController
				getPetBasedOn: ( self requestToGETResourceIdentifiedBy: 1 accepting: '*/*' )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError
		withExceptionDo: [ :error | self assert: error code equals: 404 ]
]

{ #category : 'tests - get individual' }
PetsRESTfulControllerTest >> testGetPetSummaryJustCreated [

	| response |

	self
		assert: ( resourceController
				  createPetBasedOn: ( self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}' )
				  within: self newHttpRequestContext ) isSuccess;
		assert: petRepository count equals: 1.

	response := resourceController
		            getPetBasedOn: ( self
				              requestToGETResourceIdentifiedBy: 1
				              accepting: resourceController petSummaryVersion1dot0dot0MediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: resourceController petSummaryVersion1dot0dot0MediaType;
		assert: response entityTag equals: '"1323cdfb8bb0f9011fbd480c5a87c17d05883214"' asEntityTag.
	self assertExpiresHeaderFor: response with: 4 hours.
	self assertCachingDirectivesFor: response with: #('public').

	self withJsonFromContentsIn: response do: [ :json | 
		self
			assert: json name equals: 'Firulais';
			assertUrl: json selfLocation equals: 'https://pets.example.com/pets/1';
			assert: json type isNil;
			assert: json status isNil
		]
]

{ #category : 'tests - get individual' }
PetsRESTfulControllerTest >> testGetPetWhenNoETagInTheListMatches [

  | response |
  self createPet.

  response := resourceController
                getPetBasedOn: ( self
                      requestToGETResourceIdentifiedBy: 1
                      accepting: self defaultPetMediaType
                      conditionalTo: ( EntityTagList fromString: '"Frula", "Firulais"' ) )
                within: self newHttpRequestContext.

  self
    assert: response status equals: 200;
    assert: response hasEntity
]

{ #category : 'tests - get collection' }
PetsRESTfulControllerTest >> testGetPets [

	| response |

	response := resourceController
		getPetsBasedOn: ( self requestToGetPetsAccepting: resourceController petSummaryVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
			equals: resourceController petSummaryVersion1dot0dot0MediaType.
	self assertExpiresHeaderFor: response with: 4 hours.
	self assertCachingDirectivesFor: response with: #('public').

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json items isEmpty;
				assertUrl: json selfLocation equals: 'https://pets.example.com/pets'
			]
]

{ #category : 'tests - get collection' }
PetsRESTfulControllerTest >> testGetPetsAnswersEntityTag [

  | response |
  self createSixPets.

  response := self getPetsAt: 'https://pets.example.com/pets'.

  self
    assert: response status equals: 200;
    assert: response entityTag isStrong
]

{ #category : 'tests - get collection' }
PetsRESTfulControllerTest >> testGetPetsEntityTagChangesWithTheCollection [

  | entityTag |
  self createPet.
  entityTag := ( self getPetsAt: 'https://pets.example.com/pets' ) entityTag.

  resourceController
    createPetBasedOn: ( self requestToCreatePetFrom: '{"name":"Mendieta","type":"dog"}' )
    within: self newHttpRequestContext.

  self deny:
    ( ( self getPetsAt: 'https://pets.example.com/pets' ) entityTag matchesWeakly: entityTag )
]

{ #category : 'tests - get collection' }
PetsRESTfulControllerTest >> testGetPetsEntityTagChangesWithThePage [

  | firstPageEntityTag secondPageEntityTag |
  self createSixPets.

  firstPageEntityTag := ( self getPetsAt: 'https://pets.example.com/pets?start=1&limit=2' )
                          entityTag.
  secondPageEntityTag := ( self getPetsAt: 'https://pets.example.com/pets?start=3&limit=2' )
                           entityTag.

  self deny: ( firstPageEntityTag matchesWeakly: secondPageEntityTag )
]

{ #category : 'tests - get collection' }
PetsRESTfulControllerTest >> testGetPetsNotEmpty [

	| response |

	resourceController
		createPetBasedOn: ( self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}' )
		within: self newHttpRequestContext.

	self assert: petRepository findAll notEmpty.

	response := resourceController
		getPetsBasedOn: ( self requestToGetPetsAccepting: resourceController petSummaryVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
			equals: resourceController petSummaryVersion1dot0dot0MediaType.
	self assertExpiresHeaderFor: response with: 4 hours.
	self assertCachingDirectivesFor: response with: #('public').

	self
		withJsonFromContentsIn: response
			do: [ :json | self assertUrl: json selfLocation equals: 'https://pets.example.com/pets' ];
		withJsonFromItemsIn: response
			do: [ :items | 
			self
				withTheOnlyOneIn: items
				do: [ :dogSummary | 
					self
						assert: dogSummary name equals: 'Firulais';
						assertUrl: dogSummary selfLocation equals: 'https://pets.example.com/pets/1';
						assert: dogSummary type isNil
					]
			]
]

{ #category : 'tests - get collection' }
PetsRESTfulControllerTest >> testGetPetsNotEmptyAcceptingCompleteMediaType [

	| response |

	resourceController
		createPetBasedOn: ( self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}' )
		within: self newHttpRequestContext.

	self assert: petRepository findAll notEmpty.

	response := resourceController
		getPetsBasedOn: ( self requestToGetPetsAccepting: resourceController petVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType 
			equals: resourceController petVersion1dot0dot0MediaType.
	self assertExpiresHeaderFor: response with: 4 hours.
	self assertCachingDirectivesFor: response with: #('public' 'no-transform' 'must-revalidate').

	self
		withJsonFromContentsIn: response
			do: [ :json | self assertUrl: json selfLocation equals: 'https://pets.example.com/pets' ];
		withJsonFromItemsIn: response
			do: [ :items | 
			self
				withTheOnlyOneIn: items
				do: [ :dogSummary | 
					self
						assert: dogSummary name equals: 'Firulais';
						assertUrl: dogSummary selfLocation equals: 'https://pets.example.com/pets/1';
						assert: dogSummary type equals: 'dog'.
					]
			]
]

{ #category : 'tests - get collection' }
PetsRESTfulControllerTest >> testGetPetsNotModifiedKeepsCachingFields [

  | response notModifiedResponse |
  self createSixPets.
  response := self getPetsAt: 'https://pets.example.com/pets?start=3&limit=2'.

  notModifiedResponse := self
                           getPetsAt: 'https://pets.example.com/pets?start=3&limit=2'
                           conditionalTo: response entityTag.

  self
    assert: notModifiedResponse code equals: 304;
    deny: notModifiedResponse headers hasContentType;
    assert: notModifiedResponse cachingDirectives equals: response cachingDirectives.
  self assertCachingDirectivesFor: notModifiedResponse with: #( 'public' ).
  self assertExpiresHeaderFor: notModifiedResponse with: 4 hours
]

{ #category : 'tests - get collection' }
PetsRESTfulControllerTest >> testGetPetsNotModifiedWhenETagMatches [

  | response notModifiedResponse |
  self createSixPets.
  response := self getPetsAt: 'https://pets.example.com/pets?limit=2'.

  notModifiedResponse := self
                           getPetsAt: 'https://pets.example.com/pets?limit=2'
                           conditionalTo: response entityTag.

  self
    assert: notModifiedResponse code equals: 304;
    deny: notModifiedResponse hasEntity;
    assert: notModifiedResponse entityTag equals: response entityTag;
    assert: notModifiedResponse varyHeaderNames equals: response varyHeaderNames;
    assert: notModifiedResponse links size equals: 2;
    assert: ( notModifiedResponse links collect: [ :link | link asString ] )
    equals: ( response links collect: [ :link | link asString ] )
]

{ #category : 'tests - get collection' }
PetsRESTfulControllerTest >> testGetPetsNotModifiedWhenIfNoneMatchIsWildcard [

  | response |
  self createSixPets.

  response := self getPetsAt: 'https://pets.example.com/pets' conditionalTo: EntityTagList wildcard.

  self
    assert: response code equals: 304;
    assert: response entityTag isStrong
]

{ #category : 'tests - get collection' }
PetsRESTfulControllerTest >> testGetPetsNotModifiedWhenWeakETagMatches [

  | entityTag response |
  self createSixPets.
  entityTag := ( self getPetsAt: 'https://pets.example.com/pets' ) entityTag.

  response := self
                getPetsAt: 'https://pets.example.com/pets'
                conditionalTo: ( EntityTag weakWith: entityTag value ).

  self
    assert: response code equals: 304;
    assert: response entityTag equals: entityTag
]

{ #category : 'tests - get individual' }
PetsRESTfulControllerTest >> testGetPetsVaryByAcceptLanguageWithoutOfferingLanguages [

  | pet pets |
  self assert: ( resourceController
        createPetBasedOn: ( self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}' )
        within: self newHttpRequestContext ) isSuccess.

  pet := resourceController
           getPetBasedOn:
           ( self requestToGETResourceIdentifiedBy: 1 accepting: self defaultPetMediaType )
           within: self newHttpRequestContext.
  pets := resourceController
            getPetsBasedOn:
            ( self requestToGetPetsAccepting: resourceController petSummaryVersion1dot0dot0MediaType )
            within: self newHttpRequestContext.

  { pet . pets } do: [ :response |
      self
        assert: response isSuccess;
        assert: response contentLanguageTags isEmpty;
        assert: response varyHeaderNames includes: 'Accept-Language';
        assert: response varyHeaderNames includes: 'Accept'
    ]
]

{ #category : 'tests - get collection' }
PetsRESTfulControllerTest >> testGetPetsWhenETagDoesNotMatch [

  | response |
  self createSixPets.

  response := self getPetsAt: 'https://pets.example.com/pets' conditionalTo: '"Frula"'.

  self
    assert: response status equals: 200;
    assert: response hasEntity;
    assert: response entityTag isStrong
]

{ #category : 'tests - get collection' }
PetsRESTfulControllerTest >> testGetPetsWithPagination [

	| response |

	self createSixPets.

	response := resourceController
		            getPetsBasedOn:
		            ( self requestToGetPetsAccepting:
			              resourceController petSummaryVersion1dot0dot0MediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: resourceController petSummaryVersion1dot0dot0MediaType;
		assert: response links size equals: 2;
		assertUrl: response links first url equals: 'https://pets.example.com/pets?start=6&limit=5';
		assert: response links first relationType equals: 'next';
		assertUrl: response links second url equals: 'https://pets.example.com/pets?start=6&limit=5';
		assert: response links second relationType equals: 'last'.

	self withJsonFromContentsIn: response do: [ :json | 
		self
			assertUrl: json selfLocation equals: 'https://pets.example.com/pets';
			assertUrl: json links next equals: 'https://pets.example.com/pets?start=6&limit=5';
			assertUrl: json links last equals: 'https://pets.example.com/pets?start=6&limit=5';
			assert: json items size equals: 5.

		response := resourceController
			            getPetsBasedOn:
			            ( self requestToGET: json links next accepting: response contentType )
			            within: self newHttpRequestContext.
		self
			assert: response isSuccess;
			assert: response status equals: 200;
			assert: response contentType asMediaType
			equals: resourceController petSummaryVersion1dot0dot0MediaType;
			assert: response links size equals: 2;
			assertUrl: response links first url equals: 'https://pets.example.com/pets?start=1&limit=5';
			assert: response links first relationType equals: 'first';
			assertUrl: response links second url equals: 'https://pets.example.com/pets?start=1&limit=5';
			assert: response links second relationType equals: 'prev'.
		self withJsonFromContentsIn: response do: [ :json2 | 
			self
				assertUrl: json2 selfLocation equals: 'https://pets.example.com/pets?start=6&limit=5';
				assertUrl: json2 links first equals: 'https://pets.example.com/pets?start=1&limit=5';
				assertUrl: json2 links prev equals: 'https://pets.example.com/pets?start=1&limit=5';
				assert: json2 links next isNil;
				assert: json2 links last isNil;
				assert: json2 items size equals: 1
			]
		]
]

{ #category : 'tests - update' }
PetsRESTfulControllerTest >> testInvalidETagFormatMustRaiseBadRequest [

  self
    createPet;
    should: [
        | request |
        request := self requestToUpdatePetIdentifiedBy: 1 nameTo: 'Mendieta' using: 'invalid'.
        resourceController updatePetBasedOn: request within: self newHttpRequestContext
      ]
    raise: HTTPClientError badRequest
]

{ #category : 'tests - update' }
PetsRESTfulControllerTest >> testInvalidETagListMustRaiseBadRequest [

  self
    createPet;
    should: [
        resourceController
          updatePetBasedOn:
            ( self requestToUpdatePetIdentifiedBy: 1 nameTo: 'Mendieta' using: '*, "Frula"' )
          within: self newHttpRequestContext
      ]
    raise: HTTPClientError badRequest
]

{ #category : 'tests - get individual' }
PetsRESTfulControllerTest >> testInvalidIfNoneMatchMustRaiseBadRequest [

  self
    createPet;
    should: [
        resourceController
          getPetBasedOn: ( self
                requestToGETResourceIdentifiedBy: 1
                accepting: self defaultPetMediaType
                conditionalTo: '"Frula" "Firulais"' )
          within: self newHttpRequestContext
      ]
    raise: HTTPClientError badRequest
]

{ #category : 'tests - get collection' }
PetsRESTfulControllerTest >> testInvalidIfNoneMatchOnCollectionMustRaiseBadRequest [

  self
    createSixPets;
    should: [ self getPetsAt: 'https://pets.example.com/pets' conditionalTo: '"Frula" "Firulais"' ]
    raise: HTTPClientError badRequest
]

{ #category : 'tests - update' }
PetsRESTfulControllerTest >> testInvalidIfNoneMatchOnUpdateMustRaiseBadRequest [

  | entityTag |
  self createPet.
  entityTag := self entityTagOfPetIdentifiedBy: 1.

  self
    should: [
        resourceController
          updatePetBasedOn: ( self
                requestToUpdatePetIdentifiedBy: 1
                nameTo: 'Mendieta'
                using: entityTag
                unlessMatching: '"Frula" "Firulais"' )
          within: self newHttpRequestContext
      ]
    raise: HTTPClientError badRequest.
  self assert: petRepository findAll first name equals: 'Firulais'
]

{ #category : 'tests - get collection' }
PetsRESTfulControllerTest >> testPaginationLinksUseServerlUrl [

	| response |

	resourceController serverUrl: 'https://pets.example.com/beta' asZnUrl.
	self createSixPets.

	response := resourceController
		            getPetsBasedOn: ( self
				              requestToGET: 'https://pets.example.com/pets' asZnUrl
				              accepting: resourceController petSummaryVersion1dot0dot0MediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: resourceController petSummaryVersion1dot0dot0MediaType;
		assert: response links size equals: 2;
		assertUrl: response links first url equals: 'https://pets.example.com/beta/pets?start=6&limit=5';
		assert: response links first relationType equals: 'next';
		assertUrl: response links second url equals: 'https://pets.example.com/beta/pets?start=6&limit=5';
		assert: response links second relationType equals: 'last'.

	self withJsonFromContentsIn: response do: [ :json |
			self
				assertUrl: json selfLocation equals: 'https://pets.example.com/beta/pets';
				assertUrl: json links next equals: 'https://pets.example.com/beta/pets?start=6&limit=5';
				assertUrl: json links last equals: 'https://pets.example.com/beta/pets?start=6&limit=5';
				assert: json items size equals: 5.

			response := resourceController
				            getPetsBasedOn:
				            ( self requestToGET: 'https://pets.example.com/pets?start=6&limit=5' accepting: response contentType )
				            within: self newHttpRequestContext.
			self
				assert: response isSuccess;
				assert: response status equals: 200;
				assert: response contentType asMediaType
				equals: resourceController petSummaryVersion1dot0dot0MediaType;
				assert: response links size equals: 2;
				assertUrl: response links first url
				equals: 'https://pets.example.com/beta/pets?start=1&limit=5';
				assert: response links first relationType equals: 'first';
				assertUrl: response links second url
				equals: 'https://pets.example.com/beta/pets?start=1&limit=5';
				assert: response links second relationType equals: 'prev'.
			self withJsonFromContentsIn: response do: [ :json2 |
					self
						assertUrl: json2 selfLocation equals: 'https://pets.example.com/beta/pets?start=6&limit=5';
						assertUrl: json2 links first equals: 'https://pets.example.com/beta/pets?start=1&limit=5';
						assertUrl: json2 links prev equals: 'https://pets.example.com/beta/pets?start=1&limit=5';
						assert: json2 links next isNil;
						assert: json2 links last isNil;
						assert: json2 items size equals: 1
				]
		]
]

{ #category : 'tests - creation' }
PetsRESTfulControllerTest >> testPetCreation [

	| response request |

	request := self requestToCreatePetFrom: '{"name":"Firulais","type":"dog"}'.
	request setAccept: resourceController petVersion1dot0dot0MediaType.

	response := resourceController createPetBasedOn: request within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 201;
		assertUrl: response location equals: 'https://pets.example.com/pets/1';
		assert: response hasEntity;
		assert: response contentType equals: resourceController petVersion1dot0dot0MediaType;
		assert: petRepository count equals: 1;
		assert: petRepository findAll first name equals: 'Firulais'
]

{ #category : 'tests - creation' }
PetsRESTfulControllerTest >> testPetCreationWhenNoAcceptHeaderPresentInRequest [

	| request response |

	request := ( ZnRequest post: self resourceUrl )
		entity: ( ZnEntity with: '{"name":"Firulais","type":"dog"}' type: self defaultPetMediaType );
		yourself.
	request headers removeKey: 'Accept'.

	response := resourceController
		createPetBasedOn: ( TeaRequest fromZnRequest: request )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 201;
		assertUrl: response location equals: 'https://pets.example.com/pets/1';
		assert: response hasEntity;
		assert: response contentType equals: ZnMimeType textPlain;
		assert: response contents trimBoth equals: 'Created https://pets.example.com/pets/1';
		assert: petRepository count equals: 1;
		assert: petRepository findAll first name equals: 'Firulais'
]

{ #category : 'tests' }
PetsRESTfulControllerTest >> testTemplate [

	self assert: resourceController identifierTemplate equals: '/pets/<identifier:IsInteger>'
]

{ #category : 'tests - update' }
PetsRESTfulControllerTest >> testUpdatePetName [

	| response |

	self
		createPet;
		assert: petRepository findAll first name equals: 'Firulais'.

	response := resourceController updatePetBasedOn: (self requestToUpdatePetIdentifiedBy: 1 nameTo: 'Mendieta') within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response hasEntity;
		assert: petRepository count equals: 1;
		assert: petRepository findAll first name equals: 'Mendieta';
		assert: petRepository findAll first status equals: 'new';
		withJsonFromContentsIn: response
			do: [ :json | 
			self
				assert: json name equals: 'Mendieta';
				assert: json type equals: 'dog';
				assert: json status equals: 'new';
				assertUrl: json selfLocation equals: 'https://pets.example.com/pets/1' ]
]

{ #category : 'tests - update' }
PetsRESTfulControllerTest >> testUpdatePetStatus [

	| response |

	self
		createPet;
		assert: petRepository findAll first status equals: 'new'.

	response := resourceController updatePetBasedOn: (self requestToUpdatePetIdentifiedBy: 1 statusTo: 'gone') within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response hasEntity;
		assert: petRepository count equals: 1;
		assert: petRepository findAll first name equals: 'Firulais';
		assert: petRepository findAll first status equals: 'gone';
		withJsonFromContentsIn: response
			do: [ :json | 
			self
				assert: json name equals: 'Firulais';
				assert: json type equals: 'dog';
				assert: json status equals: 'gone';
				assertUrl: json selfLocation equals: 'https://pets.example.com/pets/1' ]
]

{ #category : 'tests - update' }
PetsRESTfulControllerTest >> testUpdatePetWhenAnyETagInTheListMatches [

  | entityTag response |
  self createPet.
  entityTag := self entityTagOfPetIdentifiedBy: 1.

  response := resourceController
                updatePetBasedOn: ( self
                      requestToUpdatePetIdentifiedBy: 1
                      nameTo: 'Mendieta'
                      using: ( EntityTagList withAll: { '"Frula"' . entityTag } ) )
                within: self newHttpRequestContext.

  self
    assert: response status equals: 200;
    assert: petRepository findAll first name equals: 'Mendieta'
]

{ #category : 'tests - update' }
PetsRESTfulControllerTest >> testUpdatePetWhenIfMatchIsRepeated [

  | entityTag response |
  self createPet.
  entityTag := self entityTagOfPetIdentifiedBy: 1.

  response := resourceController
                updatePetBasedOn: ( self
                      requestToUpdatePetIdentifiedBy: 1
                      nameTo: 'Mendieta'
                      repeatingIfMatchWith: { '"Frula"' . entityTag asString } )
                within: self newHttpRequestContext.

  self
    assert: response status equals: 200;
    assert: petRepository findAll first name equals: 'Mendieta'
]

{ #category : 'tests - update' }
PetsRESTfulControllerTest >> testUpdatePetWhenIfMatchIsWildcard [

  | response |
  self createPet.

  response := resourceController
                updatePetBasedOn:
                ( self requestToUpdatePetIdentifiedBy: 1 nameTo: 'Mendieta' using: '*' )
                within: self newHttpRequestContext.

  self
    assert: response status equals: 200;
    assert: petRepository findAll first name equals: 'Mendieta'
]

{ #category : 'tests - update' }
PetsRESTfulControllerTest >> testUpdatePetWhenIfNoneMatchDoesNotMatch [

  | entityTag response |
  self createPet.
  entityTag := self entityTagOfPetIdentifiedBy: 1.

  response := resourceController
                updatePetBasedOn: ( self
                      requestToUpdatePetIdentifiedBy: 1
                      nameTo: 'Mendieta'
                      using: entityTag
                      unlessMatching: '"Frula"' )
                within: self newHttpRequestContext.

  self
    assert: response status equals: 200;
    assert: response hasEntity;
    deny: response entityTag equals: entityTag;
    assert: response entityTag equals: ( self entityTagOfPetIdentifiedBy: 1 );
    assert: petRepository findAll first name equals: 'Mendieta'
]
