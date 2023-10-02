Extension { #name : #ZnServerTransactionEvent }

{ #category : #'*Stargate-Metrics-HTTP-Zinc-Extensions' }
ZnServerTransactionEvent >> method [

	^ request method
]

{ #category : #'*Stargate-Metrics-HTTP-Zinc-Extensions' }
ZnServerTransactionEvent >> responseCode [

	^ response code
]

{ #category : #'*Stargate-Metrics-HTTP-Zinc-Extensions' }
ZnServerTransactionEvent >> url [

	^ request url
]

{ #category : #'*Stargate-Metrics-HTTP-Zinc-Extensions' }
ZnServerTransactionEvent >> urlTemplate [

	^ request urlTemplateIfAbsent: [ '' ]
]
