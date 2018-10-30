Extension { #name : #ZnRequest }

{ #category : #'*Stargate-Model' }
ZnRequest >> setIfMatchTo: etag [

	self headers at: 'If-Match' put: etag asString
]
