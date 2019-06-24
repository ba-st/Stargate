Extension { #name : #HTTPClientError }

{ #category : #'*Stargate-MigrationTo2' }
HTTPClientError class >> signalBadRequest: aFailureExplanation [

	self
		deprecated: 'Use badRequest signal: instead'
		on: '2019-06-19'
		in: #Stargate2
		transformWith: '`@receiver signalBadRequest: `@message' -> '`@receiver badRequest signal: `@message'.

	^ self signal: 400 describedBy: aFailureExplanation
]

{ #category : #'*Stargate-MigrationTo2' }
HTTPClientError class >> signalConflict: aFailureExplanation [

	self
		deprecated: 'Use conflict signal: instead'
		on: '2019-06-19'
		in: #Stargate2
		transformWith: '`@receiver signalConflict: `@message' -> '`@receiver conflict signal: `@message'.

	^self signal: 409 describedBy: aFailureExplanation
]

{ #category : #'*Stargate-MigrationTo2' }
HTTPClientError class >> signalNotFound [

	self
		deprecated: 'Use notFound signal instead'
		on: '2019-06-19'
		in: #Stargate2
		transformWith: '`@receiver signalNotFound' -> '`@receiver notFound signal'.

	^ self signal: 404 describedBy: 'Not found'
]

{ #category : #'*Stargate-MigrationTo2' }
HTTPClientError class >> signalNotFound: aFailureExplanation [

	self
		deprecated: 'Use notFound signal: instead'
		on: '2019-06-19'
		in: #Stargate2
		transformWith: '`@receiver signalNotFound: `@message' -> '`@receiver notFound signal: `@message'.

	^ self signal: 404 describedBy: aFailureExplanation
]

{ #category : #'*Stargate-MigrationTo2' }
HTTPClientError class >> signalPreconditionFailed [

	self
		deprecated: 'Use preconditionFailed signal instead'
		on: '2019-06-19'
		in: #Stargate2
		transformWith: '`@receiver signalPreconditionFailed' -> '`@receiver preconditionFailed signal'.

	^ self
		signal: 428
		describedBy:
			'One or more conditions given in the request header fields evaluated to false when tested on the server.'
]

{ #category : #'*Stargate-MigrationTo2' }
HTTPClientError class >> signalPreconditionRequired: aFailureExplanation [

	self
		deprecated: 'Use preconditionRequired signal: instead'
		on: '2019-06-19'
		in: #Stargate2
		transformWith: '`@receiver signalPreconditionRequired:  `@messageText' -> '`@receiver preconditionRequired signal: `@messageText'.

	^ self signal: 428 describedBy: aFailureExplanation
]

{ #category : #'*Stargate-MigrationTo2' }
HTTPClientError class >> signalUnprocessableEntity: aFailureExplanation [

	self
		deprecated: 'Use unprocessableEntity signal: instead'
		on: '2019-06-19'
		in: #Stargate2
		transformWith:
			'`@receiver signalUnprocessableEntity: `@message'
				-> '`@receiver unprocessableEntity signal: `@message'.

	^ self signal: 422 describedBy: aFailureExplanation
]

{ #category : #'*Stargate-MigrationTo2' }
HTTPClientError class >> signalUnsupportedMediaType: aFailureExplanation [

	self
		deprecated: 'Use unsupportedMediaType signal: instead'
		on: '2019-06-19'
		in: #Stargate2
		transformWith:
			'`@receiver signalUnsupportedMediaType: `@message'
				-> '`@receiver unsupportedMediaType signal: `@message'.
				
	^ self signal: 415 describedBy: aFailureExplanation
]
