"
A RunningSystemMetricsTest is a test class for testing the behavior of RunningSystemMetrics
"
Class {
	#name : #RunningSystemMetricsTest,
	#superclass : #TestCase,
	#category : #'Stargate-Metrics-Tests'
}

{ #category : #private }
RunningSystemMetricsTest >> assertExternalSemaphoreMetrics: composite [

	self
		assert: composite name equals: 'External semaphore count';
		assert: composite description equals: 'External semaphore table related data';
		assert: composite type equals: Counter;
		assert: composite metrics size equals: 3.
	composite metrics
		do: [ :timestamped | 
			self
				assert: timestamped timestamp <= DateAndTime now;
				assert: timestamped value strictlyPositive;
				withTheOnlyOneIn: timestamped metric labels
					do: [ :label | self assert: ( timestamped metric labelAt: #category ) notEmpty ]
			]
]

{ #category : #private }
RunningSystemMetricsTest >> assertProcessMetrics: composite [

	self
		assert: composite name equals: 'Process count';
		assert: composite description equals: 'Number of process scheduled in the running image';
		assert: composite type equals: Gauge;
		assert: composite metrics size strictlyPositive.
	composite metrics
		do: [ :timestamped | 
			self
				assert: timestamped timestamp <= DateAndTime now;
				assert: timestamped value strictlyPositive;
				assert: timestamped metric labels size equals: 2;
				assert: ( timestamped metric labelAt: #status ) notEmpty;
				assert:
					( ( timestamped metric labelAt: #priority )
						between: Processor lowestPriority
						and: Processor timingPriority )
			]
]

{ #category : #private }
RunningSystemMetricsTest >> assertUptimeMetric: counter [

	self
		assert: counter name equals: 'Uptime in seconds';
		assert: counter description equals: 'Number of seconds since the system started.';
		assert: counter type equals: Counter;
		assert: counter value strictlyPositive
]

{ #category : #test }
RunningSystemMetricsTest >> testGatherMetrics [

	| metrics |

	metrics := RunningSystemMetrics new gatherMetrics.
	self assert: metrics size equals: 3.
	self
		assertUptimeMetric: metrics first;
		assertProcessMetrics: metrics second;
		assertExternalSemaphoreMetrics: metrics last
]
