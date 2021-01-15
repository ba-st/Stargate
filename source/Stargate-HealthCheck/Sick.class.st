"
I represent a sick health condition. An API in this state is still working correctly, but approaching some threshold that can make it unhealthy in short notice.
"
Class {
	#name : #Sick,
	#superclass : #HealthCondition,
	#instVars : [
		'details',
		'concern'
	],
	#category : #'Stargate-HealthCheck'
}

{ #category : #'instance creation' }
Sick class >> detailedBy: aDetailsObject onHealthCheckNamed: aName [

	^ self new initializeDetailedBy: aDetailsObject onHealthCheckNamed: aName
]

{ #category : #accessing }
Sick >> concern [

	^ concern
]

{ #category : #accessing }
Sick >> details [

	^ details
]

{ #category : #initialization }
Sick >> initializeDetailedBy: aDetailsObject onHealthCheckNamed: aName [

	details := aDetailsObject.
	concern := aName
]

{ #category : #testing }
Sick >> isNotCritical [

	^ true
]

{ #category : #accessing }
Sick >> riskScore [

	^ 2
]
