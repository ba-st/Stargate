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

{ #category : #testing }
CriticalHealth >> hasSucceeded [

	^ false
]

{ #category : #initialization }
CriticalHealth >> initializeDetailedBy: aDetailsObject onHealthCheckNamed: aName [

	details := aDetailsObject.
	concern := aName
]

{ #category : #accessing }
CriticalHealth >> riskScore [

	^ 3
]
