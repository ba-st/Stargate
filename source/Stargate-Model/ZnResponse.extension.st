Extension { #name : #ZnResponse }

{ #category : #'*Stargate-Model' }
ZnResponse >> addLink: aLink [

	self headers at: 'Link' add: aLink
]

{ #category : #'*Stargate-Model' }
ZnResponse >> links [

	| links |

	links := self headers at: 'Link' ifAbsent: [ ^ #() ].
	^ links isCollection
		ifTrue: [ links ]
		ifFalse: [ Array with: links ]
]
