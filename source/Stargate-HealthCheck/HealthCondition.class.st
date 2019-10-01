Class {
	#name : #HealthCondition,
	#superclass : #Object,
	#category : #'Stargate-HealthCheck'
}

{ #category : #accessing }
HealthCondition >> concern [

	^ self subclassResponsibility
]

{ #category : #testing }
HealthCondition >> hasSucceeded [

	^ self subclassResponsibility
]

{ #category : #accessing }
HealthCondition >> riskScore [

	^ self subclassResponsibility
]
