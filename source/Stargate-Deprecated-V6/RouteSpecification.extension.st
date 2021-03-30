Extension { #name : #RouteSpecification }

{ #category : #'*Stargate-Deprecated-V6' }
RouteSpecification >> asCorsAware [

	self
		deprecated: 'CORS has to be configured site-wide since v6'
		transformWith: '`@receiver asCorsAware' -> '@receiver'.

	^ self
]
