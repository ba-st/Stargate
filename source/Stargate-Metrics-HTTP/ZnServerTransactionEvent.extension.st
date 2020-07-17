Extension { #name : #ZnServerTransactionEvent }

{ #category : #'*Stargate-Metrics-HTTP' }
ZnServerTransactionEvent >> method [

	^ request method
]

{ #category : #'*Stargate-Metrics-HTTP' }
ZnServerTransactionEvent >> responseCode [

	^ response code
]

{ #category : #'*Stargate-Metrics-HTTP' }
ZnServerTransactionEvent >> url [

	^ request url
]

{ #category : #'*Stargate-Metrics-HTTP' }
ZnServerTransactionEvent >> urlTemplate [

	^ request urlTemplateIfAbsent: [ '' ]
]
