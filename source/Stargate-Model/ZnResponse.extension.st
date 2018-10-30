Extension { #name : #ZnResponse }

{ #category : #'*Stargate-Model' }
ZnResponse >> addLink: aLink [

	self headers at: 'Link' add: aLink
]

{ #category : #'*Stargate-Model' }
ZnResponse >> entityTag [

	^ (self headers at: 'ETag') asETag
]

{ #category : #'*Stargate-Model' }
ZnResponse >> links [

	| links |

	links := self headers at: 'Link' ifAbsent: [ ^ #() ].
	^ links isCollection
		ifTrue: [ links ]
		ifFalse: [ Array with: links ]
]

{ #category : #'*Stargate-Model' }
ZnResponse >> setEntityTag: aStringORETag [

	self headers at: 'ETag' put: aStringORETag asETag asString
]
