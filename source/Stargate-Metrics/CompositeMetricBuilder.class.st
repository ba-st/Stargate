"
I'm a builder of composite metrics.
"
Class {
	#name : #CompositeMetricBuilder,
	#superclass : #Object,
	#instVars : [
		'metricClass',
		'metrics',
		'nameBinding',
		'descriptionBinding'
	],
	#category : #'Stargate-Metrics'
}

{ #category : #private }
CompositeMetricBuilder class >> creating: aMetricClass [

	^ self new initializeCreating: aMetricClass
]

{ #category : #'instance creation' }
CompositeMetricBuilder class >> forCounter [

	^ self creating: Counter
]

{ #category : #'instance creation' }
CompositeMetricBuilder class >> forGauge [

	^ self creating: Gauge
]

{ #category : #configuring }
CompositeMetricBuilder >> addValue: aNumber labeledBy: labels [

	metrics add: ( self metricOn: aNumber labeledBy: labels )
]

{ #category : #configuring }
CompositeMetricBuilder >> addValue: aNumber labeledBy: labels at: aTimestamp [

	metrics
		add: ( TimestampedMetric over: ( self metricOn: aNumber labeledBy: labels ) at: aTimestamp )
]

{ #category : #building }
CompositeMetricBuilder >> build [
	
	^ CompositeMetric withAll: metrics
]

{ #category : #configuring }
CompositeMetricBuilder >> describedBy: aDescription [

	descriptionBinding := Binding to: aDescription 
]

{ #category : #initialization }
CompositeMetricBuilder >> initializeCreating: aMetricClass [

	metricClass := aMetricClass.
	nameBinding := Binding undefinedExplainedBy: 'Missing name'.
	descriptionBinding := Binding undefinedExplainedBy: 'Missing description'.
	metrics := OrderedCollection new
]

{ #category : #configuring }
CompositeMetricBuilder >> metricOn: aNumber labeledBy: labels [

	^ LabeledMetric
		over:
			( metricClass named: nameBinding content describedBy: descriptionBinding content withValue: aNumber )
		labeledBy: labels
]

{ #category : #configuring }
CompositeMetricBuilder >> named: aName [

	nameBinding := Binding to: aName
]
