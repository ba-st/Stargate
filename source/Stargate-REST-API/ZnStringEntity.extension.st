Extension { #name : #ZnStringEntity }

{ #category : #'*Stargate-REST-API' }
ZnStringEntity class >> json: string [

	^ (self type: ZnMimeType applicationJson)
		string: string;
		yourself
]
