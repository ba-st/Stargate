"
I'm a abstract class representing a metric
"
Class {
	#name : #Metric,
	#superclass : #Object,
	#category : #'Stargate-Metrics'
}

{ #category : #accessing }
Metric >> description [

	^ self subclassResponsibility
]

{ #category : #accessing }
Metric >> name [

	^ self subclassResponsibility
]

{ #category : #printing }
Metric >> printDetailsOn: stream [

	self subclassResponsibility
]

{ #category : #printing }
Metric >> printOn: stream [

	stream
		nextPutAll: self name;
		cr;
		nextPutAll: self description;
		cr.
	self printDetailsOn: stream
]

{ #category : #accessing }
Metric >> type [

	^ self subclassResponsibility
]

{ #category : #accessing }
Metric >> value [

	^ self subclassResponsibility
]
