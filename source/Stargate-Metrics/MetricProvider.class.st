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

{ #category : #'instance creation' }
MetricProvider class >> configuredBy: pluginConfiguration [

	^ self subclassResponsibility
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

{ #category : #actions }
MetricProvider >> installOn: teapotServer [
]

{ #category : #actions }
MetricProvider >> uninstall [
]
