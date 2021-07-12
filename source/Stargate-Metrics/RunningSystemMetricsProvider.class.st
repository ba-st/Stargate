"
I'm a provider of metrics related to the running system
"
Class {
	#name : #RunningSystemMetricsProvider,
	#superclass : #MetricsProvider,
	#category : #'Stargate-Metrics'
}

{ #category : #'instance creation' }
RunningSystemMetricsProvider class >> configuredBy: pluginConfiguration [

	^ self new
]

{ #category : #accessing }
RunningSystemMetricsProvider class >> providerName [
	
	^ 'running system'
]

{ #category : #private }
RunningSystemMetricsProvider >> externalSemaphores [

	^ CompositeMetricBuilder forCounter
		named: 'External semaphore count';
		describedBy: 'External semaphore table related data';
		addValue: Smalltalk vm maxExternalSemaphores
			labeledBy: { #category -> 'Max External Semaphores in VM' }
			at: self currentTimestamp;
		addValue: ( ExternalSemaphoreTable unprotectedExternalObjects count: #isNil )
			labeledBy: { #category -> 'Free external semaphore table slots' }
			at: self currentTimestamp;
		addValue: ( ExternalSemaphoreTable unprotectedExternalObjects count: #notNil )
			labeledBy: { #category -> 'Used external semaphore table slots' }
			at: self currentTimestamp;
		build
]

{ #category : #calculating }
RunningSystemMetricsProvider >> gatherMetrics [

	^ Array with: self uptime with: self processesCount with: self externalSemaphores
]

{ #category : #private }
RunningSystemMetricsProvider >> groupProcessesByStatusAndPriority [

	| activeProcessData activeProcess groupedProcesses |

	Smalltalk garbageCollectMost.
	activeProcess := Processor activeProcess.
	activeProcessData := Array with: 'ACTIVE' with: activeProcess priority.

	groupedProcesses := [ ( Process allSubInstances copyWithout: activeProcess )
		groupedBy: [ :process | Array with: ( self statusOf: process ) with: process priority ]
	] valueUnpreemptively.
	groupedProcesses at: activeProcessData put: ( Array with: activeProcess ).
	^ groupedProcesses
]

{ #category : #private }
RunningSystemMetricsProvider >> processesCount [

	| builder |

	builder := CompositeMetricBuilder forGauge.
	builder
		named: 'Process count';
		describedBy: 'Number of process scheduled in the running image'.
	self groupProcessesByStatusAndPriority
		keysAndValuesDo: [ :key :processes | 
			builder
				addValue: processes size
				labeledBy: { #status -> key first . #priority -> key last }
				at: self currentTimestamp
			].
	^ builder build
]

{ #category : #private }
RunningSystemMetricsProvider >> statusOf: aProcess [

	aProcess isTerminated
		ifTrue: [ ^ 'TERMINATED' ].
	aProcess isTerminating
		ifTrue: [ ^ 'TERMINATING' ].
	aProcess isSuspended
		ifTrue: [ ^ 'SUSPENDED' ].
	( aProcess suspendingList isKindOf: Semaphore )
		ifTrue: [ ^ 'BLOCKED' ].
	^ 'READY'
]

{ #category : #private }
RunningSystemMetricsProvider >> uptime [

	^ Counter
		named: 'Uptime in seconds'
		describedBy: 'Number of seconds since the system is started.'
		withValue: Time millisecondClockValue / 1000
]
