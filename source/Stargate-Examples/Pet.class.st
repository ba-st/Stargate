"
I'm a toy abstraction used just as an example
"
Class {
	#name : #Pet,
	#superclass : #Object,
	#instVars : [
		'name',
		'type',
		'status'
	],
	#category : #'Stargate-Examples-PetStore'
}

{ #category : #'instance creation' }
Pet class >> named: aName ofType: aPetType [

	^ self named: aName ofType: aPetType withStatus: 'new'
]

{ #category : #'instance creation' }
Pet class >> named: aName ofType: aPetType withStatus: status [

	^ self new initializeNamed: aName ofType: aPetType withStatus: status
]

{ #category : #initialization }
Pet >> initializeNamed: aName ofType: aPetType withStatus: aStatus [

	name := aName.
	type := aPetType.
	status := aStatus
]

{ #category : #accessing }
Pet >> name [
	^ name
]

{ #category : #accessing }
Pet >> status [
	^ status
]

{ #category : #updating }
Pet >> synchronizeWith: aPet [

	name := aPet name.
	type := aPet type.
	status := aPet status
]

{ #category : #accessing }
Pet >> type [
	^ type
]
