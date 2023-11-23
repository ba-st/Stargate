Class {
	#name : 'SouthAmericanCurrenciesApplication',
	#superclass : 'StargateApplication',
	#category : 'Stargate-Examples-Currencies',
	#package : 'Stargate-Examples',
	#tag : 'Currencies'
}

{ #category : 'accessing' }
SouthAmericanCurrenciesApplication class >> commandName [

	^ 'currencies'
]

{ #category : 'accessing' }
SouthAmericanCurrenciesApplication class >> description [

	^'API for South american currencies'
]

{ #category : 'initialization' }
SouthAmericanCurrenciesApplication class >> initialize [

	<ignoreForCoverage>
	self initializeVersion
]

{ #category : 'private' }
SouthAmericanCurrenciesApplication class >> projectName [

	^ 'Stargate'
]

{ #category : 'private - accessing' }
SouthAmericanCurrenciesApplication >> controllersToInstall [

	^ Array with: SouthAmericanCurrenciesRESTfulController new
]
