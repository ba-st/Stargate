Extension { #name : #HttpRequestContext }

{ #category : #'*Stargate-Deprecated-V3' }
HttpRequestContext >> addPaginationControl: aControl [

	| controls |

	self deprecated: 'Use addPaginationControls: and the provided media control builder'.
	controls := self
		objectUnder: #paginationLinks
		ifNone: [ self hold: OrderedCollection new under: #paginationLinks ].
	controls add: aControl
]

{ #category : #'*Stargate-Deprecated-V3' }
HttpRequestContext >> holdAsHypermediaControls: aControlCollection [

	self deprecated: 'Use #holdAsHypermediaControls:for:'.
	self error: 'Do not supported anymore, always hold the media controls related to some resource'
]

{ #category : #'*Stargate-Deprecated-V3' }
HttpRequestContext >> holdAsHypermediaControls: aControlCollection forSubresource: aResource [

	self
		deprecated: 'Use #holdAsHypermediaControls:for:'
		transformWith:
			'`@receiver holdAsHypermediaControls: `@aControlCollection forSubresource: `@aResource'
				-> '`@receiver holdAsHypermediaControls: `@aControlCollection for: `@aResource'.

	^ self holdAsHypermediaControls: aControlCollection for: aResource
]

{ #category : #'*Stargate-Deprecated-V3' }
HttpRequestContext >> hypermediaControls [

	self deprecated: 'Use hypermediaControlsFor: with the corresponding resource'.
	self error: 'Not supported anymore. Use the variant receiving the resource'
]
