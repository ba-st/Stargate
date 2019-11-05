Class {
	#name : #HealthCheckPlugin,
	#superclass : #OperationalPlugin,
	#instVars : [
		'healthChecks'
	],
	#category : #'Stargate-HealthCheck'
}

{ #category : #'instance creation' }
HealthCheckPlugin class >> configuredBy: configuration [

	^ self new
]

{ #category : #accessing }
HealthCheckPlugin class >> endpoint [

	^ 'health-check'
]

{ #category : #'instance creation' }
HealthCheckPlugin class >> new [

	^ self runningAll: #()
]

{ #category : #accessing }
HealthCheckPlugin class >> pluginName [

	^ 'Health Check'
]

{ #category : #'instance creation' }
HealthCheckPlugin class >> running: aHealthCheck [

	^ self runningAll: {aHealthCheck}
]

{ #category : #'instance creation' }
HealthCheckPlugin class >> runningAll: aHealthCheckCollection [

	^ self basicNew initializeRunningAll: aHealthCheckCollection
]

{ #category : #configuring }
HealthCheckPlugin >> includeControllersIn: api [

	api
		addController: ( HealthCheckRESTfulController over: self configuredBy: api operationsConfiguration )
]

{ #category : #initalize }
HealthCheckPlugin >> initializeRunningAll: aHealthCheckCollection [

	healthChecks := aHealthCheckCollection
]

{ #category : #printing }
HealthCheckPlugin >> printOn: stream [

	stream nextPutAll: self name
]

{ #category : #actions }
HealthCheckPlugin >> runHealthChecks [

	^ healthChecks
		inject: OverallHealthCondition new
		into: [ :status :check | 
			status
				addCondition: check run;
				yourself
			]
]
