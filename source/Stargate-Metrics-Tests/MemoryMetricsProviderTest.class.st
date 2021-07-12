"
A MemoryMetricsTest is a test class for testing the behavior of MemoryMetrics
"
Class {
	#name : #MemoryMetricsProviderTest,
	#superclass : #TestCase,
	#category : #'Stargate-Metrics-Tests'
}

{ #category : #test }
MemoryMetricsProviderTest >> testGatherMetrics [

	| metrics |

	metrics := MemoryMetricsProvider new gatherMetrics.

	self
		withTheOnlyOneIn: metrics
		do: [ :composite | 
			self
				assert: composite name equals: 'Smalltalk Memory in Bytes';
				assert: composite description equals: 'Number of bytes of memory allocated in each category';
				assert: composite type equals: Gauge;
				assert: composite metrics size equals: 5.
			composite metrics
				do: [ :timestamped | 
					self
						assert: timestamped timestamp <= DateAndTime now;
						assert: timestamped value isInteger;
						withTheOnlyOneIn: timestamped metric labels
							do: [ :label | self assert: ( timestamped metric labelAt: #category ) notEmpty ]
					]
			]
]
