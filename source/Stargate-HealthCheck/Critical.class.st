"
I represent a critical health condition. An API in this state is unable to work correctly.
"
Class {
	#name : #Critical,
	#superclass : #HealthCondition,
	#instVars : [
		'details',
		'concern'
	],
	#category : #'Stargate-HealthCheck'
}

{ #category : #'Instance Creation' }
Critical class >> detailedBy: aDetailsObject onHealthCheckNamed: aName [

	^ self new initializeDetailedBy: aDetailsObject onHealthCheckNamed: aName
]

{ #category : #accessing }
Critical >> concern [

	^ concern
]

{ #category : #accessing }
Critical >> details [

	^ details
]

{ #category : #initialization }
Critical >> initializeDetailedBy: aDetailsObject onHealthCheckNamed: aName [

	details := aDetailsObject.
	concern := aName
]

{ #category : #testing }
Critical >> isNotCritical [

	^ false
]

{ #category : #accessing }
Critical >> riskScore [

	^ 3
]
