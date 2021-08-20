Extension { #name : #String }

{ #category : #'*Stargate-Model' }
String >> asWebOrigin [ 

	^ self asUrl asWebOrigin 
]
