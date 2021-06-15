"
A SouthAmericanCurrenciesRESTfulControllerTest is a test class for testing the behavior of SouthAmericanCurrenciesRESTfulController
"
Class {
	#name : #SouthAmericanCurrenciesRESTfulControllerTest,
	#superclass : #SingleResourceRESTfulControllerTest,
	#category : #'Stargate-Examples-Tests-Currencies'
}

{ #category : #'private - support' }
SouthAmericanCurrenciesRESTfulControllerTest >> assertThereAreNoLinksIn: json [

	self assert: json links isNil
]

{ #category : #'private - support' }
SouthAmericanCurrenciesRESTfulControllerTest >> baseUrl [

	^ 'https://currencies.example.com' asUrl
]

{ #category : #running }
SouthAmericanCurrenciesRESTfulControllerTest >> setUpResourceController [

	resourceController := SouthAmericanCurrenciesRESTfulController new
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testCantGetArgentinePesoAskingForUnsupportedLanguage [

	| request |

	request := self
		requestToGETResourceIdentifiedBy: 'ARS'
		accepting: resourceController currencyVersion1dot0dot0MediaType.
	request setAcceptLanguage: 'de'.

	self
		should: [ resourceController currencyBasedOn: request within: self newHttpRequestContext ]
		raise: HTTPNotAcceptable
		withExceptionDo: [ :error | 
			self
				assert: error messageText
					equals: 'Cannot generate a response entity with acceptable characteristics.';
				assert: error code equals: 406;
				assert: error allowedLanguageTags size equals: 2;
				assert: error allowedLanguageTags includes: 'en-US' asLanguageTag;
				assert: error allowedLanguageTags includes: 'es-AR' asLanguageTag
			]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetArgentinePeso [

	| response |

	response := resourceController
		currencyBasedOn:
			( self
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
		assert: response entityTag equals: '"5dd07a40a75ea23fa44e641a92a6dd1ec7999a36"' asETag.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
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
		currencyBanknotesBasedOn:
			( self
				requestToGETSubresource: 'banknotes'
				identifiedBy: 'ARS'
				accepting: ZnMimeType applicationJson )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType equals: ZnMimeType applicationJson.
	self assertExpiresHeaderFor: response with: 365000000 seconds.
	self assertCachingDirectivesFor: response with: #('immutable' 'public' 'Max-Age=365000000').

	self
		withJsonFromContentsIn: response
		do: [ :banknotes | self assertCollection: banknotes hasSameElements: #(5 10 20 50 100 200 500 1000) ]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetArgentinePesoInEnglish [

	| response request |

	request := self
		requestToGETResourceIdentifiedBy: 'ARS'
		accepting: resourceController currencyVersion1dot0dot0MediaType.
	request setAcceptLanguage: 'en'.

	response := resourceController currencyBasedOn: request within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
			equals: resourceController currencyVersion1dot0dot0MediaType;
		withTheOnlyOneIn: response contentLanguageTags
			do: [ :tag | self assert: tag equals: 'en-US' asLanguageTag ];
		assert: response varyHeaderNames includes: 'Accept-Language';
		assert: response varyHeaderNames includes: 'Accept';
		assert: response entityTag equals: '"5dd07a40a75ea23fa44e641a92a6dd1ec7999a36"' asETag.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
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
		accepting: resourceController currencyVersion1dot0dot0MediaType.
	request setAcceptLanguage: 'es'.

	response := resourceController currencyBasedOn: request within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
			equals: resourceController currencyVersion1dot0dot0MediaType;
		withTheOnlyOneIn: response contentLanguageTags
			do: [ :tag | self assert: tag equals: 'es-AR' asLanguageTag ];
		assert: response varyHeaderNames includes: 'Accept-Language';
		assert: response varyHeaderNames includes: 'Accept';
		assert: response entityTag equals: '"fd65007599711248b85d86917bd24c5aa29e610b"' asETag.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
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
		currencyBasedOn:
			( self
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
		assert: response entityTag equals: '"13bd1a73c317563852cbb2858e39a0af77699f60"' asETag.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
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
		accepting: resourceController currencyVersion1dot0dot0MediaType.
	request setAcceptLanguage: 'en'.

	response := resourceController currencyBasedOn: request within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
			equals: resourceController currencyVersion1dot0dot0MediaType;
		withTheOnlyOneIn: response contentLanguageTags
			do: [ :tag | self assert: tag equals: 'en-US' asLanguageTag ];
		assert: response varyHeaderNames includes: 'Accept-Language';
		assert: response varyHeaderNames includes: 'Accept';
		assert: response entityTag equals: '"13bd1a73c317563852cbb2858e39a0af77699f60"' asETag.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
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
		accepting: resourceController currencyVersion1dot0dot0MediaType.
	request setAcceptLanguage: 'es' asLanguageTag.

	response := resourceController currencyBasedOn: request within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
			equals: resourceController currencyVersion1dot0dot0MediaType;
		withTheOnlyOneIn: response contentLanguageTags
			do: [ :tag | self assert: tag equals: 'es-AR' asLanguageTag ];
		assert: response varyHeaderNames includes: 'Accept-Language';
		assert: response varyHeaderNames includes: 'Accept';
		assert: response entityTag equals: '"f74a6f30f3c09515114aa5aa2a47253dfcd59d49"' asETag.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
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
		currenciesBasedOn:
			( self
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
	self assertCachingDirectivesFor: response with: #('immutable').

	self
		withJsonFromContentsIn: response
		do: [ :currencies | 
			self
				assert: currencies size equals: 11;
				assert: ( currencies collect: #isoCode )
					equals: #('ARS' 'BOB' 'BRL' 'CLP' 'COP' 'GYD' 'PYG' 'PEN' 'SRD' 'UYU' 'VES')
			]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetCurrenciesInSpanish [

	| response request |

	request := self
		requestToGET: self resourceUrl
		accepting: resourceController currencyVersion1dot0dot0MediaType.
	request setAcceptLanguage: 'es'.

	response := resourceController currenciesBasedOn: request within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
			equals: resourceController currencyVersion1dot0dot0MediaType;
		withTheOnlyOneIn: response contentLanguageTags
			do: [ :tag | self assert: tag equals: 'es-AR' asLanguageTag ];
		assert: response varyHeaderNames includes: 'Accept-Language';
		assert: response varyHeaderNames includes: 'Accept'.
	self assertCachingDirectivesFor: response with: #('immutable').

	self
		withJsonFromContentsIn: response
		do: [ :currencies | 
			self
				assert: currencies size equals: 11;
				assert: ( currencies collect: #isoCode )
					equals: #('ARS' 'BOB' 'BRL' 'CLP' 'COP' 'GYD' 'PYG' 'PEN' 'SRD' 'UYU' 'VES');
				assert: ( currencies anySatisfy: [ :currency | currency name = 'Real brasileño' ] )
			]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetCurrencyNotFoundShouldFail [

	self
		should: [ resourceController
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
		currencyBasedOn:
			( self
				requestToGETResourceIdentifiedBy: 'ARS'
				accepting: resourceController currencyVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response entityTag equals: '"5dd07a40a75ea23fa44e641a92a6dd1ec7999a36"' asETag.

	response := resourceController
		currencyBasedOn:
			( self
				requestToGETResourceIdentifiedBy: 'ARS'
				accepting: resourceController currencyVersion1dot0dot0MediaType
				conditionalTo: response entityTag )
		within: self newHttpRequestContext.

	self
		assert: response code equals: 304;
		assert: response entityTag equals: '"5dd07a40a75ea23fa44e641a92a6dd1ec7999a36"' asETag;
		assert: response varyHeaderNames includes: 'Accept'
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testTemplates [

	| routes |

	routes := resourceController routes.

	self
		assertCollection: ( routes collect: #urlTemplate )
		hasSameElements: #('/currencies' '/currencies/<identifier:IsObject>' '/currencies/<identifier:IsObject>/banknotes').

	routes do: [ :route | self assert: route httpMethod equals: #GET ]
]
