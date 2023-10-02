Extension { #name : #Teapot }

{ #category : #'*Stargate-Teapot-Extensions' }
Teapot >> addRouteMatchedBy: aTeaRequestMatcher action: aTeaAction [

	current := dynamicRouter addRoute: ( TeaRoute matcher: aTeaRequestMatcher
			             action: aTeaAction
			             transformer: defaultOutput
			             port: server port )
]

{ #category : #'*Stargate-Teapot-Extensions' }
Teapot >> afterFilters [
	
	^ compositeRouter afterFilters
	
]

{ #category : #'*Stargate-Teapot-Extensions' }
Teapot >> beforeFilters [
	
	^ compositeRouter beforeFilters
	
]

{ #category : #'*Stargate-Teapot-Extensions' }
Teapot >> removeRoutesMatchedBy: aTeaRequestMatcher [

	dynamicRouter removeRoutesMatchedBy: aTeaRequestMatcher
]

{ #category : #'*Stargate-Teapot-Extensions' }
Teapot >> routes [
	
	^ dynamicRouter routes
]
