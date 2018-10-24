Extension { #name : #String }

{ #category : #'*Stargate-REST-API' }
String >> asMediaType [

	^ self asZnMimeType
]
