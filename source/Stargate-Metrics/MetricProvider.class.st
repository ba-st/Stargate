"
I'm a provider of metrics
"
Class {
	#name : #MetricProvider,
	#superclass : #Object,
	#category : #'Stargate-Metrics'
}

{ #category : #private }
MetricProvider >> currentTimestamp [
		
	^ DateAndTime now
]

{ #category : #calculating }
MetricProvider >> gatherMetrics [

	self subclassResponsibility
]
