Class {
	#name : #ResourceLocatorBehavior,
	#superclass : #Object,
	#category : #'Stargate-Model-Controllers'
}

{ #category : #accessing }
ResourceLocatorBehavior >> baseUrl: aServerUrl [

	self subclassResponsibility
]

{ #category : #testing }
ResourceLocatorBehavior >> canLookupResources [

	self subclassResponsibility
]

{ #category : #accessing }
ResourceLocatorBehavior >> endpoint [

	^ self subclassResponsibility
]

{ #category : #accessing }
ResourceLocatorBehavior >> handleExceptionsWith: anExceptionHandler [

	self subclassResponsibility
]

{ #category : #querying }
ResourceLocatorBehavior >> locationOf: resource within: requestContext [

	self subclassResponsibility
]

{ #category : #querying }
ResourceLocatorBehavior >> lookupResouceIdentifiedBy: httpRequest evaluating: aQueryBlock [

	self subclassResponsibility
]
