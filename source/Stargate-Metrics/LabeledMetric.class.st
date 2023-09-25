"
I'm a metric that assigns labels to another metric
"
Class {
	#name : #LabeledMetric,
	#superclass : #Metric,
	#instVars : [
		'metric',
		'labels'
	],
	#category : #'Stargate-Metrics'
}

{ #category : #'instance creation' }
LabeledMetric class >> over: aMetric labeledBy: labelingOptions [

	^ self new initializeOver: aMetric labeledBy: labelingOptions asOrderedDictionary 
]

{ #category : #accessing }
LabeledMetric >> description [

	^ metric description
]

{ #category : #initialization }
LabeledMetric >> initializeOver: aMetric labeledBy: aLabelMap [

	metric := aMetric.
	labels := aLabelMap
]

{ #category : #accessing }
LabeledMetric >> labelAt: aLabelName [

	^ labels at: aLabelName
]

{ #category : #accessing }
LabeledMetric >> labels [

	^ labels
]

{ #category : #accessing }
LabeledMetric >> metric [

	^ metric
]

{ #category : #accessing }
LabeledMetric >> name [

	^ metric name
]

{ #category : #printing }
LabeledMetric >> printDetailsOn: stream [

	stream nextPut: $[.
	labels keysAndValuesDo: [ :key :value |
		stream nextPut: $#.
		stream nextPutAll: key asString.
		stream nextPut: $=.
		value printOn: stream
		].
	stream nextPut: $].
	stream space.
	metric printDetailsOn: stream
]

{ #category : #accessing }
LabeledMetric >> type [

	^ metric type
]

{ #category : #accessing }
LabeledMetric >> value [

	^ metric value
]
