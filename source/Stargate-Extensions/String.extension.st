Extension { #name : #String }

{ #category : #'*Stargate-Extensions' }
String >> asWebOrigin [ 

	^ self asUrl asWebOrigin 
]
