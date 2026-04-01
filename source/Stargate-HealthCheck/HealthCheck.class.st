"
I'm an abstract class representing health checks
"
Class {
	#name : 'HealthCheck',
	#superclass : 'Object',
	#category : 'Stargate-HealthCheck',
	#package : 'Stargate-HealthCheck'
}

{ #category : 'running' }
HealthCheck >> run [

	self subclassResponsibility
]
