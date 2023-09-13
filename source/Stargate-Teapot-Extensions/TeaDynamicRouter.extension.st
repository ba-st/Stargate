Extension { #name : #TeaDynamicRouter }

{ #category : #'*Stargate-Teapot-Extensions' }
TeaDynamicRouter >> removeRoutesMatchedBy: aTeaRequestMatcher [

	routes removeAllSuchThat: [ :route | route isMatchedBy: aTeaRequestMatcher ]
]
