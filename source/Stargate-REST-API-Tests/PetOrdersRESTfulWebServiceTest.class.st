"
I'm a user stoty test testing the service providing the Pet Order resource, in the classic Pet Store example
"
Class {
	#name : #PetOrdersRESTfulWebServiceTest,
	#superclass : #RESTfulWebServiceTest,
	#category : #'Stargate-REST-API-Tests-PetStore'
}

{ #category : #'private - support' }
PetOrdersRESTfulWebServiceTest >> baseUrl [

	^ 'https://petstore.example.com' asZnUrl 
]

{ #category : #'private - support' }
PetOrdersRESTfulWebServiceTest >> createOrder [

	^ webService createOrderBasedOn: (self requestToCreateOrderFrom: ('{"date":"2018-10-24T18:05:46.418Z","pet":"<1p>"}' expandMacrosWith: self petUrl)) within: self newHttpRequestContext
]

{ #category : #'private - support' }
PetOrdersRESTfulWebServiceTest >> petUrl [

	^ self baseUrl / 'pets/1' asUrl
]

{ #category : #'private - support' }
PetOrdersRESTfulWebServiceTest >> requestToCreateOrderFrom: json [

	^ self requestToPOST: json as: webService specification orderVersion1dot0dot0MediaType
]

{ #category : #'private - support' }
PetOrdersRESTfulWebServiceTest >> requestToPOST: url identifiedBy: anIdentifier [

	^ TeaRequest fromZnRequest: (ZnRequest post: url) pathParams: {(#identifier -> anIdentifier)} asDictionary
]

{ #category : #running }
PetOrdersRESTfulWebServiceTest >> setUp [

	super setUp.
	self setUpWebService.
	webService serverUrl: self baseUrl asZnUrl.
	self assert: webService orders isEmpty
]

{ #category : #running }
PetOrdersRESTfulWebServiceTest >> setUpWebService [

	webService := PetOrdersRESTfulWebService new
]

{ #category : #tests }
PetOrdersRESTfulWebServiceTest >> testGetCanceledOrder [

	| response |

	self
		assert: self createOrder isSuccess;
		assert: webService orders size equals: 1.

	response := webService getOrderBasedOn: (self requestToGetResourceIdentifiedBy: 1 accepting: webService specification orderVersion1dot0dot0MediaType) within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType equals: webService specification orderVersion1dot0dot0MediaType.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assertUrl: json pet equals: self petUrl;
				assert: json status equals: 'registered';
				assertUrl: json links self equals: 'https://petstore.example.com/orders/1';
				assertUrl: json links cancel equals: 'https://petstore.example.com/orders/1/cancel';
				assertUrl: json links complete equals: 'https://petstore.example.com/orders/1/complete'.

			self assert: (webService cancelOrderBasedOn: (self requestToPOST: json links cancel identifiedBy: 1) within: self newHttpRequestContext) isSuccess ].

	response := webService getOrderBasedOn: (self requestToGetResourceIdentifiedBy: 1 accepting: webService specification orderVersion1dot0dot0MediaType) within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType equals: webService specification orderVersion1dot0dot0MediaType.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assertUrl: json pet equals: self petUrl;
				assert: json status equals: 'canceled';
				assertUrl: json links self equals: 'https://petstore.example.com/orders/1' ]
]

{ #category : #tests }
PetOrdersRESTfulWebServiceTest >> testGetOrderJustCreated [

	| response |

	self
		assert: self createOrder isSuccess;
		assert: webService orders size equals: 1.

	response := webService getOrderBasedOn: (self requestToGetResourceIdentifiedBy: 1 accepting: webService specification orderVersion1dot0dot0MediaType) within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType equals: webService specification orderVersion1dot0dot0MediaType.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assertUrl: json pet equals: self petUrl;
				assert: json status equals: 'registered';
				assertUrl: json links self equals: 'https://petstore.example.com/orders/1';
				assertUrl: json links cancel equals: 'https://petstore.example.com/orders/1/cancel';
				assertUrl: json links complete equals: 'https://petstore.example.com/orders/1/complete' ]
]

{ #category : #tests }
PetOrdersRESTfulWebServiceTest >> testHATEOAS [

	| response |

	self
		assert: self createOrder isSuccess;
		assert: webService orders size equals: 1.

	response := webService getOrderBasedOn: (self requestToGetResourceIdentifiedBy: 1 accepting: webService specification orderVersion1dot0dot0MediaType) within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType equals: webService specification orderVersion1dot0dot0MediaType.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assertUrl: json pet equals: self petUrl;
				assert: json status equals: 'registered';
				assertUrl: json links self equals: 'https://petstore.example.com/orders/1';
				assertUrl: json links cancel equals: 'https://petstore.example.com/orders/1/cancel';
				assertUrl: json links complete equals: 'https://petstore.example.com/orders/1/complete'.

			self assert: (webService completeOrderBasedOn:  (self requestToPOST: json links complete identifiedBy: 1) within: self newHttpRequestContext) isSuccess ].

	response := webService getOrderBasedOn: (self requestToGetResourceIdentifiedBy: 1 accepting: webService specification orderVersion1dot0dot0MediaType) within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType equals: webService specification orderVersion1dot0dot0MediaType.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assertUrl: json pet equals: self petUrl;
				assert: json status equals: 'completed';
				assertUrl: json links self equals: 'https://petstore.example.com/orders/1';
				assertUrl: json links cancel equals: 'https://petstore.example.com/orders/1/cancel';
				assert: json links complete isNil.

			self assert: (webService cancelOrderBasedOn: (self requestToPOST: json links cancel identifiedBy: 1) within: self newHttpRequestContext) isSuccess ].

	response := webService getOrderBasedOn: (self requestToGetResourceIdentifiedBy: 1 accepting: webService specification orderVersion1dot0dot0MediaType) within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType equals: webService specification orderVersion1dot0dot0MediaType.

	self
		withJsonFromContentsIn: response
		do: [ :json | 
			self
				assertUrl: json pet equals: self petUrl;
				assert: json status equals: 'canceled';
				assertUrl: json links self equals: 'https://petstore.example.com/orders/1';
				assert: json links cancel isNil;
				assert: json links complete isNil ]
]

{ #category : #tests }
PetOrdersRESTfulWebServiceTest >> testOrderCreation [

	| response |

	response := self createOrder.

	self
		assert: response isSuccess;
		assert: response status equals: 201;
		assertUrl: response location equals: 'https://petstore.example.com/orders/1';
		assert: response hasEntity;
		assert: webService orders size equals: 1;
		assert: webService orders first pet equals: self petUrl
]
