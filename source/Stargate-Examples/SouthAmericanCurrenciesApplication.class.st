Class {
	#name : #SouthAmericanCurrenciesApplication,
	#superclass : #StargateApplication,
	#category : #'Stargate-Examples'
}

{ #category : #private }
SouthAmericanCurrenciesApplication class >> applicationBaselineName [

	^ #BaselineOfStargate
]

{ #category : #accessing }
SouthAmericanCurrenciesApplication class >> commandName [

	^ 'currencies'
]

{ #category : #accessing }
SouthAmericanCurrenciesApplication class >> description [

	^'API for South american currencies'
]

{ #category : #initialization }
SouthAmericanCurrenciesApplication class >> initialize [

	<ignoreForCoverage>
	self initializeVersion
]

{ #category : #'private - accessing' }
SouthAmericanCurrenciesApplication >> controllersToInstall [

	^ Array with: SouthAmericanCurrenciesRESTfulController new
]
