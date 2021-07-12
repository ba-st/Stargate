"
I'm a provider of metrics
"
Class {
	#name : #MetricsProvider,
	#superclass : #Object,
	#category : #'Stargate-Metrics'
}

{ #category : #accessing }
MetricsProvider class >> allProviderNames [

	^ MetricsProvider allSubclasses collect: [ :class | class providerName ] 
]

{ #category : #'instance creation' }
MetricsProvider class >> configuredBy: pluginConfiguration [

	^ self subclassResponsibility
]

{ #category : #accessing }
MetricsProvider class >> providerName [

	^ self subclassResponsibility
]

{ #category : #private }
MetricsProvider >> currentTimestamp [
		
	^ DateAndTime now
]

{ #category : #calculating }
MetricsProvider >> gatherMetrics [

	self subclassResponsibility
]

{ #category : #actions }
MetricsProvider >> installOn: teapotServer [
]

{ #category : #actions }
MetricsProvider >> uninstall [
]
