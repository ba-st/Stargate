Extension { #name : #ZnStringEntity }

{ #category : #'*Stargate-Model' }
ZnStringEntity class >> json: string [

	^ (self type: ZnMimeType applicationJson)
		string: string;
		yourself
]
