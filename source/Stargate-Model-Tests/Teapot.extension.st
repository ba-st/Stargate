Extension { #name : #Teapot }

{ #category : #'*Stargate-Model-Tests' }
Teapot >> afterFilters [
	
	^ compositeRouter afterFilters
	
]

{ #category : #'*Stargate-Model-Tests' }
Teapot >> beforeFilters [
	
	^ compositeRouter beforeFilters
	
]

{ #category : #'*Stargate-Model-Tests' }
Teapot >> routes [
	
	^ dynamicRouter routes
]
