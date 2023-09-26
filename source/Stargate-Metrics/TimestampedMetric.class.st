"
I'm a metric that assigns a timestamp over another metric
"
Class {
	#name : #TimestampedMetric,
	#superclass : #Metric,
	#instVars : [
		'timestamp',
		'metric'
	],
	#category : #'Stargate-Metrics'
}

{ #category : #'instance creation' }
TimestampedMetric class >> over: aMetric at: aTimestamp [

	^ self new initializeOver: aMetric at: aTimestamp
]

{ #category : #accessing }
TimestampedMetric >> description [

	^ metric description
]

{ #category : #initialization }
TimestampedMetric >> initializeOver: aMetric at: aTimestamp [

	metric := aMetric.
	timestamp := aTimestamp
]

{ #category : #accessing }
TimestampedMetric >> metric [

	^ metric
]

{ #category : #accessing }
TimestampedMetric >> name [

	^ metric name
]

{ #category : #printing }
TimestampedMetric >> printDetailsOn: stream [

	timestamp printRoundedOn: stream.
	stream space.
	metric printDetailsOn: stream
]

{ #category : #accessing }
TimestampedMetric >> timestamp [

	^ timestamp
]

{ #category : #accessing }
TimestampedMetric >> type [

	^ metric type
]

{ #category : #accessing }
TimestampedMetric >> value [

	^ metric value
]
