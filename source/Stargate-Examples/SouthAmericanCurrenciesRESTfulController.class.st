"
I'm a example of a RESTful controller:
- only implementing GET operations
- not paginating collections
- don't using hypermedia
"
Class {
	#name : #SouthAmericanCurrenciesRESTfulController,
	#superclass : #SingleResourceRESTfulController,
	#instVars : [
		'currencies',
		'banknotesByCurrency',
		'banknotesRequestHandler',
		'currenciesRequestHandler'
	],
	#category : #'Stargate-Examples-Currencies'
}

{ #category : #private }
SouthAmericanCurrenciesRESTfulController >> banknotesTemplate [

	^ '<1s><2s>' expandMacrosWith: self identifierTemplate with: banknotesRequestHandler endpoint
]

{ #category : #API }
SouthAmericanCurrenciesRESTfulController >> currenciesBasedOn: httpRequest within: requestContext [

	^ currenciesRequestHandler from: httpRequest within: requestContext getCollection: [ currencies ]
]

{ #category : #API }
SouthAmericanCurrenciesRESTfulController >> currencyBanknotesBasedOn: httpRequest within: requestContext [

	^ banknotesRequestHandler
		from: httpRequest
		within: requestContext
		getCollection: [ banknotesByCurrency at: ( self identifierIn: httpRequest ) ]
]

{ #category : #API }
SouthAmericanCurrenciesRESTfulController >> currencyBasedOn: httpRequest within: requestContext [

	^ currenciesRequestHandler
		from: httpRequest
		within: requestContext
		get:
			[ :isoCode | currencies detect: [ :currency | currency isoCode = isoCode ] ifNone: [ NotFound signal ] ]
]

{ #category : #private }
SouthAmericanCurrenciesRESTfulController >> currencyNamed: aName symbol: aSymbol isoCode: anIsoCode [

	^ StargateCurrency named: aName symbol: aSymbol isoCode: anIsoCode
]

{ #category : #private }
SouthAmericanCurrenciesRESTfulController >> currencyVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'currency' vendoredBy: 'stargate' version: '1.0.0'
]

{ #category : #routes }
SouthAmericanCurrenciesRESTfulController >> declareGetCurrenciesRoute [

	^ RouteSpecification
		handling: #GET
		at: self endpoint
		evaluating: [ :httpRequest :requestContext | self currenciesBasedOn: httpRequest within: requestContext ]
]

{ #category : #routes }
SouthAmericanCurrenciesRESTfulController >> declareGetCurrencyBanknotesRoute [

	^ RouteSpecification
		handling: #GET
		at: self banknotesTemplate
		evaluating: [ :httpRequest :requestContext | self currencyBanknotesBasedOn: httpRequest within: requestContext ]
]

{ #category : #routes }
SouthAmericanCurrenciesRESTfulController >> declareGetCurrencyRoute [

	^ RouteSpecification
		handling: #GET
		at: self identifierTemplate
		evaluating: [ :httpRequest :requestContext | self currencyBasedOn: httpRequest within: requestContext ]
]

{ #category : #initialization }
SouthAmericanCurrenciesRESTfulController >> initialize [

	super initialize.
	self
		initializeCurrencies;
		initializeBanknotesByCurrency;
		initializeCurrenciesRequestHandler;
		initializeBanknotesRequestHandler
]

{ #category : #initialization }
SouthAmericanCurrenciesRESTfulController >> initializeBanknotesByCurrency [

	banknotesByCurrency := Dictionary new
		at: 'ARS' put: #(5 10 20 50 100 200 500 1000);
		at: 'BOB' put: #(10 20 50 100 200);
		at: 'BRL' put: #(2 5 10 20 50 100);
		at: 'CLP' put: #(1000 2000 5000 10000 20000);
		at: 'COP' put: #(1000 2000 5000 10000 20000 50000 100000);
		at: 'GYD' put: #(20 50 100 500 1000 5000);
		at: 'PYG' put: #(2000 5000 10000 20000 50000 100000);
		at: 'PEN' put: #(10 20 50 100);
		at: 'SRD' put: #(5 10 20 50 100);
		at: 'UYU' put: #(20 50 100 200 500 1000 2000);
		at: 'VES' put: #(2 5 10 20 50 100 200 500 10000 20000 50000);
		yourself
]

{ #category : #initialization }
SouthAmericanCurrenciesRESTfulController >> initializeBanknotesRequestHandler [

	banknotesRequestHandler := RESTfulRequestHandlerBuilder new
		handling: 'banknotes'
			extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ]
			locatingParentResourceWith: currenciesRequestHandler resourceLocator;
		whenResponding: ZnMimeType applicationJson
			encodeToJsonApplying: [ :resource :requestContext :writer |  ];
		createEntityTagHashing: [ :hasher :banknote :requestContext | hasher include: banknote ];
		directCachingWith: [ :caching | caching doNotExpire ];
		build
]

{ #category : #initialization }
SouthAmericanCurrenciesRESTfulController >> initializeCurrencies [

	currencies := OrderedCollection new
		add: ( self currencyNamed: 'Argentine peso' symbol: '$' isoCode: 'ARS' );
		add: ( self currencyNamed: 'Bolivian boliviano' symbol: 'Bs.' isoCode: 'BOB' );
		add: ( self currencyNamed: 'Brazilian real' symbol: 'R$' isoCode: 'BRL' );
		add: ( self currencyNamed: 'Chilean peso' symbol: '$' isoCode: 'CLP' );
		add: ( self currencyNamed: 'Colombian peso' symbol: '$' isoCode: 'COP' );
		add: ( self currencyNamed: 'Guyanese dollar' symbol: '$' isoCode: 'GYD' );
		add: ( self currencyNamed: 'Paraguayan guaraní' symbol: '₲' isoCode: 'PYG' );
		add: ( self currencyNamed: 'Peruvian sol' symbol: 'S/.' isoCode: 'PEN' );
		add: ( self currencyNamed: 'Surinamese dollar' symbol: '$' isoCode: 'SRD' );
		add: ( self currencyNamed: 'Uruguayan peso' symbol: '$' isoCode: 'UYU' );
		add: ( self currencyNamed: 'Venezuelan bolívar soberano' symbol: 'Bs.S' isoCode: 'VES' );
		asArray
]

{ #category : #initialization }
SouthAmericanCurrenciesRESTfulController >> initializeCurrenciesRequestHandler [

	currenciesRequestHandler := RESTfulRequestHandlerBuilder new
		handling: 'currencies'
			extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ];
		whenResponding: self currencyVersion1dot0dot0MediaType
			encodeToJsonApplying:
				[ :resource :requestContext :writer | writer for: StargateCurrency do: [ :mapping | mapping mapInstVars ] ];
		createEntityTagHashing: [ :hasher :currency :requestContext | 
			hasher
				include: currency name;
				include: currency symbol;
				include: currency isoCode
			];
		handleExceptionsApplying: [ :handler | handler addAsNotFoundError: NotFound ];
		directCachingWith: [ :caching | caching beImmutable ];
		build
]

{ #category : #private }
SouthAmericanCurrenciesRESTfulController >> requestHandler [

	^ currenciesRequestHandler 
]

{ #category : #private }
SouthAmericanCurrenciesRESTfulController >> typeIdConstraint [

	^ IsObject
]
