Class {
	#name : 'PetStoreApplication',
	#superclass : 'StargateApplication',
	#category : 'Stargate-Examples-PetStore',
	#package : 'Stargate-Examples',
	#tag : 'PetStore'
}

{ #category : 'accessing' }
PetStoreApplication class >> commandName [

	^ 'pet-store'
]

{ #category : 'accessing' }
PetStoreApplication class >> description [

	^'A RESTful API for Pet stores'
]

{ #category : 'accessing' }
PetStoreApplication class >> initialize [

	<ignoreForCoverage>
	self initializeVersion
]

{ #category : 'private' }
PetStoreApplication class >> projectName [

	^ 'Stargate'
]

{ #category : 'private' }
PetStoreApplication class >> sectionsForStargateConfiguration [

	^ #( 'Pet Store' ) , super sectionsForStargateConfiguration
]

{ #category : 'private - accessing' }
PetStoreApplication >> controllersToInstall [

	^ Array with: PetsRESTfulController new with: PetOrdersRESTfulController new
]

{ #category : 'private - accessing' }
PetStoreApplication >> stargateConfiguration [

	^self configuration petStore stargate
]
