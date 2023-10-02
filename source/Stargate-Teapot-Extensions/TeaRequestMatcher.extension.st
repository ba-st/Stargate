Extension { #name : #TeaRequestMatcher }

{ #category : #'*Stargate-Teapot-Extensions' }
TeaRequestMatcher >> isEquivalentTo: aRequestMatcher [

	^ self printString = aRequestMatcher printString
]
