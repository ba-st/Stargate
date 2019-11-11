"
I'm a provider of metrics
"
Class {
	#name : #MetricProvider,
	#superclass : #Object,
	#category : #'Stargate-Metrics'
}

{ #category : #accessing }
MetricProvider class >> allProviderNames [

	^ MetricProvider allSubclasses collect: [ :class | class providerName ] 
]

{ #category : #accessing }
MetricProvider class >> providerName [

	^ self subclassResponsibility
]

{ #category : #private }
MetricProvider >> currentTimestamp [
		
	^ DateAndTime now
]

{ #category : #calculating }
MetricProvider >> gatherMetrics [

	self subclassResponsibility
]