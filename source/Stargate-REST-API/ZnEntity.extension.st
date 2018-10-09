Extension { #name : #ZnEntity }

{ #category : #'*Stargate-REST-API' }
ZnEntity class >> json: json [

	^ self stringEntityClass json: json
]
