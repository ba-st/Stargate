Extension { #name : #ZnRequest }

{ #category : #'*Stargate-Model' }
ZnRequest >> setUrlTemplate: urlTemplate [

	self headers at: #'X-Stargate-URL-Template' put: urlTemplate asString
]

{ #category : #'*Stargate-Model' }
ZnRequest >> urlTemplateIfAbsent: aBlock [

	^ self headers at: #'X-Stargate-URL-Template' ifAbsent: aBlock
]
