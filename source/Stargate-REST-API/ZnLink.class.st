"
I represent a Link Header. 
The Link entity-header field provides a means for serialising one or more links in HTTP headers.  
It is semantically equivalent to the <LINK> element in HTML, as well as the atom:link feed-level element in Atom.

References

	https://tools.ietf.org/html/rfc5988#page-6
"
Class {
	#name : #ZnLink,
	#superclass : #Object,
	#instVars : [
		'parameters',
		'url'
	],
	#category : #'Stargate-REST-API-Zinc'
}

{ #category : #'instance creation' }
ZnLink class >> to: aUrl [

	^ self new initializeTo: aUrl
]

{ #category : #comparing }
ZnLink >> = other [

	^ self class == other class and: [ self url = other url and: [ self hasSameParametersAs: other ] ]
]

{ #category : #testing }
ZnLink >> hasParameters [

	^ parameters notNil and: [ parameters notEmpty ]
]

{ #category : #testing }
ZnLink >> hasSameParametersAs: aLink [

	^ self hasParameters = aLink hasParameters
		and: [self parameters size = aLink parameters size
			and: [self parameters associations allSatisfy: [:each |
				aLink parameters includesAssociation: each]]]
]

{ #category : #comparing }
ZnLink >> hash [

	| hash |

	hash := self url hash.
	self hasParameters
		ifTrue: [ hash := hash bitXor: self parameters hash ].
	^ hash
]

{ #category : #'initialize - release' }
ZnLink >> initializeTo: aUrl [

	url := aUrl
]

{ #category : #parameters }
ZnLink >> parameterAt: key [

	^ self parameterAt: key ifAbsent: [ KeyNotFound signalFor: key ]
]

{ #category : #parameters }
ZnLink >> parameterAt: key ifAbsent: block [

	parameters ifNil: [ ^ block value ].
	^ self parameters at: key ifAbsent: block
]

{ #category : #parameters }
ZnLink >> parameterAt: aKey put: aValue [

	self parameters at: aKey put: aValue
]

{ #category : #parameters }
ZnLink >> parameters [

	parameters ifNil: [ parameters := SmallDictionary new ].
	^ parameters
]

{ #category : #copying }
ZnLink >> postCopy [

	super postCopy.
	parameters := parameters copy
]

{ #category : #printing }
ZnLink >> printOn: stream [

	stream
		nextPut: $<;
		print: url;
		nextPut: $>.
	parameters
		ifNotNil: [ parameters
				keysAndValuesDo: [ :key :value | 
					stream
						nextPut: $;;
						nextPutAll: key;
						nextPut: $=;
						nextPutAll: value ] ]
]

{ #category : #accessing }
ZnLink >> rel [
	
	^self parameterAt: 'rel'
]

{ #category : #parameters }
ZnLink >> rel: aRelation [

	self parameterAt: 'rel' put: aRelation
]

{ #category : #parameters }
ZnLink >> removeParameter: key [

	parameters ifNil: [ ^ self ].
	^ self parameters removeKey: key ifAbsent: [ nil ]
]

{ #category : #accessing }
ZnLink >> url [

	^ url
]
