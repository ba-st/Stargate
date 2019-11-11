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
		describedBy: 'The number of objects that has been tenured'
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

{ #category : #private }
TimestampedMetricTest >> timestamp [

	^ DateAndTime year: 2020 month: 1 day: 1
]
