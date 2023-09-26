Class {
	#name : 'SupportedLoggersIntegrityTest',
	#superclass : 'TestCase',
	#category : 'Stargate-Loggers-Tests',
	#package : 'Stargate-Loggers-Tests'
}

{ #category : 'tests' }
SupportedLoggersIntegrityTest >> testAvailableLoggersImplementTheRequiredProtocol [

	SignalLogger availableInStargate do: [ :loggerClass | 
		self assert: ( loggerClass respondsTo: #typeDescription ) ]
]

{ #category : 'tests' }
SupportedLoggersIntegrityTest >> testAvailableLoggersNamesDoNotCollide [

	"Each logger name is used in the API to identify it, so it can't be repeated"

	| names |

	names := SignalLogger availableInStargate collect: [ :loggerClass | loggerClass instance name ]
		         as: Set.

	self assert: names size equals: SignalLogger availableInStargate size
]
