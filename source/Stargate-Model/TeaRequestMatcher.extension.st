Extension { #name : #TeaRequestMatcher }

{ #category : #'*Stargate-Model' }
TeaRequestMatcher >> isEquivalentTo: aRequestMatcher [

	^ self printString = aRequestMatcher printString
]
