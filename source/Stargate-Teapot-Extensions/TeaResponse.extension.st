Extension { #name : #TeaResponse }

{ #category : #'*Stargate-Teapot-Extensions' }
TeaResponse class >> noContent [

	^ self code: ZnStatusLine noContent code

]
