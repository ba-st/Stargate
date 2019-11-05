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

{ #category : #testing }
Sick >> hasSucceeded [

	^ true
]

{ #category : #initalize }
Sick >> initializeDetailedBy: aDetailsObject onHealthCheckNamed: aName [

	details := aDetailsObject.
	concern := aName
]

{ #category : #accessing }
Sick >> riskScore [

	^ 2
]
