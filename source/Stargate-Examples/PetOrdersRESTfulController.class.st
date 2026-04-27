"
I'm an example RESTful Controller implementing Pet Order resource management
"
Class {
	#name : 'PetOrdersRESTfulController',
	#superclass : 'SingleResourceRESTfulController',
	#instVars : [
		'ordersRepository',
		'commentsRequestHandler',
		'commentsByOrderId',
		'ordersRequestHandler',
		'shipmentHistoryRequestHandler',
		'shipmentHistoryByOrderId'
	],
	#category : 'Stargate-Examples-PetStore',
	#package : 'Stargate-Examples',
	#tag : 'PetStore'
}

{ #category : 'instance creation' }
PetOrdersRESTfulController class >> new [

	^ self persistingTo: InMemoryPetOrderRepository  new
]

{ #category : 'instance creation' }
PetOrdersRESTfulController class >> persistingTo: aRepository [

	^ self basicNew initializePersistingTo: aRepository
]

{ #category : 'private' }
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

	builder addLink: location / 'comments' asUrl relatedTo: 'comments'.
	builder addLink: location / 'shipment-history' asUrl relatedTo: 'shipmentHistory'
]

{ #category : 'API - orders' }
PetOrdersRESTfulController >> cancelOrderBasedOn: httpRequest within: requestContext [

	^ ordersRequestHandler
		from: httpRequest
		within: requestContext
		get: [ :id | ordersRepository findIdentifiedBy: id ]
		thenDo: [ :order | ordersRepository updateStatusOf: order to: 'canceled' ]
]

{ #category : 'private' }
PetOrdersRESTfulController >> cancelTemplate [

	^ '<1s>/cancel' expandMacrosWith: self identifierTemplate
]

{ #category : 'private' }
PetOrdersRESTfulController >> commentIdentifierIn: httpRequest [

	^ httpRequest at: self commentIdentifierKey
]

{ #category : 'private' }
PetOrdersRESTfulController >> commentIdentifierKey [

	^ #commentIdentifier asString
]

{ #category : 'private' }
PetOrdersRESTfulController >> commentIdentifierTemplate [

	^ '<1s>/%<<2s>:<3s>>'
		expandMacrosWith: self commentsTemplate
		with: self commentIdentifierKey
		with: self typeIdConstraint asString
]

{ #category : 'private' }
PetOrdersRESTfulController >> commentsForOrderIn: httpRequest [

	^ commentsByOrderId at: ( self identifierIn: httpRequest ) ifAbsent: [ #() ]
]

{ #category : 'private' }
PetOrdersRESTfulController >> commentsTemplate [

	^ '<1s><2s>' expandMacrosWith: self identifierTemplate with: commentsRequestHandler endpoint
]

{ #category : 'API - orders' }
PetOrdersRESTfulController >> completeOrderBasedOn: httpRequest within: requestContext [

	^ ordersRequestHandler
		from: httpRequest
		within: requestContext
		get: [ :id | ordersRepository findIdentifiedBy: id ]
		thenDo: [ :order | ordersRepository updateStatusOf: order to: 'completed' ]
]

{ #category : 'private' }
PetOrdersRESTfulController >> completeTemplate [

	^ '<1s>/complete' expandMacrosWith: self identifierTemplate
]

{ #category : 'private' }
PetOrdersRESTfulController >> configureOrderDecodingOn: reader [

	reader for: #Url customDo: [ :mapping | mapping decoder: [ :string | string asUrl ] ].
	reader for: PetOrder createInstanceUsing: [ :mapping |
		mapping
			mapProperty: #date;
			mapProperty: #pet as: #Url.
		mapping mapCreationSending: #for:on: withArguments: { #pet. #date }
		].

	^ reader nextAs: PetOrder
]

{ #category : 'private' }
PetOrdersRESTfulController >> configureOrderEncodingOn: writer within: requestContext [

	writer
		for: Pet do: [ :mapping | mapping mapInstVars ];
		for: ZnUrl customDo: [ :mapping | mapping encoder: [ :url | url printString ] ];
		for: #Order do: [ :mapping |
			mapping
				mapProperty: #pet getter: #pet;
				mapProperty: #date getter: #date;
				mapProperty: #status getter: [ :object | requestContext objectUnder: #status ];
				mapAsHypermediaControls: [ :order | requestContext hypermediaControlsFor: order ]
			]
]

{ #category : 'private' }
PetOrdersRESTfulController >> configureOverlyComplexOrderDecodingOn: reader [

	reader for: #Status customDo: [ :mapping | mapping decoder: [ :string | string asUppercase ] ].
	reader for: Pet createInstanceUsing: [ :mapping |
		mapping
			mapProperty: #alternativeName;
			mapProperty: #itsType;
			mapProperty: #theStatus as: #Status.
		mapping
			mapCreationSending: #named:ofType:withStatus:
			withArguments: { #alternativeName. #itsType. #theStatus };
			argumentNamed: #theStatus defaultingTo: 'UNKNOWN'
		].
	reader for: PetOrder createInstanceUsing: [ :mapping |
		mapping
			mapProperty: #date;
			mapProperty: #pet as: Pet.
		mapping mapCreationSending: #for:on: withArguments: { #pet. #date }
		].

	^ reader nextAs: PetOrder
]

{ #category : 'API - comments' }
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

{ #category : 'API - orders' }
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

{ #category : 'API - shipment history' }
PetOrdersRESTfulController >> createShipmentHistoryEntryBasedOn: httpRequest within: requestContext [

  ^ shipmentHistoryRequestHandler
      withResourceCreatedFrom: httpRequest
      within: requestContext
      do: [ :historyEntry |
          | orderId order history |
          orderId := self identifierIn: httpRequest.
          order := ordersRepository findIdentifiedBy: orderId.
          requestContext parentResource: order.
          history := shipmentHistoryByOrderId at: orderId ifAbsentPut: [ OrderedCollection new ].
          history add: historyEntry.
          historyEntry
        ]
]

{ #category : 'routes' }
PetOrdersRESTfulController >> declareAddOrderShipmentHistoryEntryCommentRoute [

  ^ RouteSpecification
      handling: #POST
      at: self shipmentHistoryTemplate
      evaluating: [ :httpRequest :requestContext |
          self createShipmentHistoryEntryBasedOn: httpRequest within: requestContext ]
]

{ #category : 'routes' }
PetOrdersRESTfulController >> declareCancelOrderRoute [

	^ RouteSpecification
		handling: #POST
		at: self cancelTemplate
		evaluating: [ :httpRequest :requestContext | self cancelOrderBasedOn: httpRequest within: requestContext ]
]

{ #category : 'routes' }
PetOrdersRESTfulController >> declareCompleteOrderRoute [

	^ RouteSpecification
		handling: #POST
		at: self completeTemplate
		evaluating: [ :httpRequest :requestContext | self completeOrderBasedOn: httpRequest within: requestContext ]
]

{ #category : 'routes' }
PetOrdersRESTfulController >> declareCreateOrderCommentRoute [

	^ RouteSpecification
		handling: #POST
		at: self commentsTemplate
		evaluating: [ :httpRequest :requestContext | self createCommentBasedOn: httpRequest within: requestContext ]
]

{ #category : 'routes' }
PetOrdersRESTfulController >> declareCreateOrderRoute [

	^ RouteSpecification
		handling: #POST
		at: self endpoint
		evaluating: [ :httpRequest :requestContext | self createOrderBasedOn: httpRequest within: requestContext ]
]

{ #category : 'routes' }
PetOrdersRESTfulController >> declareDeleteOrderCommentRoute [

	^ RouteSpecification
		handling: #DELETE
		at: self commentIdentifierTemplate
		evaluating:
			[ :httpRequest :requestContext | self deleteOrderCommentBasedOn: httpRequest within: requestContext ]
]

{ #category : 'routes' }
PetOrdersRESTfulController >> declareGetOrderCommentRoute [

	^ RouteSpecification
		handling: #GET
		at: self commentIdentifierTemplate
		evaluating: [ :httpRequest :requestContext | self orderCommentBasedOn: httpRequest within: requestContext ]
]

{ #category : 'routes' }
PetOrdersRESTfulController >> declareGetOrderCommentsRoute [

	^ RouteSpecification
		handling: #GET
		at: self commentsTemplate
		evaluating: [ :httpRequest :requestContext | self orderCommentsBasedOn: httpRequest within: requestContext ]
]

{ #category : 'routes' }
PetOrdersRESTfulController >> declareGetOrderRoute [

	^ RouteSpecification
		handling: #GET
		at: self identifierTemplate
		evaluating: [ :httpRequest :requestContext | self getOrderBasedOn: httpRequest within: requestContext ]
]

{ #category : 'routes' }
PetOrdersRESTfulController >> declareGetOrderShipmentHistoryRoute [

  ^ RouteSpecification
      handling: #GET
      at: self shipmentHistoryTemplate
      evaluating: [ :httpRequest :requestContext |
          self orderShipmentHistoryBasedOn: httpRequest within: requestContext ]
]

{ #category : 'routes' }
PetOrdersRESTfulController >> declareUpdateOrderCommentRoute [

	^ RouteSpecification
		handling: #PUT
		at: self commentIdentifierTemplate
		evaluating:
			[ :httpRequest :requestContext | self updateOrderCommentBasedOn: httpRequest within: requestContext ]
]

{ #category : 'API - comments' }
PetOrdersRESTfulController >> deleteOrderCommentBasedOn: httpRequest within: requestContext [

	^ commentsRequestHandler
		from: httpRequest
		within: requestContext
		get: [ :index | ( self commentsForOrderIn: httpRequest ) at: index ifAbsent: [ ObjectNotFound signal ] ]
		thenDo: [ :comment | ( self commentsForOrderIn: httpRequest ) remove: comment ]
]

{ #category : 'private' }
PetOrdersRESTfulController >> encodeComments: resource [

	^ resource isArray
		ifTrue: [ ( CollectionFormatter
				separatingWith: '<n>' expandMacros
				applyingToEach: [ :comment | '- <1s>' expandMacrosWith: comment ] ) format: resource
			]
		ifFalse: [ resource asString ]
]

{ #category : 'API - orders' }
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

{ #category : 'initialization' }
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

{ #category : 'initialization' }
PetOrdersRESTfulController >> initializeOrdersRequestHandler [

	ordersRequestHandler := RESTfulRequestHandlerBuilder new
		                        handling: 'orders'
		                        locatingResourcesWith: [ :order :requestContext |
			                        ordersRepository identifierOf: order ]
		                        extractingIdentifierWith: [ :httpRequest | self identifierIn: httpRequest ];
		                        beHypermediaDrivenBy: [ :builder :order :requestContext :orderLocation |
			                        self affect: builder withMediaControlsFor: order locatedAt: orderLocation ];
		                        whenAccepting: self orderVersion1dot0dot0MediaType
		                        decodeFromJsonApplying: [ :json :reader |
			                        self configureOrderDecodingOn: reader ];
		                        whenAccepting: self overlyComplexOrderVersion1dot0dot0MediaType
		                        decodeFromJsonApplying: [ :json :reader |
			                        self configureOverlyComplexOrderDecodingOn: reader ];
		                        whenResponding: self orderVersion1dot0dot0MediaType
		                        encodeToJsonApplying: [ :resource :requestContext :writer |
			                        self configureOrderEncodingOn: writer within: requestContext ]
		                        as: #Order;
		                        createEntityTagHashing: [ :hasher :order :requestContext |
			                        hasher
				                        include: ( ordersRepository identifierOf: order );
				                        include: ( ordersRepository lastModificationOf: order )
			                        ];
		                        directCachingWith: [ :caching | caching beAvailableFor: 1 minute ];
		                        build
]

{ #category : 'initialization' }
PetOrdersRESTfulController >> initializePersistingTo: aPetRepository [

	ordersRepository := aPetRepository.
	commentsByOrderId := Dictionary new.
	shipmentHistoryByOrderId := Dictionary new.
	self
		initializeOrdersRequestHandler;
		initializeCommentsRequestHandler;
		initializeShipmentHistoryRequestHandler
]

{ #category : 'initialization' }
PetOrdersRESTfulController >> initializeShipmentHistoryRequestHandler [

  shipmentHistoryRequestHandler := RESTfulRequestHandlerBuilder new
                                     handling: 'shipment-history'
                                     locatingSubresourcesWith: [ :historyEntry :requestContext |
                                         ( shipmentHistoryByOrderId at:
                                               ( ordersRepository identifierOf:
                                                     requestContext parentResource ) ) indexOf:
                                             historyEntry
                                       ]
                                     extractingIdentifierWith: [ :httpRequest |
                                         httpRequest at: #shipmentHistoryIdentifier asString ]
                                     locatingParentResourceWith:
                                       ordersRequestHandler resourceLocator;
                                     beHypermediaDriven;
                                     handleExceptionsApplying: [ :handler |
                                         handler addAsDecodingError: AssertionFailed ];
                                     whenAccepting: self shipmentHistoryVersion1dot0dot0MediaType
                                     decodeFromJsonApplying: [ :json :reader |
                                         PetOrderShipmentHistoryEntry describedBy:
                                             ( NeoJSONObject fromString: json ) description ];
                                     whenResponding: self shipmentHistoryVersion1dot0dot0MediaType
                                     encodeToJsonApplying: [ :resource :requestContext :writer |
                                         writer
                                           for: PetOrderShipmentHistoryEntry
                                           do: [ :mapping | mapping mapAccessor: #description ].
                                         self
                                       ]
                                     as: PetOrderShipmentHistoryEntry;
                                     createEntityTagHashingEncodedResource;
                                     directCachingWith: [ :caching | caching beAvailableFor: 1 hour ];
                                     build
]

{ #category : 'API - comments' }
PetOrdersRESTfulController >> orderCommentBasedOn: httpRequest within: requestContext [

	^ commentsRequestHandler
		from: httpRequest
		within: requestContext
		get:
			[ :commentIndex | ( self commentsForOrderIn: httpRequest ) at: commentIndex ifAbsent: [ ObjectNotFound signal ] ]
]

{ #category : 'API - comments' }
PetOrdersRESTfulController >> orderCommentsBasedOn: httpRequest within: requestContext [

	^ commentsRequestHandler
		from: httpRequest
		within: requestContext
		getCollection: [ ( self commentsForOrderIn: httpRequest ) asArray ]
]

{ #category : 'API - shipment history' }
PetOrdersRESTfulController >> orderShipmentHistoryBasedOn: httpRequest within: requestContext [

  | order |
  order := ordersRepository findIdentifiedBy: ( self identifierIn: httpRequest ).
  requestContext parentResource: order.

  ^ shipmentHistoryRequestHandler
      from: httpRequest
      within: requestContext
      getCollection: [ ( self shipmentHistoryForOrderIn: httpRequest ) asArray ]
]

{ #category : 'private' }
PetOrdersRESTfulController >> orderVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'order' vendoredBy: 'stargate' version: '1.0.0'
]

{ #category : 'private' }
PetOrdersRESTfulController >> overlyComplexOrderVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'overly-complex-order' vendoredBy: 'stargate' version: '1.0.0'
]

{ #category : 'private' }
PetOrdersRESTfulController >> requestHandler [

	^ ordersRequestHandler
]

{ #category : 'configuring' }
PetOrdersRESTfulController >> serverUrl: aServerUrl [

	super serverUrl: aServerUrl.
	commentsRequestHandler serverUrl: aServerUrl
]

{ #category : 'private' }
PetOrdersRESTfulController >> shipmentHistoryForOrderIn: httpRequest [

	^ shipmentHistoryByOrderId at: ( self identifierIn: httpRequest ) ifAbsent: [ #() ]
]

{ #category : 'private' }
PetOrdersRESTfulController >> shipmentHistoryTemplate [

  ^ '<1s><2s>'
      expandMacrosWith: self identifierTemplate
      with: shipmentHistoryRequestHandler endpoint
]

{ #category : 'private' }
PetOrdersRESTfulController >> shipmentHistoryVersion1dot0dot0MediaType [

  ^ self jsonMediaType: 'shipment-history' vendoredBy: 'stargate' version: '1.0.0'
]

{ #category : 'private' }
PetOrdersRESTfulController >> typeIdConstraint [

	^ IsInteger
]

{ #category : 'API - comments' }
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
