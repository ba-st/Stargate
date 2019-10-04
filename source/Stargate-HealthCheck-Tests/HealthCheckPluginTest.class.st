"
A HealthCheckPluginTest is a test class for testing the behavior of HealthCheckPlugin
"
Class {
	#name : #HealthCheckPluginTest,
	#superclass : #TestCase,
	#category : #'Stargate-HealthCheck-Tests'
}

{ #category : #private }
HealthCheckPluginTest >> failedHealthCheck [

	^ TestHealthCheck
		responding: ( CriticalHealth detailedBy: self failureDetails onHealthCheckNamed: 'failing' )
]

{ #category : #private }
HealthCheckPluginTest >> failureDetails [

	^ Dictionary new
		at: #message put: 'Low space on disk';
		yourself
]

{ #category : #private }
HealthCheckPluginTest >> successfulHealthCheck [

	^ TestHealthCheck responding: ( Healthy onHealthCheckNamed: 'succeeding' )
]

{ #category : #'tests - running' }
HealthCheckPluginTest >> testHealthCheckSucceedingWithWarnings [

	self
		assert:
			( HealthCheckPlugin
				runningAll: ( Array with: self successfulHealthCheck with: self warningHealthCheck ) )
				runHealthChecks hasSucceeded
]

{ #category : #'tests - running' }
HealthCheckPluginTest >> testNoHealthChecksConfigured [

	self assert: HealthCheckPlugin new runHealthChecks hasSucceeded
]

{ #category : #'tests - running' }
HealthCheckPluginTest >> testSingleHealthCheckFailing [

	self deny: ( HealthCheckPlugin running: self failedHealthCheck ) runHealthChecks hasSucceeded
]

{ #category : #'tests - running' }
HealthCheckPluginTest >> testSingleHealthCheckSucceeding [

	self assert: ( HealthCheckPlugin running: self successfulHealthCheck ) runHealthChecks hasSucceeded
]

{ #category : #private }
HealthCheckPluginTest >> warningDetails [

	^ Dictionary new
		at: #message put: 'Approaching disk low space limit';
		yourself
]

{ #category : #private }
HealthCheckPluginTest >> warningHealthCheck [

	^ TestHealthCheck
		responding: ( Sick detailedBy: self warningDetails onHealthCheckNamed: 'warning' )
]
