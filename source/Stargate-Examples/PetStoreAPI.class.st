Class {
	#name : #PetStoreAPI,
	#superclass : #StargateAPISkeleton,
	#category : #'Stargate-Examples'
}

{ #category : #private }
PetStoreAPI class >> applicationBaselineName [

	^ #BaselineOfStargate
]

{ #category : #accessing }
PetStoreAPI class >> commandName [

	^ 'pet-store'
]

{ #category : #accessing }
PetStoreAPI class >> description [

	^'A RESTful API for Pet stores'
]

{ #category : #accessing }
PetStoreAPI class >> initialize [

	<ignoreForCoverage>
	self initializeVersion
]

{ #category : #private }
PetStoreAPI class >> sectionsForStargateConfiguration [

	^ #( 'Pet Store' ) , super sectionsForStargateConfiguration
]

{ #category : #'private - accessing' }
PetStoreAPI >> controllersToInstall [

	^ Array with: PetsRESTfulController new with: PetOrdersRESTfulController new
]

{ #category : #'private - accessing' }
PetStoreAPI >> stargateConfiguration [

	^self configuration petStore stargate
]
