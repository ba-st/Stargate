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

	^ self using: InMemoryPetOrderRepository  new
]

{ #category : #'instance creation' }
PetOrdersRESTfulController class >> using: aRepository [

	^ self basicNew initializeUsing: aRepository
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
PetOrdersRESTfulController >> initializeProcessor [

	requestHandler := RESTfulRequestHandlerBuilder new
		endpoint: 'orders';
		calculateLocationUsing: [ :order :requestContext | ordersRepository identifierOf: order ];
		beHypermediaDrivenBy: [ :order :requestContext :orderLocation | self mediaControlsFor: order locatedAt: orderLocation ];
		decodeFrom: self orderVersion1dot0dot0MediaType
			jsonUsing: [ :json :reader | 
			reader
				for: PetOrder
					do: [ :mapping | 
					mapping
						mapInstVar: #date;
						mapProperty: #pet setter: [ :order :url | order instVarNamed: 'pet' put: url asUrl ]
					];
				nextAs: PetOrder
			];
		encodeTo: self orderVersion1dot0dot0MediaType
			jsonUsing: [ :resource :requestContext :writer | 
			writer
				for: ZnUrl customDo: [ :mapping | mapping encoder: [ :url | url printString ] ];
				for: PetOrder
					do: [ :mapping | 
					mapping
						mapInstVars;
						mapProperty: #status getter: [ :object | requestContext objectUnder: #status ];
						mapAsHypermediaControls: [ :pet | requestContext hypermediaControlsFor: pet ]
					]
			];
		createEntityTagHashing: [ :hasher :order :requestContext | 
			hasher
				include: ( ordersRepository identifierOf: order );
				include: ( ordersRepository lastModificationOf: order )
			];
		build
]

{ #category : #initialization }
PetOrdersRESTfulController >> initializeUsing: aPetRepository [

	ordersRepository := aPetRepository.
	self initializeProcessor
]

{ #category : #initialization }
PetOrdersRESTfulController >> mediaControlsFor: order locatedAt: location [

	| status |

	status := ordersRepository statusOf: order.
	"In the real life you don't do a case. This is a toy example"
	status = 'registered'
		ifTrue: [ 
			^ Array
				with: 'cancel' -> ( location / 'cancel' asUrl )
				with: 'complete' -> ( location / 'complete' asUrl )
			].
	status = 'completed'
		ifTrue: [ ^ Array with: 'cancel' -> ( location / 'cancel' asUrl ) ].
		
	^ #()
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
