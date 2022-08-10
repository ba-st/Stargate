"
I'm an example RESTful Controller implementing Pet Order resource management
"
Class {
	#name : #PetOrdersRESTfulController,
	#superclass : #SingleResourceRESTfulController,
	#instVars : [
		'ordersRepository',
		'commentsRequestHandler',
		'commentsByOrderId',
		'ordersRequestHandler'
	],
	#category : #'Stargate-Examples-PetStore'
}

{ #category : #'instance creation' }
PetOrdersRESTfulController class >> new [

	^ self persistingTo: InMemoryPetOrderRepository  new
]

{ #category : #'instance creation' }
PetOrdersRESTfulController class >> persistingTo: aRepository [

	^ self basicNew initializePersistingTo: aRepository
]

{ #category : #private }
PetOrdersRESTfulController >> affect: builder withMediaControlsFor: order locatedAt: location [

	| status |

	status := ordersRepository statusOf: order.	
	"In the real life you don't do a case. This is a toy example"
	status = 'registered'
		ifTrue: [ builder
				addLink: location / 'cancel' asUrl relatedTo: 'cancel';
				addLink: location / 'complete' asUrl relatedTo: 'complete'
			].
	status = 'completed'
		ifTrue: [ builder addLink: location / 'cancel' asUrl relatedTo: 'cancel' ].

	builder addLink: location / 'comments' asUrl relatedTo: 'comments'
]

{ #category : #'API - orders' }
PetOrdersRESTfulController >> cancelOrderBasedOn: httpRequest within: requestContext [

	^ ordersRequestHandler
		from: httpRequest
		within: requestContext
		get: [ :id | ordersRepository findIdentifiedBy: id ]
		thenDo: [ :order | ordersRepository updateStatusOf: order to: 'canceled' ]
]

{ #category : #private }
PetOrdersRESTfulController >> cancelTemplate [

	^ '<1s>/cancel' expandMacrosWith: self identifierTemplate
]

{ #category : #private }
PetOrdersRESTfulController >> commentIdentifierIn: httpRequest [

	^ httpRequest at: self commentIdentifierKey
]

{ #category : #private }
PetOrdersRESTfulController >> commentIdentifierKey [

	^ #commentIdentifier
]

{ #category : #private }
PetOrdersRESTfulController >> commentIdentifierTemplate [

	^ '<1s>/%<<2s>:<3s>>'
		expandMacrosWith: self commentsTemplate
		with: self commentIdentifierKey
		with: self typeIdConstraint asString
]

{ #category : #private }
PetOrdersRESTfulController >> commentsForOrderIn: httpRequest [

	^ commentsByOrderId at: ( self identifierIn: httpRequest ) ifAbsent: [ #() ]
]

{ #category : #private }
PetOrdersRESTfulController >> commentsTemplate [

	^ '<1s><2s>' expandMacrosWith: self identifierTemplate with: commentsRequestHandler endpoint
]

{ #category : #'API - orders' }
PetOrdersRESTfulController >> completeOrderBasedOn: httpRequest within: requestContext [

	^ ordersRequestHandler
		from: httpRequest
		within: requestContext
		get: [ :id | ordersRepository findIdentifiedBy: id ]
		thenDo: [ :order | ordersRepository updateStatusOf: order to: 'completed' ]
]

{ #category : #private }
PetOrdersRESTfulController >> completeTemplate [

	^ '<1s>/complete' expandMacrosWith: self identifierTemplate
]

{ #category : #private }
PetOrdersRESTfulController >> configureOrderDecodingOn: reader [

	^ reader
		for: PetOrder
			do: [ :mapping | 
			mapping
				mapInstVar: #date;
				mapProperty: #pet setter: [ :order :url | order instVarNamed: 'pet' put: url asUrl ]
			];
		nextAs: PetOrder
]

{ #category : #private }
PetOrdersRESTfulController >> configureOrderEncodingOn: writer within: requestContext [

	writer
		for: ZnUrl customDo: [ :mapping | mapping encoder: [ :url | url printString ] ];
		for: #Order
			do: [ :mapping | 
			mapping
				mapProperty: #pet getter: #pet;
				mapProperty: #name getter: #date;
				mapProperty: #status getter: [ :object | requestContext objectUnder: #status ];
				mapAsHypermediaControls: [ :order | requestContext hypermediaControlsFor: order ]
			]
]

{ #category : #'API - comments' }
PetOrdersRESTfulController >> createCommentBasedOn: httpRequest within: requestContext [

	^ commentsRequestHandler
		withResourceCreatedFrom: httpRequest
		within: requestContext
		do: [ :comment | 
			| orderId order comments |
			orderId := self identifierIn: httpRequest.
			order := ordersRepository findIdentifiedBy: orderId.
			requestContext parentResource: order.
			comments := commentsByOrderId at: orderId ifAbsentPut: [ OrderedCollection new ].
			comments add: comment.
			comment
			]
]

{ #category : #'API - orders' }
PetOrdersRESTfulController >> createOrderBasedOn: httpRequest within: requestContext [

	^ ordersRequestHandler
		withResourceCreatedFrom: httpRequest
		within: requestContext
		do: [ :order | 
			ordersRepository store: order.
			requestContext hold: ( ordersRepository statusOf: order ) under: #status.
			order
			]
]

{ #category : #routes }
PetOrdersRESTfulController >> declareCancelOrderRoute [

	^ RouteSpecification
		handling: #POST
		at: self cancelTemplate
		evaluating: [ :httpRequest :requestContext | self cancelOrderBasedOn: httpRequest within: requestContext ]
]

{ #category : #routes }
PetOrdersRESTfulController >> declareCompleteOrderRoute [

	^ RouteSpecification
		handling: #POST
		at: self completeTemplate
		evaluating: [ :httpRequest :requestContext | self completeOrderBasedOn: httpRequest within: requestContext ]
]

{ #category : #routes }
PetOrdersRESTfulController >> declareCreateOrderCommentRoute [

	^ RouteSpecification
		handling: #POST
		at: self commentsTemplate
		evaluating: [ :httpRequest :requestContext | self createCommentBasedOn: httpRequest within: requestContext ]
]

{ #category : #routes }
PetOrdersRESTfulController >> declareCreateOrderRoute [

	^ RouteSpecification
		handling: #POST
		at: self endpoint
		evaluating: [ :httpRequest :requestContext | self createOrderBasedOn: httpRequest within: requestContext ]
]

{ #category : #routes }
PetOrdersRESTfulController >> declareDeleteOrderCommentRoute [

	^ RouteSpecification
		handling: #DELETE
		at: self commentIdentifierTemplate
		evaluating:
			[ :httpRequest :requestContext | self deleteOrderCommentBasedOn: httpRequest within: requestContext ]
]

{ #category : #routes }
PetOrdersRESTfulController >> declareGetOrderCommentRoute [

	^ RouteSpecification
		handling: #GET
		at: self commentIdentifierTemplate
		evaluating: [ :httpRequest :requestContext | self orderCommentBasedOn: httpRequest within: requestContext ]
]

{ #category : #routes }
PetOrdersRESTfulController >> declareGetOrderCommentsRoute [

	^ RouteSpecification
		handling: #GET
		at: self commentsTemplate
		evaluating: [ :httpRequest :requestContext | self orderCommentsBasedOn: httpRequest within: requestContext ]
]

{ #category : #routes }
PetOrdersRESTfulController >> declareGetOrderRoute [

	^ RouteSpecification
		handling: #GET
		at: self identifierTemplate
		evaluating: [ :httpRequest :requestContext | self getOrderBasedOn: httpRequest within: requestContext ]
]

{ #category : #routes }
PetOrdersRESTfulController >> declareUpdateOrderCommentRoute [

	^ RouteSpecification
		handling: #PUT
		at: self commentIdentifierTemplate
		evaluating:
			[ :httpRequest :requestContext | self updateOrderCommentBasedOn: httpRequest within: requestContext ]
]

{ #category : #'API - comments' }
PetOrdersRESTfulController >> deleteOrderCommentBasedOn: httpRequest within: requestContext [

	^ commentsRequestHandler
		from: httpRequest
		within: requestContext
		get: [ :index | ( self commentsForOrderIn: httpRequest ) at: index ifAbsent: [ ObjectNotFound signal ] ]
		thenDo: [ :comment | ( self commentsForOrderIn: httpRequest ) remove: comment ]
]

{ #category : #private }
PetOrdersRESTfulController >> encodeComments: resource [

	^ resource isArray
		ifTrue: [ ( CollectionFormatter
				separatingWith: '<n>' expandMacros
				applyingToEach: [ :comment | '- <1s>' expandMacrosWith: comment ] ) format: resource
			]
		ifFalse: [ resource asString ]
]

{ #category : #'API - orders' }
PetOrdersRESTfulController >> getOrderBasedOn: httpRequest within: requestContext [

	^ ordersRequestHandler
		from: httpRequest
		within: requestContext
		get: [ :id | 
			| order |
			order := ordersRepository findIdentifiedBy: id.
			requestContext hold: ( ordersRepository statusOf: order ) under: #status.
			order
			]
]

{ #category : #initialization }
PetOrdersRESTfulController >> initializeCommentsRequestHandler [

	commentsRequestHandler := RESTfulRequestHandlerBuilder new
		handling: 'comments'
			locatingSubresourcesWith: [ :comment :requestContext | 
				( commentsByOrderId at: ( ordersRepository identifierOf: requestContext parentResource ) )
					indexOf: comment
				]
			extractingIdentifierWith: [ :httpRequest | self commentIdentifierIn: httpRequest ]
			locatingParentResourceWith: ordersRequestHandler resourceLocator;
		whenAccepting: ZnMimeType textPlain decodeApplying: [ :comment | comment ];
		whenResponding: ZnMimeType textPlain
			encodeApplying: [ :resource | self encodeComments: resource ];
		whenResponding: ZnMimeType applicationJson 
			encodeToJsonApplying: [ :resource :context :writer |  ];
		createEntityTagHashingEncodedResource;
		directCachingWith: [ :caching | 
			caching
				whenSharedBeStaleAfter: 10 minutes;
				whenSharedMustRevalidate
			];
		build
]

{ #category : #initialization }
PetOrdersRESTfulController >> initializeOrdersRequestHandler [

	ordersRequestHandler := RESTfulRequestHandlerBuilder new
		handling: 'orders'
			locatingResourcesWith: [ :order :requestContext | ordersRepository identifierOf: order ]
			extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ];
		beHypermediaDrivenBy:
				[ :builder :order :requestContext :orderLocation | self affect: builder withMediaControlsFor: order locatedAt: orderLocation ];
		whenAccepting: self orderVersion1dot0dot0MediaType
			decodeFromJsonApplying: [ :json :reader | self configureOrderDecodingOn: reader ];
		whenResponding: self orderVersion1dot0dot0MediaType
			encodeToJsonApplying: [ :resource :requestContext :writer | self configureOrderEncodingOn: writer within: requestContext ]
			as: #Order;
		createEntityTagHashing: [ :hasher :order :requestContext | 
			hasher
				include: ( ordersRepository identifierOf: order );
				include: ( ordersRepository lastModificationOf: order )
			];
		directCachingWith: [ :caching | caching beAvailableFor: 1 minute ];
		build
]

{ #category : #initialization }
PetOrdersRESTfulController >> initializePersistingTo: aPetRepository [

	ordersRepository := aPetRepository.
	commentsByOrderId := Dictionary new.
	self
		initializeOrdersRequestHandler;
		initializeCommentsRequestHandler
]

{ #category : #'API - comments' }
PetOrdersRESTfulController >> orderCommentBasedOn: httpRequest within: requestContext [

	^ commentsRequestHandler
		from: httpRequest
		within: requestContext
		get:
			[ :commentIndex | ( self commentsForOrderIn: httpRequest ) at: commentIndex ifAbsent: [ ObjectNotFound signal ] ]
]

{ #category : #'API - comments' }
PetOrdersRESTfulController >> orderCommentsBasedOn: httpRequest within: requestContext [

	^ commentsRequestHandler
		from: httpRequest
		within: requestContext
		getCollection: [ ( self commentsForOrderIn: httpRequest ) asArray ]
]

{ #category : #private }
PetOrdersRESTfulController >> orderVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'order' vendoredBy: 'stargate' version: '1.0.0'
]

{ #category : #private }
PetOrdersRESTfulController >> requestHandler [

	^ ordersRequestHandler
]

{ #category : #configuring }
PetOrdersRESTfulController >> serverUrl: aServerUrl [

	super serverUrl: aServerUrl.
	commentsRequestHandler serverUrl: aServerUrl
]

{ #category : #private }
PetOrdersRESTfulController >> typeIdConstraint [

	^ IsInteger
]

{ #category : #'API - comments' }
PetOrdersRESTfulController >> updateOrderCommentBasedOn: httpRequest within: requestContext [

	^ commentsRequestHandler
		from: httpRequest
		within: requestContext
		get: [ :index | 
			requestContext hold: index under: #commentIndex.
			( self commentsForOrderIn: httpRequest ) at: index ifAbsent: [ ObjectNotFound signal ]
			]
		thenUpdateWith: [ :oldComment :newComment | 
			( self commentsForOrderIn: httpRequest )
				at: ( requestContext objectUnder: #commentIndex )
				put: newComment.
			newComment
			]
]
