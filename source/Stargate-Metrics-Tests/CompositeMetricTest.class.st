"
A CompositeMetricTest is a test class for testing the behavior of CompositeMetric
"
Class {
	#name : #CompositeMetricTest,
	#superclass : #TestCase,
	#category : #'Stargate-Metrics-Tests'
}

{ #category : #tests }
CompositeMetricTest >> testPrintSting [

	| metric |

	metric := CompositeMetricBuilder forCounter
		named: 'tenure count';
		describedBy: 'The number of objects that have been tenured';
		addValue: 12500 labeledBy: #() asDictionary;
		build.

	self
		assert: metric printString
		equals:
			'tenure count
The number of objects that have been tenured
	[] 12500'
]
