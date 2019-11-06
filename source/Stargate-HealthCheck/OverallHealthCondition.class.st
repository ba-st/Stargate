"
I represent a health condition composed of other conditions. 
My riskScore is derived of the composing conditions, like my critical state.
"
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

{ #category : #enumerating }
OverallHealthCondition >> conditionsDo: aBlockClosure [

	conditions do: aBlockClosure
]

{ #category : #initialization }
OverallHealthCondition >> initialize [

	super initialize.
	conditions := OrderedCollection new
]

{ #category : #testing }
OverallHealthCondition >> isNotCritical [

	^ conditions allSatisfy: #isNotCritical
]

{ #category : #accessing }
OverallHealthCondition >> riskScore [

	^ conditions maxUsing: [ :condition | condition riskScore ] ifEmpty: [ 1 ]
]
