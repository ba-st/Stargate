Extension { #name : #CharacterCollection }

{ #category : #'*Stargate-GS64-Extensions' }
CharacterCollection >> asWebOrigin [ 

	^ self asUrl asWebOrigin 
]

{ #category : #'*Stargate-GS64-Extensions' }
CharacterCollection >> asOpaqueEntityTag [

  ^ EntityTag with: self
]
