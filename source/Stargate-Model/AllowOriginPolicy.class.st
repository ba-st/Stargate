Class {
	#name : 'AllowOriginPolicy',
	#superclass : 'Object',
	#category : 'Stargate-Model-CORS',
	#package : 'Stargate-Model',
	#tag : 'CORS'
}

{ #category : 'configuring headers' }
AllowOriginPolicy >> applyOn: aResponse for: aRequest using: aHandler [ 

	self subclassResponsibility 
]
