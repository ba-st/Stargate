"
I represent a healthy health condition. An API in this state is working correctly.
"
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

{ #category : #accessing }
Healthy >> details [

	^ Dictionary new
]

{ #category : #initialization }
Healthy >> initializeOnHealthCheckNamed: aName [

	concern := aName
]

{ #category : #testing }
Healthy >> isNotCritical [

	^ true
]

{ #category : #accessing }
Healthy >> riskScore [

	^ 1
]
