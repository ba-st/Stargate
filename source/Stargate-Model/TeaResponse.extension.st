Extension { #name : #TeaResponse }

{ #category : #'*Stargate-Model' }
TeaResponse class >> noContent [

	^ self code: ZnStatusLine noContent code

]
