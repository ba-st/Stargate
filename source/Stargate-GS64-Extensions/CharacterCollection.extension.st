Extension { #name : #CharacterCollection }

{ #category : #'*Stargate-GS64-Extensions' }
CharacterCollection >> asWebOrigin [ 

	^ self asUrl asWebOrigin 
]
