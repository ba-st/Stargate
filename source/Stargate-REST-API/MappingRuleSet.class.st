Class {
	#name : #MappingRuleSet,
	#superclass : #Object,
	#instVars : [
		'decodingRules',
		'encodingRules'
	],
	#category : #'Stargate-REST-API'
}

{ #category : #'instance creation' }
MappingRuleSet class >> consistingOf: encodingRules and: decodingRules [ 
	
	^ self new initializeConsistingOf: encodingRules and: decodingRules 
]

{ #category : #'private - querying' }
MappingRuleSet >> decodingRuleFor: anObjectType withMediaTypeEqualsTo: aMediaType ifNone: ifNoneBlock [

	^ self
		ruleIn: decodingRules
		for: anObjectType
		withMediaTypeEqualsTo: aMediaType
		ifNone: ifNoneBlock
]

{ #category : #'private - querying' }
MappingRuleSet >> defaultDecodingRuleFor: anObjectType withMediaTypeMatching: aMediaType [

	| defaultDecodingRule |

	defaultDecodingRule := self defaultRuleIn: decodingRules for: anObjectType.

	^ ((self does: aMediaType match: defaultDecodingRule mediaType)
		or: [ self isWildcard: aMediaType ])
		ifTrue: [ defaultDecodingRule ]
		ifFalse: [ MappingNotFound signal: 'Decoder not found for given media type' ]
]

{ #category : #'private - querying' }
MappingRuleSet >> defaultEncodingRuleFor: anObjectType withMediaTypeMatching: aMediaType [

	| defaultEncodingRule |

	defaultEncodingRule := self defaultRuleIn: encodingRules for: anObjectType.

	^ ((self does: aMediaType match: defaultEncodingRule mediaType)
		or: [ self isWildcard: aMediaType ])
		ifTrue: [ defaultEncodingRule ]
		ifFalse: [ MappingNotFound signal: 'Encoder not found for given media type' ]
]

{ #category : #'private - querying' }
MappingRuleSet >> defaultRuleIn: mappingRules for: anObjectType [

	^ mappingRules
		detect:
			[ :decodingRule | decodingRule objectType = anObjectType and: [ decodingRule isDefault ] ]
		ifNone: [ MappingNotFound signal ]
]

{ #category : #'private - testing media type' }
MappingRuleSet >> does: aMediaType match: anotherMediaType [

	^ (aMediaType matches: anotherMediaType)
		and: [ self isNotVersioned: aMediaType ]
]

{ #category : #'private - querying' }
MappingRuleSet >> encodingRuleFor: anObjectType withMediaTypeEqualsTo: aMediaType ifNone: ifNoneBlock [

	^ self
		ruleIn: encodingRules 
		for: anObjectType
		withMediaTypeEqualsTo: aMediaType
		ifNone: ifNoneBlock
]

{ #category : #initialization }
MappingRuleSet >> initializeConsistingOf: aCollectionOfEncodingRules and: aCollectionOfDecodingRules [ 
	
	encodingRules := aCollectionOfEncodingRules.
	decodingRules := aCollectionOfDecodingRules
]

{ #category : #'private - testing media type' }
MappingRuleSet >> isNotVersioned: aMediaType [

	^ (aMediaType parameters includesKey: 'version') not
]

{ #category : #'private - testing media type' }
MappingRuleSet >> isWildcard: aMediaType [

	^ {aMediaType main.
	aMediaType sub} allSatisfy: [ :part | part = '*' ]
]

{ #category : #'private - querying' }
MappingRuleSet >> ruleIn: mappingRules for: anObjectType withMediaTypeEqualsTo: aMediaType ifNone: ifNoneBlock [

	^ mappingRules
		detect:
			[ :mappingRule | mappingRule mediaType = aMediaType and: [ mappingRule objectType = anObjectType ] ]
		ifNone: ifNoneBlock
]

{ #category : #querying }
MappingRuleSet >> ruleToDecode: aMediaType to: anObjectType [

	^ self
		decodingRuleFor: anObjectType
		withMediaTypeEqualsTo: aMediaType
		ifNone: [ self defaultDecodingRuleFor: anObjectType withMediaTypeMatching: aMediaType ]
]

{ #category : #querying }
MappingRuleSet >> ruleToEncode: anObjectType to: aMediaType [

	^ self
		encodingRuleFor: anObjectType
		withMediaTypeEqualsTo: aMediaType
		ifNone: [ self
				defaultEncodingRuleFor: anObjectType
				withMediaTypeMatching: aMediaType ]
]
