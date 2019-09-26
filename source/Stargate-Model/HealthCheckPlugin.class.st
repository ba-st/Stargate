Class {
	#name : #HealthCheckPlugin,
	#superclass : #OperationalPlugin,
	#category : #'Stargate-Model-Operations'
}

{ #category : #accessing }
HealthCheckPlugin class >> endpoint [

	^ 'health-check'
]

{ #category : #accessing }
HealthCheckPlugin class >> pluginName [

	^ 'Health Check'
]
