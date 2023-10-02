"
A TimestampedMetricTest is a test class for testing the behavior of TimestampedMetric
"
Class {
	#name : #TimestampedMetricTest,
	#superclass : #TestCase,
	#instVars : [
		'basicMetric'
	],
	#category : #'Stargate-Metrics-Tests'
}

{ #category : #running }
TimestampedMetricTest >> setUp [

	super setUp.
	basicMetric := Counter
		named: 'tenure count'
		describedBy: 'The number of objects that have been tenured'
		withValue: 125000
]

{ #category : #tests }
TimestampedMetricTest >> testAccessing [

	| metric |

	metric := TimestampedMetric over: basicMetric at: self timestamp.

	self
		assert: metric name equals: basicMetric name;
		assert: metric description equals: basicMetric description;
		assert: metric value equals: basicMetric value;
		assert: metric timestamp equals: self timestamp
]

{ #category : #tests }
TimestampedMetricTest >> testPrintString [

	| metric |

	metric := TimestampedMetric over: basicMetric at: self timestamp.

	self
		assert: metric printString
		equals:
			'tenure count
The number of objects that have been tenured
2020-01-01T00:00:00+00:00 125000'
]

{ #category : #private }
TimestampedMetricTest >> timestamp [

	^ DateAndTime
		  year: 2020
		  month: 1
		  day: 1
		  hour: 0
		  minute: 0
		  second: 0
		  offset: 0 asDuration
]
