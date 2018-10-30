Extension { #name : #ZnRequest }

{ #category : #'*Stargate-Model' }
ZnRequest >> setIfMatchTo: etag [

	self headers at: 'If-Match' put: etag asString
]

{ #category : #'*Stargate-Model' }
ZnRequest >> setIfNoneMatchTo: etag [

	self headers at: 'If-None-Match' put: etag asString
]
