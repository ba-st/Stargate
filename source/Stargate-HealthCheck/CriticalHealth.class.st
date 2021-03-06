"
I represent a critical health condition. An API in this state is unable to work correctly.
"
Class {
	#name : #CriticalHealth,
	#superclass : #HealthCondition,
	#instVars : [
		'details',
		'concern'
	],
	#category : #'Stargate-HealthCheck'
}

{ #category : #'Instance Creation' }
CriticalHealth class >> detailedBy: aDetailsObject onHealthCheckNamed: aName [

	^ self new initializeDetailedBy: aDetailsObject onHealthCheckNamed: aName
]

{ #category : #accessing }
CriticalHealth >> concern [

	^ concern
]

{ #category : #accessing }
CriticalHealth >> details [

	^ details
]

{ #category : #initialization }
CriticalHealth >> initializeDetailedBy: aDetailsObject onHealthCheckNamed: aName [

	details := aDetailsObject.
	concern := aName
]

{ #category : #testing }
CriticalHealth >> isNotCritical [

	^ false
]

{ #category : #accessing }
CriticalHealth >> riskScore [

	^ 3
]
