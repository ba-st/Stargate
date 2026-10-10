Extension { #name : #String }

{ #category : #'*Stargate-Extensions' }
String >> asWebOrigin [ 

	^ self asUrl asWebOrigin 
]

{ #category : #'*Stargate-Extensions' }
String >> asOpaqueEntityTag [

  ^ EntityTag with: self
]
