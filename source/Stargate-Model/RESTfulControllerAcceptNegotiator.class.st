"
I will provide the best representation (media type) to use for processing an HTTP Request given an available media type list
"
Class {
	#name : #RESTfulControllerAcceptNegotiator,
	#superclass : #Object,
	#instVars : [
		'availableMediaTypes'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #'instance creation' }
RESTfulControllerAcceptNegotiator class >> basedOn: aMediaTypeCollection [

	^ self new initializeBasedOn: aMediaTypeCollection
]

{ #category : #'private - accessing' }
RESTfulControllerAcceptNegotiator >> acceptableMediaTypesIn: anHttpRequest [

	| acceptHeaderContent |

	"Per RFC 2616: If no Accept header field is present, then it is assumed that the client accepts all media types."
	acceptHeaderContent := [ anHttpRequest accept ]
		on: KeyNotFound
		do: [ :signal | signal return: '*/*' ].

	^ acceptHeaderContent isArray
		then: [ acceptHeaderContent
				flatCollect: [ :acceptList | self splitMediaTypesIn: acceptList ]
				as: OrderedCollection
			]
		otherwise: [ self splitMediaTypesIn: acceptHeaderContent ]
]

{ #category : #querying }
RESTfulControllerAcceptNegotiator >> bestRepresentationFor: anHttpRequest [

	"This method returns the best suited representation for the given request"

	self withAcceptableMediaTypesIn: anHttpRequest do: [ :mediaType | (self sortByPrecedence: (self mediaTypesAvailableFor: mediaType)) ifNotEmpty: [ :availableTypes | ^ availableTypes first ] ].
	HTTPNotAcceptable signal: 'Cannot generate a response entity with acceptable characteristics.' accepting: availableMediaTypes
]

{ #category : #'initialize - release' }
RESTfulControllerAcceptNegotiator >> initializeBasedOn: aMediaTypeCollection [

	availableMediaTypes := aMediaTypeCollection 
]

{ #category : #'private - accessing' }
RESTfulControllerAcceptNegotiator >> mediaTypesAvailableFor: aMediaType [

	^ availableMediaTypes
		select: [ :available | 
			(available accepts: aMediaType)
				and: [ self versionIn: aMediaType canBeHandledBy: available ] ]
]

{ #category : #'private - accessing' }
RESTfulControllerAcceptNegotiator >> precedenceFor: aMediaType [

	| precedence version versionParts |

	aMediaType main = '*'
		ifTrue: [ ^ 1 ].
	aMediaType sub = '*'
		ifTrue: [ ^ 2 ].
	precedence := 3.
	(aMediaType isVendorSpecific and: [ aMediaType sub includes: $+ ])
		ifTrue: [ precedence := precedence + 1 ].
	version := aMediaType parameterAt: 'version' ifAbsent: [ ^ precedence ].
	precedence := precedence + 2.
	versionParts := version splitOn: $..
	precedence := precedence + versionParts size.
	versionParts doWithIndex: [ :part :index | precedence := precedence + (part asInteger * (2 raisedTo: 4 - index)) ].

	^ precedence
]

{ #category : #'private - accessing' }
RESTfulControllerAcceptNegotiator >> sortByPrecedence: mediaTypes [

	^ mediaTypes sorted: [ :mediaType | self precedenceFor: mediaType ] descending
]

{ #category : #'private - accessing' }
RESTfulControllerAcceptNegotiator >> splitMediaTypesIn: acceptList [

	^ ( acceptList splitOn: ',' ) collect: [ :type | type asMediaType ]
]

{ #category : #'private - accessing' }
RESTfulControllerAcceptNegotiator >> versionIn: acceptable canBeHandledBy: available [

	| acceptVersion availableVersion acceptVersionParts availableVersionParts |

	acceptVersion := acceptable parameterAt: 'version' ifAbsent: [ ^ true ].
	availableVersion := available parameterAt: 'version' ifAbsent: [ ^ false ].
	acceptVersionParts := acceptVersion splitOn: $..
	availableVersionParts := availableVersion splitOn: $..
	acceptVersionParts
		doWithIndex: [ :acceptPart :index | 
			| availablePart |
			availablePart := availableVersionParts at: index.
			acceptPart ~= availablePart
				ifTrue: [ ^ false ] ].
	^ true
]

{ #category : #'private - accessing' }
RESTfulControllerAcceptNegotiator >> withAcceptableMediaTypesIn: anHttpRequest do: aBlock [

	| acceptable grouped |

	"Parse accept header"
	acceptable := self acceptableMediaTypesIn: anHttpRequest.	
	"Group it by quality"
	grouped := acceptable groupedBy: [ :mediaType | mediaType quality ].	
	"Iterate it by max to minimum quality and for each quality group by precedence"
	grouped keys sorted reverse
		do: [ :quality | ( self sortByPrecedence: ( grouped at: quality ) ) do: aBlock ]
]
