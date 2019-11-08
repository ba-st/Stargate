Class {
	#name : #RunningSystemMetrics,
	#superclass : #MetricProvider,
	#category : #'Stargate-Metrics'
}

{ #category : #calculating }
RunningSystemMetrics >> gatherMetrics [

	^ Array with: self uptime with: self processesCount
]

{ #category : #calculating }
RunningSystemMetrics >> processesCount [

	| allProcesses groupedByPriority |

	allProcesses := Process allSubInstances.
	groupedByPriority := allProcesses groupedBy: [ :process | process priority ].
	self flag: #ToDo
]

{ #category : #private }
RunningSystemMetrics >> uptime [

	^ Counter
		named: 'Uptime in seconds'
		describedBy: 'Number of seconds since the system is started.'
		withValue: Time millisecondClockValue / 1000
]
