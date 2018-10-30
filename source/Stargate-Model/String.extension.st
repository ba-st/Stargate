Extension { #name : #String }

{ #category : #'*Stargate-Model' }
String >> asETag [

	^ ZnETag fromString: self
]

{ #category : #'*Stargate-Model' }
String >> asMediaType [

	^ self asZnMimeType
]
