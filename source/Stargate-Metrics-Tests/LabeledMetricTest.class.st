"
A LabeledMetricTest is a test class for testing the behavior of LabeledMetric
"
Class {
	#name : #LabeledMetricTest,
	#superclass : #TestCase,
	#category : #'Stargate-Metrics-Tests'
}

{ #category : #tests }
LabeledMetricTest >> testAccessing [

	| metric |

	metric := LabeledMetric
		over:
			( Counter named: 'HTTP requests total' describedBy: 'Number of HTTP requests received' withValue: 3 )
		labeledBy:
			{ #method -> 'POST' . #returnCode -> 400 }.

	self
		assert: metric name equals: 'HTTP requests total';
		assert: metric description equals: 'Number of HTTP requests received';
		assert: metric value equals: 3;
		assert: ( metric labelAt: #method ) equals: 'POST';
		assert: ( metric labelAt: #returnCode ) equals: 400
]
