"
A GarbageCollectionMetricsTest is a test class for testing the behavior of GarbageCollectionMetrics
"
Class {
	#name : #GarbageCollectionMetricsTest,
	#superclass : #TestCase,
	#category : #'Stargate-Metrics-Tests'
}

{ #category : #private }
GarbageCollectionMetricsTest >> assertGarbageCollectionCountMetrics: composite [

	self
		assert: composite name equals: 'Garbage Collector invokations';
		assert: composite description equals: 'Number of times the garbage collector was invoked';
		assert: composite type equals: Counter;
		assert: composite metrics size equals: 2.
	composite metrics
		do: [ :timestamped | 
			self
				assert: timestamped timestamp <= DateAndTime now;
				assert: timestamped value isNumber;
				withTheOnlyOneIn: timestamped metric labels
					do: [ :label | self assert: ( timestamped metric labelAt: #type ) notEmpty ]
			]
]

{ #category : #private }
GarbageCollectionMetricsTest >> assertGarbageCollectionTimeMetrics: composite [

	self
		assert: composite name equals: 'Garbage Collection Time in Milliseconds';
		assert: composite description
			equals: 'Cumulative number of milliseconds spent on Garbage Collection';
		assert: composite type equals: Counter;
		assert: composite metrics size equals: 2.
	composite metrics
		do: [ :timestamped | 
			self
				assert: timestamped timestamp <= DateAndTime now;
				assert: timestamped value isNumber;
				withTheOnlyOneIn: timestamped metric labels
					do: [ :label | self assert: ( timestamped metric labelAt: #type ) notEmpty ]
			]
]

{ #category : #private }
GarbageCollectionMetricsTest >> assertTenureCountMetrics: counter [

	self
		assert: counter name equals: 'Tenured objects count';
		assert: counter description
			equals: 'Cummulative number of objects tenured by the Garbage Collector';
		assert: counter type equals: Counter;
		assert: counter value positive
]

{ #category : #test }
GarbageCollectionMetricsTest >> testGatherMetrics [

	| metrics |

	metrics := GarbageCollectionMetrics new gatherMetrics.
	self assert: metrics size equals: 3.
	self
		assertGarbageCollectionTimeMetrics: metrics first;
		assertGarbageCollectionCountMetrics: metrics second;
		assertTenureCountMetrics: metrics last
]
