"
I'm a health check created for testing purposes.
"
Class {
	#name : #TestHealthCheck,
	#superclass : #HealthCheck,
	#instVars : [
		'status'
	],
	#category : #'Stargate-Model-Tests-Operations'
}

{ #category : #'instance creation' }
TestHealthCheck class >> responding: aHealthCheckStatus [

	^ self new initializeResponding: aHealthCheckStatus
]

{ #category : #initialize }
TestHealthCheck >> initializeResponding: aHealthCheckStatus [

	status := aHealthCheckStatus
]

{ #category : #running }
TestHealthCheck >> run [

	^ status
]
