"
I'm a provider of metrics related to memory
"
Class {
	#name : #MemoryMetricsProvider,
	#superclass : #MetricsProvider,
	#category : #'Stargate-Metrics'
}

{ #category : #'instance creation' }
MemoryMetricsProvider class >> configuredBy: pluginConfiguration [

	^ self new
]

{ #category : #accessing }
MemoryMetricsProvider class >> providerName [

	^ 'memory'
]

{ #category : #calculating }
MemoryMetricsProvider >> gatherMetrics [

	^ Array with: self memoryAllocation
]

{ #category : #private }
MemoryMetricsProvider >> memoryAllocation [

	^ CompositeMetricBuilder forGauge
		named: 'Smalltalk Memory in Bytes';
		describedBy: 'Number of bytes of memory allocated in each category';
		addValue: Smalltalk vm memorySize
			labeledBy: {( #category -> 'total allocated' )}
			at: self currentTimestamp;
		addValue: Smalltalk vm oldSpace
			labeledBy: {( #category -> 'old space' )}
			at: self currentTimestamp;
		addValue: Smalltalk vm freeOldSpaceSize
			labeledBy: {( #category -> 'free old space' )}
			at: self currentTimestamp;
		addValue: Smalltalk vm edenSpaceSize
			labeledBy: {( #category -> 'eden space' )}
			at: self currentTimestamp;
		addValue: Smalltalk vm youngSpaceSize
			labeledBy: {( #category -> 'young space' )}
			at: self currentTimestamp;
		build
]
