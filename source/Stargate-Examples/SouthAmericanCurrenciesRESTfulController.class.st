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
		'requestHandler'
	],
	#category : #'Stargate-Examples-Currencies'
}

{ #category : #API }
SouthAmericanCurrenciesRESTfulController >> currenciesBasedOn: httpRequest within: requestContext [

	^ requestHandler from: httpRequest within: requestContext getCollection: [ currencies ]
]

{ #category : #API }
SouthAmericanCurrenciesRESTfulController >> currencyBasedOn: httpRequest within: requestContext [

	^ requestHandler
		from: httpRequest
		within: requestContext
		get:
			[ :isoCode | currencies detect: [ :currency | currency isoCode = isoCode ] ifNone: [ ObjectNotFound signal ] ]
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
		initializeRequestHandler
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
SouthAmericanCurrenciesRESTfulController >> initializeRequestHandler [

	requestHandler := RESTfulRequestHandlerBuilder new
		handling: 'currencies'
			extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ];
		whenAccepting: self currencyVersion1dot0dot0MediaType
			decodeFromJsonApplying: [ :json :reader | 
			reader
				for: StargateCurrency do: [ :mapping | mapping mapInstVars ];
				nextAs: StargateCurrency
			];
		whenResponding: self currencyVersion1dot0dot0MediaType
			encodeToJsonApplying:
				[ :resource :requestContext :writer | writer for: StargateCurrency do: [ :mapping | mapping mapInstVars ] ];
		createEntityTagHashing: [ :hasher :currency :requestContext | 
			hasher
				include: currency name;
				include: currency symbol;
				include: currency isoCode
			];
		build
]

{ #category : #private }
SouthAmericanCurrenciesRESTfulController >> requestHandler [

	^ requestHandler 
]

{ #category : #private }
SouthAmericanCurrenciesRESTfulController >> typeIdConstraint [

	^ IsObject
]
