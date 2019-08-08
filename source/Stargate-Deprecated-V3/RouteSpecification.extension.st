Extension { #name : #RouteSpecification }

{ #category : #'*Stargate-Deprecated-V3' }
RouteSpecification class >> handling: anHttpMethod at: aUrlTemplate sending: aMessage [

	self deprecated: 'Use #handling:at:evaluating: instead with a block'.
	self error: 'Unsupported in V3'
]
