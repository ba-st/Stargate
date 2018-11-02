"
I'm an example RESTful Web Service implementing Pet Order resource management
"
Class {
	#name : #PetOrdersRESTfulWebService,
	#superclass : #RESTfulWebService,
	#instVars : [
		'orders',
		'nextId',
		'orderById',
		'orderStatus',
		'updateTimestamps'
	],
	#category : #'Stargate-Examples'
}

{ #category : #API }
PetOrdersRESTfulWebService >> cancelOrderBasedOn: anHttpRequest within: aContext [

	^ self updateOrderStatusBasedOn: anHttpRequest within: aContext with: [ self updateOrderStatusAt: (self identifierIn: anHttpRequest) to: 'canceled' ]
]

{ #category : #API }
PetOrdersRESTfulWebService >> completeOrderBasedOn: anHttpRequest within: aContext [

	^ self updateOrderStatusBasedOn: anHttpRequest within: aContext with: [ self updateOrderStatusToCompletedBasedOn: anHttpRequest ]
]

{ #category : #API }
PetOrdersRESTfulWebService >> createOrderBasedOn: anHttpRequest within: aContext [

	^ self
		withCreatedResourceDo: [ :order | 
			orders add: order.
			self recordIdAndUpdateTimestampFor: order.
			nextId := nextId + 1.
			order ]
		decodedUsing: self specification orderMappingKey
		basedOn: anHttpRequest
		within: aContext
]

{ #category : #'private - accessing' }
PetOrdersRESTfulWebService >> defaultPaginationLimit [

	^ 10
]

{ #category : #'private - accessing' }
PetOrdersRESTfulWebService >> entityTagOf: aPetOrder encodedAs: mediaType [

	^ ZnETag
		with:
			(SHA1 new
				hashMessage:
					('<1s>-<2s>-<3s>'
						expandMacrosWith: (self identifierOf: aPetOrder) asString
						with: (self lastModificationOf: aPetOrder) asString
						with: mediaType asString)) hex
]

{ #category : #API }
PetOrdersRESTfulWebService >> getOrderBasedOn: anHttpRequest within: aContext [

	^ self
		get: [ aContext hold: (orderStatus at: (self identifierIn: anHttpRequest)) under: #status.
			self orderIdentifiedUsing: anHttpRequest ]
		encodedUsing: self specification orderMappingKey
		basedOn: anHttpRequest
		within: aContext
]

{ #category : #'private - accessing' }
PetOrdersRESTfulWebService >> identifierIn: anHttpRequest [

	^ anHttpRequest at: #identifier
]

{ #category : #'private - accessing' }
PetOrdersRESTfulWebService >> identifierOf: aPetOrder [

	^ orderById keyAtValue: aPetOrder
]

{ #category : #initialization }
PetOrdersRESTfulWebService >> initialize [

	super initialize.
	orders := OrderedCollection new.
	orderById := IdentityDictionary new.
	orderStatus := IdentityDictionary new.
	updateTimestamps := IdentityDictionary new.
	nextId := 1
]

{ #category : #'private - accessing' }
PetOrdersRESTfulWebService >> lastModificationOf: aPetOrder [

	^ updateTimestamps at: (self identifierOf: aPetOrder)
]

{ #category : #'private - accessing' }
PetOrdersRESTfulWebService >> locationOf: aPetOrder [

	| baseUrl |

	baseUrl := '' asZnUrl.
	baseUrlOptional withContentDo: [ :theBaseUrl | baseUrl := theBaseUrl ].

	^ baseUrl / self specification endpoint asZnUrl / (self identifierOf: aPetOrder) printString asZnUrl
]

{ #category : #'private - accessing' }
PetOrdersRESTfulWebService >> mediaControlsFor: order [

	| status |

	status := orderStatus at: (orderById keyAtValue: order).
	"In the real life you don't do a case. This is a toy example"
	status = 'registered'
		ifTrue: [ ^ (super mediaControlsFor: order)
				,
					{('cancel' -> ((self locationOf: order) / 'cancel' asUrl)).
					('complete' -> ((self locationOf: order) / 'complete' asUrl))} ].
	status = 'completed'
		ifTrue: [ ^ (super mediaControlsFor: order) , {('cancel' -> ((self locationOf: order) / 'cancel' asUrl))} ].
	^ super mediaControlsFor: order
]

{ #category : #'private - accessing' }
PetOrdersRESTfulWebService >> orderIdentifiedUsing: anHttpRequest [

	^ orderById at: (self identifierIn: anHttpRequest) ifAbsent: [ ObjectNotFound signal ]
]

{ #category : #accessing }
PetOrdersRESTfulWebService >> orders [

	^ orders
]

{ #category : #'private - accessing' }
PetOrdersRESTfulWebService >> provideHypermediaPolicy [

	^ HypermediaDrivenResourcePolicy for: self
]

{ #category : #'private - accessing' }
PetOrdersRESTfulWebService >> providePaginationPolicy [

	^ ResourceIsPaginatedPolicy for: self with: self defaultPaginationLimit
]

{ #category : #'private - API' }
PetOrdersRESTfulWebService >> recordIdAndUpdateTimestampFor: order [

	orderById at: nextId put: order.
	orderStatus at: nextId put: 'registered'.
	"I will simulate a timestamp using a fixed version revision,
	because for the tests it's easier that using the current datetime"
	updateTimestamps at: nextId put: 1
]

{ #category : #specification }
PetOrdersRESTfulWebService >> specification [

	^ PetOrdersRESTfulWebServiceSpecification new
]

{ #category : #'private - API' }
PetOrdersRESTfulWebService >> updateOrderStatusAt: id to: aTargetStatus [

	orderStatus at: id put: aTargetStatus.
	updateTimestamps at: id put: (updateTimestamps at: id) + 1
]

{ #category : #API }
PetOrdersRESTfulWebService >> updateOrderStatusBasedOn: anHttpRequest within: aContext with: anUpdateBlock [

	| response |

	self handleConflictsIn: anUpdateBlock.
	response := ZnResponse noContent.
	self putEntityTagOf: (self orderIdentifiedUsing: anHttpRequest) encodedAs: self specification orderVersion1dot0dot0MediaType in: response.
	^ response
]

{ #category : #'private - API' }
PetOrdersRESTfulWebService >> updateOrderStatusToCompletedBasedOn: anHttpRequest [

	| orderId |

	orderId := self identifierIn: anHttpRequest.
	AssertionChecker enforce: [ (orderStatus at: orderId) = 'registered' ] because: 'Non pending orders cannot be completed.' raising: ConflictingObjectFound.
	self updateOrderStatusAt: orderId to: 'completed'
]
