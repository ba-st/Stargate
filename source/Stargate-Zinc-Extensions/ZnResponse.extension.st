Extension { #name : #ZnResponse }

{ #category : #'*Stargate-Zinc-Extensions' }
ZnResponse class >> forbidden [

	^ self statusLine: ZnStatusLine forbidden
]
