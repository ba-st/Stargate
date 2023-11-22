"
I will provide the best representation (media type) to use for processing an HTTP Request given an available media type list
"
Class {
	#name : 'RESTfulControllerAcceptNegotiator',
	#superclass : 'Object',
	#instVars : [
		'availableMediaTypes',
		'availableLanguageTags'
	],
	#category : 'Stargate-Model-Controllers',
	#package : 'Stargate-Model',
	#tag : 'Controllers'
}

{ #category : 'instance creation' }
RESTfulControllerAcceptNegotiator class >> accepting: aMediaTypeCollection [

	^ self accepting: aMediaTypeCollection inAnyOf: #()
]

{ #category : 'instance creation' }
RESTfulControllerAcceptNegotiator class >> accepting: aMediaTypeCollection inAnyOf: aLanguageTagCollection [

	^ self new initializeAccepting: aMediaTypeCollection inAnyOf: aLanguageTagCollection
]

{ #category : 'private - accessing' }
RESTfulControllerAcceptNegotiator >> acceptableMediaTypesIn: anHttpRequest [

	| acceptHeaderContent |

	acceptHeaderContent :=  anHttpRequest accept .

	^ acceptHeaderContent isArray
		then: [ acceptHeaderContent
				flatCollect: [ :acceptList | self splitMediaTypesIn: acceptList ]
				as: OrderedCollection
			]
		otherwise: [ self splitMediaTypesIn: acceptHeaderContent ]
]

{ #category : 'private - accessing' }
RESTfulControllerAcceptNegotiator >> acceptableQualifiedLanguageRangesIn: anHttpRequest [

	| acceptHeaderContent |

	acceptHeaderContent := [ anHttpRequest acceptLanguage ]
		on: KeyNotFound
		do: [ :signal | signal return: '*' ].

	^ acceptHeaderContent isArray
		then: [ acceptHeaderContent
				flatCollect: [ :acceptList | self splitQualifiedLanguageRangesIn: acceptList ]
				as: OrderedCollection
			]
		otherwise: [ self splitQualifiedLanguageRangesIn: acceptHeaderContent ]
]

{ #category : 'querying' }
RESTfulControllerAcceptNegotiator >> bestLanguageFor: anHttpRequest [

	"This method returns the best suited language tag for the given request"

	self
		withAcceptableLanguageRangesIn: anHttpRequest
		do: [ :languageRange | 
			availableLanguageTags
				detect: [ :languageTag | languageRange matches: languageTag ]
				ifFound: [ :languageTag | ^ languageTag ]
			].
	HTTPNotAcceptable
		signal: 'Cannot generate a response entity with acceptable characteristics.'
		accepting: availableMediaTypes
		inAnyOf: availableLanguageTags
]

{ #category : 'querying' }
RESTfulControllerAcceptNegotiator >> bestRepresentationFor: anHttpRequest [

	"This method returns the best suited representation for the given request"

	self withAcceptableMediaTypesIn: anHttpRequest do: [ :mediaType | (self sortByPrecedence: (self mediaTypesAvailableFor: mediaType)) ifNotEmpty: [ :availableTypes | ^ availableTypes first ] ].
	HTTPNotAcceptable signal: 'Cannot generate a response entity with acceptable characteristics.' accepting: availableMediaTypes
]

{ #category : 'initialize - release' }
RESTfulControllerAcceptNegotiator >> initializeAccepting: aMediaTypeCollection inAnyOf: aLanguageTagCollection [

	availableMediaTypes := aMediaTypeCollection.
	availableLanguageTags := aLanguageTagCollection
]

{ #category : 'private - accessing' }
RESTfulControllerAcceptNegotiator >> mediaTypesAvailableFor: aMediaType [

	^ availableMediaTypes
		select: [ :available | 
			(available accepts: aMediaType)
				and: [ self versionIn: aMediaType canBeHandledBy: available ] ]
]

{ #category : 'private - accessing' }
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
	versionParts := $. split: version.
	precedence := precedence + versionParts size.
	versionParts doWithIndex: [ :part :index | precedence := precedence + (part asInteger * (2 raisedTo: 4 - index)) ].

	^ precedence
]

{ #category : 'private - accessing' }
RESTfulControllerAcceptNegotiator >> sortByPrecedence: mediaTypes [

	^ mediaTypes sorted: [ :mediaType | self precedenceFor: mediaType ] descending
]

{ #category : 'private - accessing' }
RESTfulControllerAcceptNegotiator >> splitMediaTypesIn: acceptList [

	^ ( ',' split: acceptList ) collect: [ :type | type asMediaType ]
]

{ #category : 'private - accessing' }
RESTfulControllerAcceptNegotiator >> splitQualifiedLanguageRangesIn: acceptLanguageList [

	^ ( ',' split: acceptLanguageList )
		inject: OrderedCollection new
		into: [ :qualifiedLanguageRanges :each | 
			"Be lenient here, ignore everything that is garbage in the header"
			[ qualifiedLanguageRanges add: ( QualifiedLanguageRange fromString: each ) ]
				on: Error
				except: MessageNotUnderstood
				do: [ :error | error return ].
			qualifiedLanguageRanges
			]
]

{ #category : 'private - accessing' }
RESTfulControllerAcceptNegotiator >> versionIn: acceptable canBeHandledBy: available [

	| acceptVersion availableVersion acceptVersionParts availableVersionParts |

	acceptVersion := acceptable parameterAt: 'version' ifAbsent: [ ^ true ].
	availableVersion := available parameterAt: 'version' ifAbsent: [ ^ false ].
	acceptVersionParts := $. split: acceptVersion.
	availableVersionParts := $. split: availableVersion.
	acceptVersionParts
		doWithIndex: [ :acceptPart :index | 
			| availablePart |
			availablePart := availableVersionParts at: index.
			acceptPart ~= availablePart
				ifTrue: [ ^ false ] ].
	^ true
]

{ #category : 'private - accessing' }
RESTfulControllerAcceptNegotiator >> withAcceptableLanguageRangesIn: anHttpRequest do: aBlock [

	| acceptable grouped |

	"Parse Accept-Language header"
	acceptable := self acceptableQualifiedLanguageRangesIn: anHttpRequest.	
	"Group it by quality"
	grouped := acceptable groupedBy: [ :qualifiedLanguageRange | qualifiedLanguageRange quality ].	
	"Iterate it by max to minimum quality and for each quality group"
	grouped keys sorted reverse
		do: [ :quality | ( grouped at: quality ) do: [ :qualifiedRange | aBlock value: qualifiedRange range ] ]
]

{ #category : 'private - accessing' }
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
