"
A SouthAmericanCurrenciesRESTfulControllerTest is a test class for testing the behavior of SouthAmericanCurrenciesRESTfulController
"
Class {
	#name : #SouthAmericanCurrenciesRESTfulControllerTest,
	#superclass : #SingleResourceRESTfulControllerTest,
	#category : #'Stargate-Examples-Tests-Currencies'
}

{ #category : #'private - support' }
SouthAmericanCurrenciesRESTfulControllerTest >> baseUrl [

	^ 'https://currencies.example.com' asZnUrl
]

{ #category : #running }
SouthAmericanCurrenciesRESTfulControllerTest >> setUpResourceController [

	resourceController := SouthAmericanCurrenciesRESTfulController new
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetArgentinePeso [

	| response |

	response := resourceController
		currencyBasedOn:
			( self
				requestToGetResourceIdentifiedBy: 'ARS'
				accepting: resourceController currencyVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
			equals: resourceController currencyVersion1dot0dot0MediaType;
		assert: response entityTag equals: '"5dd07a40a75ea23fa44e641a92a6dd1ec7999a36"' asETag.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json name equals: 'Argentine peso';
				assert: json symbol equals: '$';
				assert: json isoCode equals: 'ARS';
				assert: json links isNil
			]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetBrazilianReal [

	| response |

	response := resourceController
		currencyBasedOn:
			( self
				requestToGetResourceIdentifiedBy: 'BRL'
				accepting: resourceController currencyVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
			equals: resourceController currencyVersion1dot0dot0MediaType;
		assert: response entityTag equals: '"13bd1a73c317563852cbb2858e39a0af77699f60"' asETag.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assert: json name equals: 'Brazilian real';
				assert: json symbol equals: 'R$';
				assert: json isoCode equals: 'BRL';
				assert: json links isNil
			]
]

{ #category : #tests }
SouthAmericanCurrenciesRESTfulControllerTest >> testGetCurrencies [

	| response |

	response := resourceController
		currenciesBasedOn:
			( self
				requestToGet: self resourceUrl
				accepting: resourceController currencyVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
			equals: resourceController currencyVersion1dot0dot0MediaType.

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
SouthAmericanCurrenciesRESTfulControllerTest >> testGetCurrencyNotFoundShouldFail [

	self
		should: [ resourceController
				currencyBasedOn: ( self requestToGetResourceIdentifiedBy: 'ZZZ' accepting: '*/*' )
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
				requestToGetResourceIdentifiedBy: 'ARS'
				accepting: resourceController currencyVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response entityTag equals: '"5dd07a40a75ea23fa44e641a92a6dd1ec7999a36"' asETag.

	response := resourceController
		currencyBasedOn:
			( self
				requestToGetResourceIdentifiedBy: 'ARS'
				accepting: resourceController currencyVersion1dot0dot0MediaType
				conditionalTo: response entityTag )
		within: self newHttpRequestContext.

	self
		assert: response code equals: 304;
		assert: response entityTag equals: '"5dd07a40a75ea23fa44e641a92a6dd1ec7999a36"' asETag
]
