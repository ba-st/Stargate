Extension { #name : #String }

{ #category : #'*Stargate-Model' }
String >> asMediaType [

	^ self asZnMimeType
]
