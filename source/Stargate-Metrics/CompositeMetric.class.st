"
I'm a metric composed of other metrics. I was supposed to be constructed using CompositeMetricBuilder.
"
Class {
	#name : #CompositeMetric,
	#superclass : #Metric,
	#instVars : [
		'metrics'
	],
	#category : #'Stargate-Metrics'
}

{ #category : #'instance creation' }
CompositeMetric class >> withAll: aMetricCollection [

	AssertionChecker
		enforce: [ aMetricCollection notEmpty ]
		because: 'A composite metric must have at least one metric'
		raising: InstanceCreationFailed.
		
	^ self new initializeWith: aMetricCollection
]

{ #category : #private }
CompositeMetric >> anyMetric [

	^ metrics first
]

{ #category : #accessing }
CompositeMetric >> description [

	^ self anyMetric description
]

{ #category : #initialization }
CompositeMetric >> initializeWith: aMetricCollection [

	metrics := aMetricCollection 
]

{ #category : #accessing }
CompositeMetric >> metrics [

	^ metrics
]

{ #category : #accessing }
CompositeMetric >> name [
	
	^ self anyMetric name
]

{ #category : #printing }
CompositeMetric >> printDetailsOn: stream [

	metrics
		do: [ :metric | 
			stream tab.
			metric printDetailsOn: stream
			]
		separatedBy: [ stream cr ]
]

{ #category : #accessing }
CompositeMetric >> type [

	^ self anyMetric type
]

{ #category : #accessing }
CompositeMetric >> value [

	^ metrics inject: 0 into: [ :sum :metric | sum + metric value ]
]
