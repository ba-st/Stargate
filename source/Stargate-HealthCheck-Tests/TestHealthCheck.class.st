"
I'm a health check created for testing purposes.
"
Class {
	#name : #TestHealthCheck,
	#superclass : #HealthCheck,
	#instVars : [
		'healthCondition'
	],
	#category : #'Stargate-HealthCheck-Tests'
}

{ #category : #'instance creation' }
TestHealthCheck class >> responding: aHealthCondition [

	^ self new initializeResponding: aHealthCondition
]

{ #category : #initialize }
TestHealthCheck >> initializeResponding: aHealthCondition [

	healthCondition := aHealthCondition
]

{ #category : #running }
TestHealthCheck >> run [

	^ healthCondition
]
