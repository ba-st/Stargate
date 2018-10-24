"
I will provide the best representation (media type) to use for processing an HTTP Request given an available media type list
"
Class {
	#name : #RESTfulWebServiceAcceptNegotiator,
	#superclass : #Object,
	#instVars : [
		'availableMediaTypes'
	],
	#category : #'Stargate-REST-API-Model'
}

{ #category : #'instance creation' }
RESTfulWebServiceAcceptNegotiator class >> basedOn: aMediaTypeCollection [

	^ self new initializeBasedOn: aMediaTypeCollection
]

{ #category : #querying }
RESTfulWebServiceAcceptNegotiator >> bestRepresentationFor: anHttpRequest [

	"This method returns the best suited representation for the given request"

	self withAcceptableMediaTypesIn: anHttpRequest do: [ :mediaType | (self sortByPrecedence: (self mediaTypesAvailableFor: mediaType)) ifNotEmpty: [ :availableTypes | ^ availableTypes first ] ].
	HTTPClientError signalUnsupportedMediaType: 'No media type can be served according to the Accept header'
]

{ #category : #'initialize - release' }
RESTfulWebServiceAcceptNegotiator >> initializeBasedOn: aMediaTypeCollection [

	availableMediaTypes := aMediaTypeCollection 
]

{ #category : #'private - accessing' }
RESTfulWebServiceAcceptNegotiator >> mediaTypesAvailableFor: aMediaType [

	^ availableMediaTypes
		select: [ :available | 
			(available accepts: aMediaType)
				and: [ self versionIn: aMediaType canBeHandledBy: available ] ]
]

{ #category : #'private - accessing' }
RESTfulWebServiceAcceptNegotiator >> precedenceFor: aMediaType [

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
RESTfulWebServiceAcceptNegotiator >> sortByPrecedence: mediaTypes [

	^ (mediaTypes sorted: [ :a :b | (self precedenceFor: a) < (self precedenceFor: b) ]) reversed 
]

{ #category : #'private - accessing' }
RESTfulWebServiceAcceptNegotiator >> versionIn: acceptable canBeHandledBy: available [

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
RESTfulWebServiceAcceptNegotiator >> withAcceptableMediaTypesIn: anHttpRequest do: aBlock [

	| acceptable grouped |

	"Parse accept header"
	acceptable := (anHttpRequest accept splitOn: ',') collect: [ :type | type asMediaType ].
	"Group it by quality"
	grouped := acceptable groupedBy: [ :mediaType | mediaType quality ].
	"Iterate it by max to minimum quality and for each quality group by precedence"
	grouped keys sorted reverse do: [ :quality | (self sortByPrecedence: (grouped at: quality)) do: aBlock ]
]
