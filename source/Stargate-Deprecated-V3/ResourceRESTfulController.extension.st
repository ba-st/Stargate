Extension { #name : #ResourceRESTfulController }

{ #category : #'*Stargate-Deprecated-V3' }
ResourceRESTfulController >> get: aQueryEvaluationBlock asCollectionEncodedUsing: aKey basedOn: anHttpRequest within: aContext [

	self
		deprecated: 'Use #from:within:getCollection:'
		transformWith:
			'`@receiver get: `@aQueryEvaluationBlock asCollectionEncodedUsing: `@aKey basedOn: `@anHttpRequest within: `@aContext'
				->
					'`@receiver requestHandler from: `@anHttpRequest within: `@aContext getCollection: `@aQueryEvaluationBlock'.
	^ self requestHandler from: anHttpRequest within: aContext getCollection: aQueryEvaluationBlock
]

{ #category : #'*Stargate-Deprecated-V3' }
ResourceRESTfulController >> get: aQueryEvaluationBlock encodedUsing: aKey basedOn: anHttpRequest within: aContext [

	self
		deprecated: 'Use #get:basedOn:within:'
		transformWith:
			'`@receiver get: `@aQueryEvaluationBlock encodedUsing: `@aKey basedOn: `@anHttpRequest within: `@aContext'
				->
					'`@receiver requestHandler from: `@anHttpRequest within: `@aContext
		get: `@aQueryEvaluationBlock'.
	^ self requestHandler from: anHttpRequest within: aContext get: aQueryEvaluationBlock
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
					'`@receiver requestHandler withResourceCreatedFrom: `@anHttpRequest within: `@aContext do: `@aQueryEvaluationBlock'.
	^ self requestHandler withResourceCreatedFrom: anHttpRequest within: aContext do: aBlock
]
