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
		'orderStatus'
	],
	#category : #'Stargate-Examples'
}

{ #category : #API }
PetOrdersRESTfulWebService >> cancelOrderBasedOn: anHttpRequest within: aContext [

	orderStatus at: (self identifierIn: anHttpRequest) put: 'canceled'.
	^ ZnResponse noContent
]

{ #category : #API }
PetOrdersRESTfulWebService >> createOrderBasedOn: anHttpRequest within: aContext [

	^ self
		withCreatedResourceDo: [ :order | 
			orders add: order.
			orderById at: nextId put: order.
			orderStatus at: nextId put: 'registered'.
			nextId := nextId + 1.
			order ]
		decodedUsing: self specification orderMappingKey
		basedOn: anHttpRequest
		within: aContext
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

{ #category : #initialization }
PetOrdersRESTfulWebService >> initialize [

	super initialize.
	orders := OrderedCollection new.
	orderById := IdentityDictionary new.
	orderStatus := IdentityDictionary new.
	nextId := 1
]

{ #category : #'private - accessing' }
PetOrdersRESTfulWebService >> locationOf: aPetOrder [

	| baseUrl |

	baseUrl := '' asZnUrl.
	baseUrlOptional withContentDo: [ :theBaseUrl | baseUrl := theBaseUrl ].

	^ baseUrl / self specification endpoint asZnUrl / (orderById keyAtValue: aPetOrder) printString asZnUrl
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

{ #category : #specification }
PetOrdersRESTfulWebService >> specification [

	^ PetOrdersRESTfulWebServiceSpecification new
]
