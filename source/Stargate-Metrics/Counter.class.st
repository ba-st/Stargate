"
A counter is a cumulative metric that represents a single monotonically increasing counter whose value can only increase or be reset to zero on restart. 

For example, you can use a counter to represent the number of requests served, tasks completed, or errors.
Do not use a counter to expose a value that can decrease. For example, do not use a counter for the number of currently running processes; instead use a gauge.
"
Class {
	#name : #Counter,
	#superclass : #Metric,
	#instVars : [
		'name',
		'description',
		'value'
	],
	#category : #'Stargate-Metrics'
}

{ #category : #'instance creation' }
Counter class >> named: aMetricName describedBy: aMetricDescription withValue: aNumber [

	AssertionCheckerBuilder new
		raising: InstanceCreationFailed;
		checking: [ :asserter | 
			asserter
				enforce: [ aMetricName notEmpty ] because: 'A metric name cannot be empty';
				enforce: [ aMetricDescription notEmpty ] because: 'A metric description cannot be empty';
				enforce: [ aNumber positive ] because: 'Counters value can only increase or be equal to 0'
			];
		buildAndCheck.

	^ self new initializeNamed: aMetricName describedBy: aMetricDescription withValue: aNumber
]

{ #category : #accessing }
Counter >> description [

	^ description
]

{ #category : #initialization }
Counter >> initializeNamed: aMetricName describedBy: aMetricDescription withValue: aNumber [

	name := aMetricName.
	description := aMetricDescription.
	value := aNumber
]

{ #category : #accessing }
Counter >> name [

	^ name
]

{ #category : #printing }
Counter >> printDetailsOn: stream [

	value printOn: stream
]

{ #category : #accessing }
Counter >> type [
	
	^ self class
]

{ #category : #accessing }
Counter >> value [

	^ value
]
