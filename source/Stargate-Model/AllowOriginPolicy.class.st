Class {
	#name : #AllowOriginPolicy,
	#superclass : #Object,
	#pools : [
		'CrossOriginResourceSharing'
	],
	#category : #'Stargate-Model-CORS'
}

{ #category : #'configuring headers' }
AllowOriginPolicy >> applyOn: aFilter for: aRequest [

	self subclassResponsibility 
]
