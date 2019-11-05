Extension { #name : #ZnResponse }

{ #category : #'*Stargate-Model' }
ZnResponse class >> forbidden [

	^ self statusLine: ZnStatusLine forbidden
]
