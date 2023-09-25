Class {
	#name : #RunningGemMetrics,
	#superclass : #MetricProvider,
	#category : #'Stargate-Metrics-GS64'
}

{ #category : #'instance creation' }
RunningGemMetrics class >> configuredBy: pluginConfiguration [

	^ self new
]

{ #category : #accessing }
RunningGemMetrics class >> providerName [
	
	^ 'running gem'
]

{ #category : #calculating }
RunningGemMetrics >> gatherMetrics [

	^ { self processesCount }
]

{ #category : #private }
RunningGemMetrics >> groupProcessesByStatusAndPriority [

	| activeProcessData activeProcess groupedProcesses |

	activeProcess := Processor activeProcess.
	activeProcessData := { 'ACTIVE'. activeProcess priority }.

	groupedProcesses := ( Processor allProcesses select: [ :process | process ~~ activeProcess ] )
		                    groupedBy: [ :process |
			                    { process _statusString asUppercase. process priority }
			                    ].
	groupedProcesses at: activeProcessData put: { activeProcess }.
	^ groupedProcesses
]

{ #category : #private }
RunningGemMetrics >> processesCount [

	| builder |

	builder := CompositeMetricBuilder forGauge.
	builder
		named: 'Process count';
		describedBy: 'Number of process scheduled in the running gem'.
	self groupProcessesByStatusAndPriority
		keysAndValuesDo: [ :key :processes | 
			builder
				addValue: processes size
				labeledBy: { #status -> key first . #priority -> key last }
				at: self currentTimestamp
			].
	^ builder build
]
