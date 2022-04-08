"
I'm a user stoty test testing the service providing the Pet Order resource, in the classic Pet Store example
"
Class {
	#name : #PetOrdersRESTfulControllerTest,
	#superclass : #SingleResourceRESTfulControllerTest,
	#instVars : [
		'orderRepository'
	],
	#category : #'Stargate-Examples-Tests-PetStore'
}

{ #category : #'private - support' }
PetOrdersRESTfulControllerTest >> baseUrl [

	^ 'https://petstore.example.com' asUrl
]

{ #category : #'private - support' }
PetOrdersRESTfulControllerTest >> commentsRelatedTo: order [

	^ resourceController
		orderCommentsBasedOn:
			( self requestToGETSubresource: order links comments identifiedBy: 1 accepting: ZnMimeType textPlain )
		within: self newHttpRequestContext
]

{ #category : #'private - support' }
PetOrdersRESTfulControllerTest >> createCommentFor: order identifiedBy: anId withContent: aComment [

	| request |

	request := self requestToPOST: order links comments asUrl identifiedBy: anId.
	request entity: ( ZnEntity with: aComment type: ZnMimeType textPlain ).

	^ resourceController createCommentBasedOn: request within: self newHttpRequestContext
]

{ #category : #'private - support' }
PetOrdersRESTfulControllerTest >> createOrder [

	^ resourceController
		createOrderBasedOn:
			( self
				requestToPOSTAsOrder: ( '{"date":"2018-10-24T18:05:46.418Z","pet":"<1p>"}' expandMacrosWith: self petUrl ) )
		within: self newHttpRequestContext
]

{ #category : #'private - support' }
PetOrdersRESTfulControllerTest >> getFirstOrderAndWithJsonDo: aBlock [

	| response |

	response := resourceController
		getOrderBasedOn:
			( self
				requestToGETResourceIdentifiedBy: 1
				accepting: resourceController orderVersion1dot0dot0MediaType )
		within: self newHttpRequestContext.

	self
		assert: response isSuccess;
		assert: response status equals: 200;
		assert: response contentType asMediaType
			equals: resourceController orderVersion1dot0dot0MediaType.
	self assertExpiresHeaderFor: response with: 1 minute.
	self assertCachingDirectivesFor: response with: #('public' 'Max-Age=60').
	self withJsonFromContentsIn: response do: aBlock
]

{ #category : #'private - support' }
PetOrdersRESTfulControllerTest >> parametersWith: anOrderId and: aCommentIndex [

	^ ( self parametersWith: anOrderId )
		at: resourceController commentIdentifierKey put: aCommentIndex;
		yourself
]

{ #category : #'private - support' }
PetOrdersRESTfulControllerTest >> petUrl [

	^ self baseUrl / 'pets/1' asUrl
]

{ #category : #'private - HTTP requests' }
PetOrdersRESTfulControllerTest >> requestToDELETEComment: aSubresourceUrl at: aCommentIndex forOrder: anOrderId [

	^ TeaRequest
		fromZnRequest: ( ZnRequest delete: aSubresourceUrl asUrl / aCommentIndex asString )
		pathParams: ( self parametersWith: anOrderId and: aCommentIndex )
]

{ #category : #'private - HTTP requests' }
PetOrdersRESTfulControllerTest >> requestToGETComment: aSubresourceUrl at: aCommentIndex forOrder: anOrderId [

	^ TeaRequest
		fromZnRequest:
			( ( ZnRequest get: aSubresourceUrl asUrl / aCommentIndex asString )
				setAccept: ZnMimeType textPlain;
				yourself )
		pathParams: ( self parametersWith: anOrderId and: aCommentIndex )
]

{ #category : #'private - HTTP requests' }
PetOrdersRESTfulControllerTest >> requestToPOST: url identifiedBy: anIdentifier [

	^ TeaRequest
		fromZnRequest: ( ZnRequest post: url )
		pathParams: ( self parametersWith: anIdentifier )
]

{ #category : #'private - HTTP requests' }
PetOrdersRESTfulControllerTest >> requestToPOSTAsOrder: json [

	^ self requestToPOST: json as: resourceController orderVersion1dot0dot0MediaType
]

{ #category : #'private - HTTP requests' }
PetOrdersRESTfulControllerTest >> requestToPUTComment: aComment on: aSubresourceUrl at: aCommentIndex forOrder: anOrderId conditionalTo: anETag [

	^ TeaRequest
		fromZnRequest:
			( ( ZnRequest put: aSubresourceUrl asUrl / aCommentIndex asString )
				setIfMatchTo: anETag;
				entity: ( ZnEntity text: aComment );
				yourself )
		pathParams: ( self parametersWith: anOrderId and: aCommentIndex )
]

{ #category : #running }
PetOrdersRESTfulControllerTest >> setUp [

	orderRepository := InMemoryPetOrderRepository new.
	super setUp.
	self assert: orderRepository findAll isEmpty
]

{ #category : #running }
PetOrdersRESTfulControllerTest >> setUpResourceController [

	resourceController := PetOrdersRESTfulController persistingTo: orderRepository 
]

{ #category : #'tests - comments' }
PetOrdersRESTfulControllerTest >> testCannnotDeleteComment [

	self
		withJsonFromContentsIn: self createOrder
		do: [ :order | 
			self
				should: [ resourceController
						deleteOrderCommentBasedOn: ( self requestToDELETEComment: order links comments at: 1 forOrder: 1 )
						within: self newHttpRequestContext
					]
				raise: HTTPClientError notFound
			]
]

{ #category : #'tests - comments' }
PetOrdersRESTfulControllerTest >> testCannotGetComment [

	self
		withJsonFromContentsIn: self createOrder
		do: [ :order | 
			self
				createCommentFor: order identifiedBy: 1 withContent: 'Hey!';
				createCommentFor: order identifiedBy: 1 withContent: 'Mr. DJ'.

			self
				should: [ resourceController
						orderCommentBasedOn: ( self requestToGETComment: order links comments at: 3 forOrder: 1 )
						within: self newHttpRequestContext
					]
				raise: HTTPClientError notFound
			]
]

{ #category : #'tests - comments' }
PetOrdersRESTfulControllerTest >> testCannotUpdateComment [

	self
		withJsonFromContentsIn: self createOrder
		do: [ :order | 
			| knownETag response |

			knownETag := ( self createCommentFor: order identifiedBy: 1 withContent: 'Hey!' ) entityTag.
			self createCommentFor: order identifiedBy: 1 withContent: 'Mr. DJ'.

			self
				should: [ resourceController
						updateOrderCommentBasedOn:
							( self
								requestToPUTComment: 'Hola!'
								on: order links comments
								at: 5
								forOrder: 1
								conditionalTo: knownETag )
						within: self newHttpRequestContext
					]
				raise: HTTPClientError notFound.

			response := self commentsRelatedTo: order.

			self
				assert: response isSuccess;
				assert: response contentType equals: ZnMimeType textPlain;
				assert: response contents equals: '- Hey!<n>- Mr. DJ' expandMacros
			]
]

{ #category : #'tests - comments' }
PetOrdersRESTfulControllerTest >> testCannotUpdateCommentWhenETagDoesNotMatch [

	self withJsonFromContentsIn: self createOrder do: [ :order | 
		| response |

		self
			createCommentFor: order identifiedBy: 1 withContent: 'Hey!';
			createCommentFor: order identifiedBy: 1 withContent: 'Mr. DJ'.

		self
			should: [ 
				resourceController
					updateOrderCommentBasedOn: ( self
							  requestToPUTComment: 'Hola!'
							  on: order links comments
							  at: 1
							  forOrder: 1
							  conditionalTo: '"XXX"' asEntityTag )
					within: self newHttpRequestContext
				]
			raise: HTTPClientError preconditionFailed.

		response := self commentsRelatedTo: order.

		self
			assert: response isSuccess;
			assert: response contentType equals: ZnMimeType textPlain;
			assert: response contents equals: '- Hey!<n>- Mr. DJ' expandMacros
		]
]

{ #category : #'tests - comments' }
PetOrdersRESTfulControllerTest >> testCommentCreation [

	self
		withJsonFromContentsIn: self createOrder
		do: [ :order | 
			| response |

			response := self createCommentFor: order identifiedBy: 1 withContent: 'First comment!'.

			self
				assert: response isSuccess;
				assert: response isCreated;
				assert: response contentType equals: ZnMimeType textPlain;
				assert: response contents equals: 'First comment!';
				assertUrl: response location equals: 'https://petstore.example.com/orders/1/comments/1'.

			response := self createCommentFor: order identifiedBy: 1 withContent: 'Second'.

			self
				assert: response isSuccess;
				assert: response isCreated;
				assert: response contentType equals: ZnMimeType textPlain;
				assert: response contents equals: 'Second';
				assertUrl: response location equals: 'https://petstore.example.com/orders/1/comments/2'
			]
]

{ #category : #'tests - comments' }
PetOrdersRESTfulControllerTest >> testDeleteComment [

	self
		withJsonFromContentsIn: self createOrder
		do: [ :order | 
			| response |

			self
				createCommentFor: order identifiedBy: 1 withContent: 'Hey!';
				createCommentFor: order identifiedBy: 1 withContent: 'Mr. DJ'.

			response := resourceController
				deleteOrderCommentBasedOn: ( self requestToDELETEComment: order links comments at: 2 forOrder: 1 )
				within: self newHttpRequestContext.

			self
				assert: response isSuccess;
				assert: response isNoContent.

			response := resourceController
				orderCommentsBasedOn:
					( self requestToGETSubresource: order links comments identifiedBy: 1 accepting: ZnMimeType textPlain )
				within: self newHttpRequestContext.

			self
				assert: response isSuccess;
				assert: response contentType equals: ZnMimeType textPlain;
				assert: response contents equals: '- Hey!' expandMacros
			]
]

{ #category : #'tests - orders' }
PetOrdersRESTfulControllerTest >> testGetCanceledOrder [

	self
		createOrder;
		getFirstOrderAndWithJsonDo: [ :json | 
			self
				assertUrl: json pet equals: self petUrl;
				assert: json status equals: 'registered';
				assertUrl: json selfLocation equals: 'https://petstore.example.com/orders/1';
				assertUrl: json links cancel equals: 'https://petstore.example.com/orders/1/cancel';
				assertUrl: json links complete equals: 'https://petstore.example.com/orders/1/complete';
				assert: (resourceController cancelOrderBasedOn: (self requestToPOST: json links cancel identifiedBy: 1) within: self newHttpRequestContext) isSuccess ];
		getFirstOrderAndWithJsonDo: [ :json | 
			self
				assertUrl: json pet equals: self petUrl;
				assert: json status equals: 'canceled';
				assertUrl: json selfLocation equals: 'https://petstore.example.com/orders/1' ]
]

{ #category : #'tests - comments' }
PetOrdersRESTfulControllerTest >> testGetComment [

	self
		withJsonFromContentsIn: self createOrder
		do: [ :order | 
			| response |

			self
				createCommentFor: order identifiedBy: 1 withContent: 'Hey!';
				createCommentFor: order identifiedBy: 1 withContent: 'Mr. DJ'.

			response := resourceController
				orderCommentBasedOn: ( self requestToGETComment: order links comments at: 1 forOrder: 1 )
				within: self newHttpRequestContext.

			self
				assert: response isSuccess;
				assert: response contentType equals: ZnMimeType textPlain;
				assert: response contents equals: 'Hey!'
			]
]

{ #category : #'tests - comments' }
PetOrdersRESTfulControllerTest >> testGetComments [

	self
		withJsonFromContentsIn: self createOrder
		do: [ :order | 
			| response |

			self
				createCommentFor: order identifiedBy: 1 withContent: 'Hey!';
				createCommentFor: order identifiedBy: 1 withContent: 'Mr. DJ'.

			response := self commentsRelatedTo: order.

			self
				assert: response isSuccess;
				assert: response contentType equals: ZnMimeType textPlain;
				assert: response contents equals: '- Hey!<n>- Mr. DJ' expandMacros.
			self assertCachingDirectivesFor: response with: #('S-MaxAge=600' 'proxy-revalidate')
			]
]

{ #category : #'tests - comments' }
PetOrdersRESTfulControllerTest >> testGetCommentsForJustCreatedOrder [

	self
		withJsonFromContentsIn: self createOrder
		do: [ :order | 
			| response |

			response := resourceController
				orderCommentsBasedOn:
					( self requestToGETSubresource: order links comments identifiedBy: 1 accepting: ZnMimeType textPlain )
				within: self newHttpRequestContext.

			self
				assert: response isSuccess;
				assert: response contentType equals: ZnMimeType textPlain;
				assert: response contents isEmpty
			]
]

{ #category : #'tests - orders' }
PetOrdersRESTfulControllerTest >> testGetOrderJustCreated [

	self
		createOrder;
		getFirstOrderAndWithJsonDo: [ :json | 
			self
				assertUrl: json pet equals: self petUrl;
				assert: json status equals: 'registered';
				assertUrl: json selfLocation equals: 'https://petstore.example.com/orders/1';
				assertUrl: json links cancel equals: 'https://petstore.example.com/orders/1/cancel';
				assertUrl: json links complete equals: 'https://petstore.example.com/orders/1/complete' ]
]

{ #category : #'tests - orders' }
PetOrdersRESTfulControllerTest >> testHATEOAS [

	"This case will transition an order from registered to completed to canceled, using the hypermedia controls provided
	in the response."

	self
		createOrder;
		getFirstOrderAndWithJsonDo: [ :json | 
			self
				assertUrl: json pet equals: self petUrl;
				assert: json status equals: 'registered';
				assertUrl: json selfLocation equals: 'https://petstore.example.com/orders/1';
				assertUrl: json links cancel equals: 'https://petstore.example.com/orders/1/cancel';
				assertUrl: json links complete equals: 'https://petstore.example.com/orders/1/complete';
				assert:
					( resourceController
						completeOrderBasedOn: ( self requestToPOST: json links complete identifiedBy: 1 )
						within: self newHttpRequestContext ) isSuccess
			];
		getFirstOrderAndWithJsonDo: [ :json | 
			self
				assertUrl: json pet equals: self petUrl;
				assert: json status equals: 'completed';
				assertUrl: json selfLocation equals: 'https://petstore.example.com/orders/1';
				assertUrl: json links cancel equals: 'https://petstore.example.com/orders/1/cancel';
				assert: json links complete isNil;
				assert:
					( resourceController
						cancelOrderBasedOn: ( self requestToPOST: json links cancel identifiedBy: 1 )
						within: self newHttpRequestContext ) isSuccess
			];
		getFirstOrderAndWithJsonDo: [ :json | 
			self
				assertUrl: json pet equals: self petUrl;
				assert: json status equals: 'canceled';
				assertUrl: json selfLocation equals: 'https://petstore.example.com/orders/1';
				assert: json links cancel isNil;
				assert: json links complete isNil
			]
]

{ #category : #'tests - orders' }
PetOrdersRESTfulControllerTest >> testInvalidStateTransition [

	| completeOrderLink |

	self
		createOrder;
		getFirstOrderAndWithJsonDo: [ :json | 
			self assert: json status equals: 'registered'.
			completeOrderLink := json links complete.
			self assert: (resourceController cancelOrderBasedOn: (self requestToPOST: json links cancel identifiedBy: 1) within: self newHttpRequestContext) isSuccess ];
		getFirstOrderAndWithJsonDo: [ :json | 
			self
				assert: json status equals: 'canceled';
				assert: json links cancel isNil;
				assert: json links complete isNil ];
		should: [ resourceController completeOrderBasedOn: (self requestToPOST: completeOrderLink identifiedBy: 1) within: self newHttpRequestContext ]
			raise: HTTPClientError
			withExceptionDo: [ :error | self assert: error code equals: 409 ]
]

{ #category : #'tests - orders' }
PetOrdersRESTfulControllerTest >> testOrderCreation [

	| response |

	response := self createOrder.

	self
		assert: response isSuccess;
		assert: response status equals: 201;
		assertUrl: response location equals: 'https://petstore.example.com/orders/1';
		assert: response hasEntity;
		assert: orderRepository count equals: 1;
		assert: orderRepository findAll first pet equals: self petUrl
]

{ #category : #tests }
PetOrdersRESTfulControllerTest >> testRoutes [

	| routes |

	routes := resourceController routes.

	self
		assert: routes size equals: 9;
		assertCollection: ( routes collect: #urlTemplate )
			hasSameElements: #(
				'/orders' 
				'/orders/<identifier:IsInteger>' 
				'/orders/<identifier:IsInteger>/cancel' 
				'/orders/<identifier:IsInteger>/complete' 
				'/orders/<identifier:IsInteger>/comments' 
				'/orders/<identifier:IsInteger>/comments/<commentIdentifier:IsInteger>')
]

{ #category : #tests }
PetOrdersRESTfulControllerTest >> testTemplate [

	| controller |

	controller := PetOrdersRESTfulController new.

	self
		assert: controller identifierTemplate equals: '/orders/<identifier:IsInteger>';
		assert: controller cancelTemplate equals: '/orders/<identifier:IsInteger>/cancel';
		assert: controller completeTemplate equals: '/orders/<identifier:IsInteger>/complete';
		assert: controller commentsTemplate equals: '/orders/<identifier:IsInteger>/comments';
		assert: controller commentIdentifierTemplate
			equals: '/orders/<identifier:IsInteger>/comments/<commentIdentifier:IsInteger>'
]

{ #category : #'tests - comments' }
PetOrdersRESTfulControllerTest >> testUpdateComment [

	self
		withJsonFromContentsIn: self createOrder
		do: [ :order | 
			| response knownETag |

			knownETag := ( self createCommentFor: order identifiedBy: 1 withContent: 'Hey!' ) entityTag.
			self createCommentFor: order identifiedBy: 1 withContent: 'Mr. DJ'.

			response := resourceController
				updateOrderCommentBasedOn:
					( self
						requestToPUTComment: 'Hola!'
						on: order links comments
						at: 1
						forOrder: 1
						conditionalTo: knownETag )
				within: self newHttpRequestContext.

			self
				assert: response isSuccess;
				deny: response entityTag = knownETag;
				assert: response contents equals: 'Hola!'.

			response := resourceController
				orderCommentsBasedOn:
					( self requestToGETSubresource: order links comments identifiedBy: 1 accepting: ZnMimeType textPlain )
				within: self newHttpRequestContext.

			self
				assert: response isSuccess;
				assert: response contentType equals: ZnMimeType textPlain;
				assert: response contents equals: '- Hola!<n>- Mr. DJ' expandMacros
			]
]
