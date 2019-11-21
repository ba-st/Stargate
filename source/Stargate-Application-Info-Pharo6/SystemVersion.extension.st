Extension { #name : #SystemVersion }

{ #category : #'*Stargate-Application-Info-Pharo6' }
SystemVersion >> build [

	^ self highestUpdate
]

{ #category : #'*Stargate-Application-Info-Pharo6' }
SystemVersion >> commitHash [

	^ ''
]

{ #category : #'*Stargate-Application-Info-Pharo6' }
SystemVersion >> dottedMajorMinorPatch [

	^ self dottedMajorMinor
]
