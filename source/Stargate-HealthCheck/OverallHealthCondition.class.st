Class {
	#name : #OverallHealthCondition,
	#superclass : #HealthCondition,
	#instVars : [
		'conditions'
	],
	#category : #'Stargate-HealthCheck'
}

{ #category : #adding }
OverallHealthCondition >> addCondition: aHealthCondition [

	conditions add: aHealthCondition
]

{ #category : #accessing }
OverallHealthCondition >> concern [

	^ 'overall'
]

{ #category : #testing }
OverallHealthCondition >> hasSucceeded [

	^ conditions allSatisfy: #hasSucceeded
]

{ #category : #initialization }
OverallHealthCondition >> initialize [

	super initialize.
	conditions := OrderedCollection new
]

{ #category : #accessing }
OverallHealthCondition >> riskScore [

	^ conditions maxUsing: [ :condition | condition riskScore ] ifEmpty: [ 1 ]
]
