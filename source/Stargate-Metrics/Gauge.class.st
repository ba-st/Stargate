"
A gauge is a metric that represents a single numerical value that can arbitrarily go up and down.

Gauges are typically used for measured values like temperatures or current memory usage, but also ""counts"" that can go up and down, like the number of concurrent requests.
"
Class {
	#name : #Gauge,
	#superclass : #Metric,
	#instVars : [
		'name',
		'description',
		'value'
	],
	#category : #'Stargate-Metrics'
}

{ #category : #'instance creation' }
Gauge class >> named: aMetricName describedBy: aMetricDescription withValue: aNumber [

	AssertionCheckerBuilder new
		raising: InstanceCreationFailed;
		checking: [ :asserter | 
			asserter
				enforce: [ aMetricName notEmpty ] because: 'A metric name cannot be empty';
				enforce: [ aMetricDescription notEmpty ] because: 'A metric description cannot be empty';
				enforce: [ aNumber isNumber ] because: 'Gauge value must be numeric'
			];
		buildAndCheck.

	^ self new initializeNamed: aMetricName describedBy: aMetricDescription withValue: aNumber
]

{ #category : #accessing }
Gauge >> description [

	^ description
]

{ #category : #initialization }
Gauge >> initializeNamed: aMetricName describedBy: aMetricDescription withValue: aNumber [

	name := aMetricName.
	description := aMetricDescription.
	value := aNumber
]

{ #category : #accessing }
Gauge >> name [

	^ name
]

{ #category : #printing }
Gauge >> printDetailsOn: stream [

	value printOn: stream
]

{ #category : #accessing }
Gauge >> type [

	^ self class
]

{ #category : #accessing }
Gauge >> value [

	^ value
]
