"
I'm an example RESTful Controller implementing Pet Order resource management
"
Class {
	#name : #PetOrdersRESTfulController,
	#superclass : #SingleResourceRESTfulController,
	#instVars : [
		'ordersRepository',
		'requestHandler'
	],
	#category : #'Stargate-Examples'
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
		ifTrue: [ builder addLink: location / 'cancel' asUrl relatedTo: 'cancel' ]
]

{ #category : #API }
PetOrdersRESTfulController >> cancelOrderBasedOn: httpRequest within: requestContext [

	^ requestHandler
		with: [ ordersRepository findIdentifiedBy: ( self identifierIn: httpRequest ) ]
		do: [ :order | ordersRepository updateStatusOf: order to: 'canceled' ]
		basedOn: httpRequest
		within: requestContext
]

{ #category : #routes }
PetOrdersRESTfulController >> cancelOrderRoute [

	^ RouteSpecification
		handling: #POST
		at: self cancelTemplate
		evaluating: [ :httpRequest :requestContext | self cancelOrderBasedOn: httpRequest within: requestContext ]
]

{ #category : #private }
PetOrdersRESTfulController >> cancelTemplate [

	^ '<1s>/cancel' expandMacrosWith: self identifierTemplate
]

{ #category : #API }
PetOrdersRESTfulController >> completeOrderBasedOn: httpRequest within: requestContext [

	^ requestHandler
		with: [ ordersRepository findIdentifiedBy: ( self identifierIn: httpRequest ) ]
		do: [ :order | ordersRepository updateStatusOf: order to: 'completed' ]
		basedOn: httpRequest
		within: requestContext
]

{ #category : #routes }
PetOrdersRESTfulController >> completeOrderRoute [

	^ RouteSpecification
		handling: #POST
		at: self completeTemplate
		evaluating: [ :httpRequest :requestContext | self completeOrderBasedOn: httpRequest within: requestContext ]
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
		for: PetOrder
			do: [ :mapping | 
			mapping
				mapInstVars;
				mapProperty: #status getter: [ :object | requestContext objectUnder: #status ];
				mapAsHypermediaControls: [ :pet | requestContext hypermediaControlsFor: pet ]
			]
]

{ #category : #API }
PetOrdersRESTfulController >> createOrderBasedOn: anHttpRequest within: aContext [

	^ requestHandler
		withCreatedResourceDo: [ :order | 
			ordersRepository store: order.
			aContext hold: ( ordersRepository statusOf: order ) under: #status.
			order
			]
		basedOn: anHttpRequest
		within: aContext
]

{ #category : #routes }
PetOrdersRESTfulController >> createOrderRoute [

	^ RouteSpecification
		handling: #POST
		at: self endpoint
		evaluating: [ :httpRequest :requestContext | self createOrderBasedOn: httpRequest within: requestContext ]
]

{ #category : #API }
PetOrdersRESTfulController >> getOrderBasedOn: httpRequest within: requestContext [

	^ requestHandler
		get: [ 
			| order |
			order := ordersRepository findIdentifiedBy: ( self identifierIn: httpRequest ).
			requestContext hold: ( ordersRepository statusOf: order ) under: #status.
			order
			]
		basedOn: httpRequest
		within: requestContext
]

{ #category : #routes }
PetOrdersRESTfulController >> getOrderRoute [

	^ RouteSpecification
		handling: #GET
		at: self identifierTemplate
		evaluating: [ :httpRequest :requestContext | self getOrderBasedOn: httpRequest within: requestContext ]
]

{ #category : #initialization }
PetOrdersRESTfulController >> initializePersistingTo: aPetRepository [

	ordersRepository := aPetRepository.
	self initializeRequestHandler
]

{ #category : #initialization }
PetOrdersRESTfulController >> initializeRequestHandler [

	requestHandler := RESTfulRequestHandlerBuilder new
		endpoint: 'orders';
		calculateLocationUsing: [ :order :requestContext | ordersRepository identifierOf: order ];
		beHypermediaDrivenBy:
				[ :builder :order :requestContext :orderLocation | self affect: builder withMediaControlsFor: order locatedAt: orderLocation ];
		whenAccepting: self orderVersion1dot0dot0MediaType
			decodeFromJsonApplying: [ :json :reader | self configureOrderDecodingOn: reader ];
		whenResponding: self orderVersion1dot0dot0MediaType
			encodeToJsonApplying: [ :resource :requestContext :writer | self configureOrderEncodingOn: writer within: requestContext ];
		createEntityTagHashing: [ :hasher :order :requestContext | 
			hasher
				include: ( ordersRepository identifierOf: order );
				include: ( ordersRepository lastModificationOf: order )
			];
		build
]

{ #category : #private }
PetOrdersRESTfulController >> orderVersion1dot0dot0MediaType [

	^ self jsonMediaType: 'order' vendoredBy: 'stargate' version: '1.0.0'
]

{ #category : #private }
PetOrdersRESTfulController >> requestHandler [

	^ requestHandler
]

{ #category : #private }
PetOrdersRESTfulController >> typeIdConstraint [

	^ IsInteger
]
