"
I'm an abstract class representing health conditions 
"
Class {
	#name : #HealthCondition,
	#superclass : #Object,
	#category : #'Stargate-HealthCheck'
}

{ #category : #testing }
HealthCondition >> isCritical [

	^ self isNotCritical not
]

{ #category : #testing }
HealthCondition >> isNotCritical [

	^ self subclassResponsibility
]

{ #category : #accessing }
HealthCondition >> riskScore [

	^ self subclassResponsibility
]
