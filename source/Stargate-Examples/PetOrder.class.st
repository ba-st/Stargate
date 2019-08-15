"
I'm a toy abstraction used just as an example
"
Class {
	#name : #PetOrder,
	#superclass : #Object,
	#instVars : [
		'pet',
		'date'
	],
	#category : #'Stargate-Examples-PetStore'
}

{ #category : #'instance creation' }
PetOrder class >> for: aPetReference on: aDateAndTime [

	^self new initializeFor: aPetReference on: aDateAndTime
]

{ #category : #initialization }
PetOrder >> initializeFor: aPetReference on: aDateAndTime [

	pet := aPetReference.
	date := aDateAndTime 
]

{ #category : #accessing }
PetOrder >> pet [

	^ pet
]
