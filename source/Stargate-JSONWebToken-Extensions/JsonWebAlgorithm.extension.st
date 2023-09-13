Extension { #name : #JsonWebAlgorithm }

{ #category : #'*Stargate-JSONWebToken-Extensions' }
JsonWebAlgorithm class >> supportsAlgorithmNamed: aString [

	^ self allSubclasses anySatisfy: [ :each |
		  each parameterValue = aString ]
]
