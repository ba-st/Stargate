Extension { #name : #HTTPBasedRESTfulAPI }

{ #category : #'*Stargate-Deprecated-V6' }
HTTPBasedRESTfulAPI >> beCORSAwareAllowing: origins [

	self
		deprecated: 'Use allowCrossOriginSharingApplying:'
		transformWith:
			'`@receiver beCORSAwareAllowing: `@origins'
				-> '@receiver allowCrossOriginSharingApplying: [:cors | cors allowOnlyFrom: `@origins ]'
]
