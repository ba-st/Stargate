Extension { #name : #Teapot }

{ #category : #'*Stargate-Model' }
Teapot >> addRouteMatchedBy: aTeaRequestMatcher action: aTeaAction [

	current := dynamicRouter addRoute: ( TeaRoute matcher: aTeaRequestMatcher
			             action: aTeaAction
			             transformer: defaultOutput
			             port: server port )
]

{ #category : #'*Stargate-Model' }
Teapot >> removeRoutesMatchedBy: aTeaRequestMatcher [

	dynamicRouter removeRoutesMatchedBy: aTeaRequestMatcher
]
