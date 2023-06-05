"
A SouthAmericanCurrenciesRESTfulControllerTest is a test class for testing the behavior of SouthAmericanCurrenciesRESTfulController
"
Class {
	#name : #SouthAmericanCurrenciesRESTfulControllerTest,
	#superclass : #SingleResourceRESTfulControllerTest,
	#category : #'Stargate-Examples-Tests-Currencies'
}

{ #category : #'private - language ranges' }
SouthAmericanCurrenciesRESTfulControllerTest >> argentineSpanish [

	^ 'es-AR' asLanguageTag 
]

{ #category : #'private - support' }
SouthAmericanCurrenciesRESTfulControllerTest >> assertThereAreNoLinksIn: json [

	self assert: json links isNil
]

{ #category : #'private - support' }
SouthAmericanCurrenciesRESTfulControllerTest >> baseUrl [

	^ 'https://currencies.example.com' asUrl
]

{ #category : #'private - language ranges' }
SouthAmericanCurrenciesRESTfulControllerTest >> english [

	^ 'en' asLanguageTag 
]

{ #category : #'private - language ranges' }
SouthAmericanCurrenciesRESTfulControllerTest >> languageRange [

	^ 'de,en;q=0.5,es;q=0.6'
]

{ #category : #running }
SouthAmericanCurrenciesRESTfulControllerTest >> setUpResourceController [

	resourceController := SouthAmericanCurrenciesRESTfulController new
]

{ #category : #'private - language ranges' }
SouthAmericanCurrenciesRESTfulControllerTest >> spanish [

	^ 'es' asLanguageTag 
]

{ #category : #'private - language ranges' }
SouthAmericanCurrenciesRESTfulControllerTest >> supportedLanguages [

	^ Array with: self argentineSpanish with: self unitedStatesEnglish
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testCantGetArgentinePesoAskingForAnEmptyLanguage [

	| request |

	request := self
		           requestToGETResourceIdentifiedBy: 'ARS'
		           acceptingContentMatching: resourceController currencyVersion1dot0dot0MediaType
		           inAnyOf: ''.

	self
		should: [ resourceController currencyBasedOn: request within: self newHttpRequestContext ]
		raise: HTTPNotAcceptable
		withExceptionDo: [ :error | 
			self
				assert: error messageText
				equals: 'Cannot generate a response entity with acceptable characteristics.';
				assert: error code equals: 406;
				assertCollection: error allowedLanguageTags hasSameElements: self supportedLanguages
			]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testCantGetArgentinePesoAskingForUnsupportedLanguage [

	| request |

	request := self
		           requestToGETResourceIdentifiedBy: 'ARS'
		           acceptingContentMatching: resourceController currencyVersion1dot0dot0MediaType
		           inAnyOf: self unsupportedLanguage.

	self
		should: [ resourceController currencyBasedOn: request within: self newHttpRequestContext ]
		raise: HTTPNotAcceptable
		withExceptionDo: [ :error | 
			self
				assert: error messageText
				equals: 'Cannot generate a response entity with acceptable characteristics.';
				assert: error code equals: 406;
				assertCollection: error allowedLanguageTags hasSameElements: self supportedLanguages
			]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetArgentinePeso [

	| response |

	response := resourceController
		            currencyBasedOn: ( self
				              requestToGETResourceIdentifiedBy: 'ARS'
				              accepting: resourceController currencyVersion1dot0dot0MediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		assert: response contentLanguageTags isEmpty;
		deny: response varyHeaderNames includes: 'Accept-Language';
		assert: response varyHeaderNames includes: 'Accept';
		assert: response entityTag equals: '"5dd07a40a75ea23fa44e641a92a6dd1ec7999a36"' asEntityTag;
		assertCachingDirectivesFor: response with: #( 'immutable' 'public' ).

	self withJsonFromContentsIn: response do: [ :json | 
		self
			assert: json name equals: 'Argentine peso';
			assert: json symbol equals: '$';
			assert: json isoCode equals: 'ARS';
			assertThereAreNoLinksIn: json
		]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetArgentinePesoBanknotes [

	| response |

	response := resourceController
		            currencyBanknotesBasedOn: ( self
				              requestToGETSubresource: 'banknotes'
				              identifiedBy: 'ARS'
				              accepting: ZnMimeType applicationJson )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType equals: ZnMimeType applicationJson.
	self assertExpiresHeaderFor: response with: 365000000 seconds.
	self assertCachingDirectivesFor: response with: #( 'immutable' 'public' 'Max-Age=365000000' ).

	self
		withJsonFromContentsIn: response
		do: [ :banknotes | 
		self assertCollection: banknotes hasSameElements: #( 5 10 20 50 100 200 500 1000 ) ]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetArgentinePesoInEnglish [

	| response request |

	request := self
		           requestToGETResourceIdentifiedBy: 'ARS'
		           acceptingContentMatching: resourceController currencyVersion1dot0dot0MediaType
		           inAnyOf: self english.

	response := resourceController currencyBasedOn: request within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		withTheOnlyOneIn: response contentLanguageTags
		do: [ :tag | self assert: tag equals: self unitedStatesEnglish ];
		assert: response varyHeaderNames includes: 'Accept-Language';
		assert: response varyHeaderNames includes: 'Accept';
		assert: response entityTag equals: '"5dd07a40a75ea23fa44e641a92a6dd1ec7999a36"' asEntityTag.

	self withJsonFromContentsIn: response do: [ :json | 
		self
			assert: json name equals: 'Argentine peso';
			assert: json symbol equals: '$';
			assert: json isoCode equals: 'ARS';
			assertThereAreNoLinksIn: json
		]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetArgentinePesoInEnglishBasedOnAnyLanguageWildcard [

	| response request |

	request := self
		           requestToGETResourceIdentifiedBy: 'ARS'
		           acceptingContentMatching: resourceController currencyVersion1dot0dot0MediaType
		           inAnyOf: '*'.

	response := resourceController currencyBasedOn: request within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		withTheOnlyOneIn: response contentLanguageTags
		do: [ :tag | self assert: tag equals: self unitedStatesEnglish ];
		assert: response varyHeaderNames includes: 'Accept-Language';
		assert: response varyHeaderNames includes: 'Accept';
		assert: response entityTag equals: '"5dd07a40a75ea23fa44e641a92a6dd1ec7999a36"' asEntityTag.

	self withJsonFromContentsIn: response do: [ :json | 
		self
			assert: json name equals: 'Argentine peso';
			assert: json symbol equals: '$';
			assert: json isoCode equals: 'ARS';
			assertThereAreNoLinksIn: json
		]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetArgentinePesoInSpanish [

	| response request |

	request := self
		           requestToGETResourceIdentifiedBy: 'ARS'
		           acceptingContentMatching: resourceController currencyVersion1dot0dot0MediaType
		           inAnyOf: self spanish.

	response := resourceController currencyBasedOn: request within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		withTheOnlyOneIn: response contentLanguageTags
		do: [ :tag | self assert: tag equals: self argentineSpanish ];
		assert: response varyHeaderNames includes: 'Accept-Language';
		assert: response varyHeaderNames includes: 'Accept';
		assert: response entityTag equals: '"fd65007599711248b85d86917bd24c5aa29e610b"' asEntityTag.

	self withJsonFromContentsIn: response do: [ :json | 
		self
			assert: json name equals: 'Peso';
			assert: json symbol equals: '$';
			assert: json isoCode equals: 'ARS';
			assertThereAreNoLinksIn: json
		]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetArgentinePesoInSpanishBasedOnLanguagePriorityList [

	| response request |

	request := self
		           requestToGETResourceIdentifiedBy: 'ARS'
		           acceptingContentMatching: resourceController currencyVersion1dot0dot0MediaType
		           inAnyOf: self languageRange.

	response := resourceController currencyBasedOn: request within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		withTheOnlyOneIn: response contentLanguageTags
		do: [ :tag | self assert: tag equals: self argentineSpanish ];
		assert: response varyHeaderNames includes: 'Accept-Language';
		assert: response varyHeaderNames includes: 'Accept';
		assert: response entityTag equals: '"fd65007599711248b85d86917bd24c5aa29e610b"' asEntityTag.

	self withJsonFromContentsIn: response do: [ :json | 
		self
			assert: json name equals: 'Peso';
			assert: json symbol equals: '$';
			assert: json isoCode equals: 'ARS';
			assertThereAreNoLinksIn: json
		]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetBrazilianReal [

	| response |

	response := resourceController
		            currencyBasedOn: ( self
				              requestToGETResourceIdentifiedBy: 'BRL'
				              accepting: resourceController currencyVersion1dot0dot0MediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		assert: response contentLanguageTags isEmpty;
		assert: response varyHeaderNames includes: 'Accept';
		assert: response entityTag equals: '"13bd1a73c317563852cbb2858e39a0af77699f60"' asEntityTag;
		assertCachingDirectivesFor: response with: #( 'immutable' ).

	self withJsonFromContentsIn: response do: [ :json | 
		self
			assert: json name equals: 'Brazilian real';
			assert: json symbol equals: 'R$';
			assert: json isoCode equals: 'BRL';
			assertThereAreNoLinksIn: json
		]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetBrazilianRealInEnglish [

	| response request |

	request := self
		           requestToGETResourceIdentifiedBy: 'BRL'
		           acceptingContentMatching: resourceController currencyVersion1dot0dot0MediaType
		           inAnyOf: self english.


	response := resourceController currencyBasedOn: request within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		withTheOnlyOneIn: response contentLanguageTags
		do: [ :tag | self assert: tag equals: self unitedStatesEnglish ];
		assert: response varyHeaderNames includes: 'Accept-Language';
		assert: response varyHeaderNames includes: 'Accept';
		assert: response entityTag equals: '"13bd1a73c317563852cbb2858e39a0af77699f60"' asEntityTag.

	self withJsonFromContentsIn: response do: [ :json | 
		self
			assert: json name equals: 'Brazilian real';
			assert: json symbol equals: 'R$';
			assert: json isoCode equals: 'BRL';
			assertThereAreNoLinksIn: json
		]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetBrazilianRealInSpanish [

	| response request |

	request := self
		           requestToGETResourceIdentifiedBy: 'BRL'
		           acceptingContentMatching: resourceController currencyVersion1dot0dot0MediaType
		           inAnyOf: self spanish.

	response := resourceController currencyBasedOn: request within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		withTheOnlyOneIn: response contentLanguageTags
		do: [ :tag | self assert: tag equals: self argentineSpanish ];
		assert: response varyHeaderNames includes: 'Accept-Language';
		assert: response varyHeaderNames includes: 'Accept';
		assert: response entityTag equals: '"f74a6f30f3c09515114aa5aa2a47253dfcd59d49"' asEntityTag.

	self withJsonFromContentsIn: response do: [ :json | 
		self
			assert: json name equals: 'Real brasileño';
			assert: json symbol equals: 'R$';
			assert: json isoCode equals: 'BRL';
			assertThereAreNoLinksIn: json
		]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetCurrencies [

	| response |

	response := resourceController
		            currenciesBasedOn: ( self
				              requestToGET: self resourceUrl
				              accepting: resourceController currencyVersion1dot0dot0MediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		assert: response contentLanguageTags isEmpty;
		deny: response varyHeaderNames includes: 'Accept-Language';
		assert: response varyHeaderNames includes: 'Accept'.
	self assertCachingDirectivesFor: response with: #( 'immutable' 'Max-Age=86400' ).

	self withJsonFromContentsIn: response do: [ :currencies | 
		self
			assert: currencies size equals: 11;
			assert: ( currencies collect: #isoCode )
			equals: #( 'ARS' 'BOB' 'BRL' 'CLP' 'COP' 'GYD' 'PYG' 'PEN' 'SRD' 'UYU' 'VES' )
		]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetCurrenciesInSpanish [

	| response request |

	request := self requestToGET: self resourceUrl applying: [ :requestConfig | 
		           requestConfig
			           setAccept: resourceController currencyVersion1dot0dot0MediaType;
			           setAcceptLanguage: self spanish
		           ].

	response := resourceController currenciesBasedOn: request within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
		equals: resourceController currencyVersion1dot0dot0MediaType;
		withTheOnlyOneIn: response contentLanguageTags
		do: [ :tag | self assert: tag equals: self argentineSpanish ];
		assert: response varyHeaderNames includes: 'Accept-Language';
		assert: response varyHeaderNames includes: 'Accept'.
	self assertCachingDirectivesFor: response with: #( 'immutable' 'Max-Age=86400' ).

	self withJsonFromContentsIn: response do: [ :currencies | 
		self
			assert: currencies size equals: 11;
			assert: ( currencies collect: #isoCode )
			equals: #( 'ARS' 'BOB' 'BRL' 'CLP' 'COP' 'GYD' 'PYG' 'PEN' 'SRD' 'UYU' 'VES' );
			assert: ( currencies anySatisfy: [ :currency | currency name = 'Real brasileño' ] )
		]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetCurrencyNotFoundShouldFail [

	self
		should: [ 
			resourceController
				currencyBasedOn: ( self requestToGETResourceIdentifiedBy: 'ZZZ' accepting: '*/*' )
				within: self newHttpRequestContext
			]
		raise: HTTPClientError
		withExceptionDo: [ :error | self assert: error code equals: 404 ]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetNotModifiedWhenValidETag [

	| response |

	response := resourceController
		            currencyBasedOn: ( self
				              requestToGETResourceIdentifiedBy: 'ARS'
				              accepting: resourceController currencyVersion1dot0dot0MediaType )
		            within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response entityTag equals: '"5dd07a40a75ea23fa44e641a92a6dd1ec7999a36"' asEntityTag.

	response := resourceController
		            currencyBasedOn: ( self
				              requestToGETResourceIdentifiedBy: 'ARS'
				              accepting: resourceController currencyVersion1dot0dot0MediaType
				              conditionalTo: response entityTag )
		            within: self newHttpRequestContext.

	self
		assert: response code equals: 304;
		assert: response entityTag equals: '"5dd07a40a75ea23fa44e641a92a6dd1ec7999a36"' asEntityTag;
		assert: response varyHeaderNames includes: 'Accept'
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testTemplates [

	| routes |

	routes := resourceController routes.

	self
		assertCollection: ( routes collect: #urlTemplate )
		hasSameElements:
		#( '/currencies' '/currencies/<identifier:IsObject>' '/currencies/<identifier:IsObject>/banknotes' ).

	routes do: [ :route | self assert: route httpMethod equals: #GET ]
]

{ #category : #'private - language ranges' }
SouthAmericanCurrenciesRESTfulControllerTest >> unitedStatesEnglish [

	^ 'en-US' asLanguageTag 
]

{ #category : #'private - language ranges' }
SouthAmericanCurrenciesRESTfulControllerTest >> unsupportedLanguage [

	^ 'de' asLanguageTag
]
