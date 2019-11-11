"
A CounterTest is a test class for testing the behavior of Counter
"
Class {
	#name : #CounterTest,
	#superclass : #TestCase,
	#category : #'Stargate-Metrics-Tests'
}

{ #category : #tests }
CounterTest >> testAccessing [

	| counter |

	counter := Counter
		named: 'tenure count'
		describedBy: 'The number of objects that has been tenured'
		withValue: 125000.

	self
		assert: counter name equals: 'tenure count';
		assert: counter description equals: 'The number of objects that has been tenured';
		assert: counter value equals: 125000
]

{ #category : #tests }
CounterTest >> testCountersDontAcceptNegativeValues [

	self
		should: [ Counter
				named: 'tenure count'
				describedBy: 'The number of objects that has been tenured'
				withValue: -1
			]
		raise: InstanceCreationFailed
		withMessageText: 'Counters value can only increase or be equal to 0'
]

{ #category : #tests }
CounterTest >> testCountersMustHaveADescription [

	self
		should: [ Counter named: 'tenure count' describedBy: '' withValue: 1 ]
		raise: InstanceCreationFailed
		withMessageText: 'A metric description cannot be empty'
]

{ #category : #tests }
CounterTest >> testCountersMustHaveAName [

	self
		should: [ Counter named: '' describedBy: 'The number of objects that has been tenured' withValue: 1 ]
		raise: InstanceCreationFailed
		withMessageText: 'A metric name cannot be empty'
]

{ #category : #tests }
CounterTest >> testPrintString [

	| counter |

	counter := Counter
		named: 'tenure count'
		describedBy: 'The number of objects that has been tenured'
		withValue: 125000.

	self
		assert: counter printString
		equals:
			'tenure count
The number of objects that has been tenured
125000'
]
