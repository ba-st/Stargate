Extension { #name : #ResourceRESTfulController }

{ #category : #'*Stargate-Deprecated-V3' }
ResourceRESTfulController >> get: aQueryEvaluationBlock asCollectionEncodedUsing: aKey basedOn: anHttpRequest within: aContext [

	self
		deprecated: 'Use #get:asCollectionBasedOn:within:'
		transformWith:
			'`@receiver get: `@aQueryEvaluationBlock asCollectionEncodedUsing: `@aKey basedOn: `@anHttpRequest within: `@aContext'
				->
					'`@receiver requestHandler
		get: `@aQueryEvaluationBlock
		asCollectionBasedOn: `@anHttpRequest
		within: `@aContext'.
	^ self requestHandler
		get: aQueryEvaluationBlock
		asCollectionBasedOn: anHttpRequest
		within: aContext
]

{ #category : #'*Stargate-Deprecated-V3' }
ResourceRESTfulController >> get: aQueryEvaluationBlock encodedUsing: aKey basedOn: anHttpRequest within: aContext [

	self
		deprecated: 'Use #get:basedOn:within:'
		transformWith:
			'`@receiver get: `@aQueryEvaluationBlock encodedUsing: `@aKey basedOn: `@anHttpRequest within: `@aContext'
				->
					'`@receiver requestHandler
		get: `@aQueryEvaluationBlock
		basedOn: `@anHttpRequest
		within: `@aContext'.
	^ self requestHandler get: aQueryEvaluationBlock basedOn: anHttpRequest within: aContext
]

{ #category : #'*Stargate-Deprecated-V3' }
ResourceRESTfulController >> locationOf: resource within: aContext [

	self
		deprecated:
			'This method is no longer a subclassResponsibility, 
			 you can reuse the implementation configuring the handler'.
	^ self error: 'Configure the handler'
]

{ #category : #'*Stargate-Deprecated-V3' }
ResourceRESTfulController >> mediaControlsFor: result within: aContext [

	self
		deprecated:
			'This method is no longer a subclassResponsibility, 
			 you can reuse the implementation configuring the handler'.
	^ self error: 'Configure the handler'
]

{ #category : #'*Stargate-Deprecated-V3' }
ResourceRESTfulController >> provideHypermediaPolicy [

	self
		deprecated:
			'This method is no longer a subclassResponsibility, 
			 you can reuse the implementation configuring the handler'.
	^ self error: 'Configure the handler'
]

{ #category : #'*Stargate-Deprecated-V3' }
ResourceRESTfulController >> providePaginationPolicy [

	self
		deprecated:
			'This method is no longer a subclassResponsibility, 
			 you can reuse the implementation configuring the handler'.
	^ self error: 'Configure the handler'
]

{ #category : #'*Stargate-Deprecated-V3' }
ResourceRESTfulController >> provideResourceCreationPolicy [

	self
		deprecated:
			'This method is no longer a subclassResponsibility, 
			 you can reuse the implementation configuring the handler'.
	^ self error: 'Configure the handler'
]

{ #category : #'*Stargate-Deprecated-V3' }
ResourceRESTfulController >> specification [

	self
		deprecated: 'Specifications are no longer needed. Now the same controller defines the required behavior'.
	^ self
]

{ #category : #'*Stargate-Deprecated-V3' }
ResourceRESTfulController >> withCreatedResourceDo: aBlock decodedUsing: aKey basedOn: anHttpRequest within: aContext [

	self
		deprecated: 'Use #withDecodedResourceDo:basedOn:within:'
		transformWith:
			'`@receiver withCreatedResourceDo: `@aQueryEvaluationBlock decodedUsing: `@aKey basedOn: `@anHttpRequest within: `@aContext'
				->
					'`@receiver requestHandler
		withCreatedResourceDo: `@aQueryEvaluationBlock
		basedOn: `@anHttpRequest
		within: `@aContext'.
	^ self requestHandler withCreatedResourceDo: aBlock basedOn: anHttpRequest within: aContext
]
