Extension { #name : #TeaRoute }

{ #category : #'*Stargate-Model' }
TeaRoute >> isMatchedBy: aTeaRequestMatcher [

	^ requestMatcher isEquivalentTo: aTeaRequestMatcher
]
