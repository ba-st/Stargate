Extension { #name : #TeaRoute }

{ #category : #'*Stargate-Teapot-Extensions' }
TeaRoute >> isMatchedBy: aTeaRequestMatcher [

	^ requestMatcher isEquivalentTo: aTeaRequestMatcher
]
