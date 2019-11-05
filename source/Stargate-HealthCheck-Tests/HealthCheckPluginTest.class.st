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
HealthCheckPluginTest >> testEnabledByDefault [

	self assert: HealthCheckPlugin enabledByDefault
]

{ #category : #'tests - running' }
HealthCheckPluginTest >> testHealthCheckMix [

	| healthCondition |

	healthCondition := ( HealthCheckPlugin
		runningAll:
			( Array with: self failedHealthCheck with: self successfulHealthCheck with: self warningHealthCheck ) )
		runHealthChecks.

	self assert: healthCondition isCritical
]

{ #category : #'tests - running' }
HealthCheckPluginTest >> testHealthCheckSucceedingWithWarnings [

	| healthCondition |

	healthCondition := ( HealthCheckPlugin
		runningAll: ( Array with: self successfulHealthCheck with: self warningHealthCheck ) )
		runHealthChecks.

	self assert: healthCondition isNotCritical
]

{ #category : #'tests - running' }
HealthCheckPluginTest >> testNoHealthChecksConfigured [

	| healthCondition |

	healthCondition := HealthCheckPlugin new runHealthChecks.

	self assert: healthCondition isNotCritical
]

{ #category : #test }
HealthCheckPluginTest >> testPrintOn [

	self assert: HealthCheckPlugin new printString equals: 'Health Check'
]

{ #category : #'tests - running' }
HealthCheckPluginTest >> testSingleHealthCheckFailing [

	| healthCondition |

	healthCondition := ( HealthCheckPlugin running: self failedHealthCheck ) runHealthChecks.

	self assert: healthCondition isCritical
]

{ #category : #'tests - running' }
HealthCheckPluginTest >> testSingleHealthCheckSucceeding [

	| healthCondition |

	healthCondition := ( HealthCheckPlugin running: self successfulHealthCheck ) runHealthChecks.

	self assert: healthCondition isNotCritical
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
