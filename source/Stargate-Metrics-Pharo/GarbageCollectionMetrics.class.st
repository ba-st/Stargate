"
I'm a provider of metrics related to the garbage collector
"
Class {
	#name : #GarbageCollectionMetrics,
	#superclass : #MetricProvider,
	#category : #'Stargate-Metrics-Pharo'
}

{ #category : #'instance creation' }
GarbageCollectionMetrics class >> configuredBy: pluginConfiguration [

	^ self new
]

{ #category : #accessing }
GarbageCollectionMetrics class >> providerName [

	^ 'garbage collection'
]

{ #category : #private }
GarbageCollectionMetrics >> garbageCollectionCount [

	^ CompositeMetricBuilder forCounter
		named: 'Garbage Collector invocations';
		describedBy: 'Number of times the garbage collector was invoked';
		addValue: Smalltalk vm fullGCCount labeledBy: { #type -> 'full' } at: self currentTimestamp;
		addValue: Smalltalk vm incrementalGCCount
			labeledBy: { #type -> 'incremental' }
			at: self currentTimestamp;
		build
]

{ #category : #private }
GarbageCollectionMetrics >> garbageCollectionTime [

	^ CompositeMetricBuilder forCounter
		named: 'Garbage Collection Time in Milliseconds';
		describedBy: 'Cumulative number of milliseconds spent on Garbage Collection';
		addValue: Smalltalk vm totalFullGCTime labeledBy: { #type -> 'full' } at: self currentTimestamp;
		addValue: Smalltalk vm totalIncrementalGCTime
			labeledBy: { #type -> 'incremental' }
			at: self currentTimestamp;
		build
]

{ #category : #calculating }
GarbageCollectionMetrics >> gatherMetrics [

	^ Array with: self garbageCollectionTime with: self garbageCollectionCount with: self tenuringCount
]

{ #category : #private }
GarbageCollectionMetrics >> tenuringCount [

	^ Counter
		named: 'Tenured objects count'
		describedBy: 'Cumulative number of objects tenured by the Garbage Collector'
		withValue: Smalltalk vm tenureCount
]
