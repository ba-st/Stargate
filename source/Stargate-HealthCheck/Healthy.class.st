Class {
	#name : #Healthy,
	#superclass : #HealthCondition,
	#instVars : [
		'concern'
	],
	#category : #'Stargate-HealthCheck'
}

{ #category : #'instance creation' }
Healthy class >> onHealthCheckNamed: aName [

	^ self new initializeOnHealthCheckNamed: aName
]

{ #category : #accessing }
Healthy >> concern [

	^ concern
]

{ #category : #testing }
Healthy >> hasSucceeded [

	^ true
]

{ #category : #initialization }
Healthy >> initializeOnHealthCheckNamed: aName [

	concern := aName
]

{ #category : #accessing }
Healthy >> riskScore [

	^ 1
]
