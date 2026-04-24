Class {
	#name : 'PetOrderShipmentHistoryEntry',
	#superclass : 'Object',
	#instVars : [
		'description'
	],
	#category : 'Stargate-Examples-PetStore',
	#package : 'Stargate-Examples',
	#tag : 'PetStore'
}

{ #category : 'instance creation' }
PetOrderShipmentHistoryEntry class >> describedBy: aDescription [

  ^ self new initializeDescribedBy: aDescription
]

{ #category : 'accessing' }
PetOrderShipmentHistoryEntry >> description [

  ^ description
]

{ #category : 'initialization' }
PetOrderShipmentHistoryEntry >> initializeDescribedBy: aDescription [ 

	description := aDescription
]
