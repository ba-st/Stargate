Extension { #name : #ZnResponse }

{ #category : #'*Stargate-REST-API' }
ZnResponse >> addLink: aLink [

	self headers at: 'Link' add: aLink
]

{ #category : #'*Stargate-REST-API' }
ZnResponse >> links [

	| links |

	links := self headers at: 'Link' ifAbsent: [ ^ #() ].
	^ links isCollection
		ifTrue: [ links ]
		ifFalse: [ Array with: links ]
]
