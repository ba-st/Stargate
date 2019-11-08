"
A GaugeTest is a test class for testing the behavior of Gauge
"
Class {
	#name : #GaugeTest,
	#superclass : #TestCase,
	#category : #'Stargate-Metrics-Tests'
}

{ #category : #tests }
GaugeTest >> testAccessing [

	| gauge |

	gauge := Gauge 
		named: 'memory free bytes'
		describedBy: 'The number of bytes of available allocated memory'
		withValue: 125000.

	self
		assert: gauge name equals: 'memory free bytes';
		assert: gauge description equals: 'The number of bytes of available allocated memory';
		assert: gauge value equals: 125000
]

{ #category : #tests }
GaugeTest >> testGaugeValueMustBeANumber [

	self
		should: [ Gauge
				named: 'temperature'
				describedBy: 'The ambient temperature'
				withValue: $a
			]
		raise: InstanceCreationFailed
		withMessageText: 'Gauge value must be numeric'
]

{ #category : #tests }
GaugeTest >> testGaugesMustHaveADescription [

	self
		should: [ Gauge named: 'temperature' describedBy: '' withValue: 1 ]
		raise: InstanceCreationFailed
		withMessageText: 'A metric description cannot be empty'
]

{ #category : #tests }
GaugeTest >> testGaugesMustHaveAName [

	self
		should: [ Gauge named: '' describedBy: 'The ambient temperature' withValue: 1 ]
		raise: InstanceCreationFailed
		withMessageText: 'A metric name cannot be empty'
]
