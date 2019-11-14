"
I'm a provider of metrics related to memory
"
Class {
	#name : #MemoryMetrics,
	#superclass : #MetricProvider,
	#category : #'Stargate-Metrics'
}

{ #category : #accessing }
MemoryMetrics class >> providerName [

	^ 'memory'
]

{ #category : #calculating }
MemoryMetrics >> gatherMetrics [

	^ Array with: self memoryAllocation
]

{ #category : #private }
MemoryMetrics >> memoryAllocation [

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
