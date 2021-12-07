Extension { #name : #TeaDynamicRouter }

{ #category : #'*Stargate-Model' }
TeaDynamicRouter >> removeRoutesMatchedBy: aTeaRequestMatcher [

	routes removeAllSuchThat: [ :route | route isMatchedBy: aTeaRequestMatcher ]
]
