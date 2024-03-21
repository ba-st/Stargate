"
I'm a testing application used to check the concurrent connections threshold configuration parameter behavior.
"
Class {
	#name : 'ConcurrentConnectionsTestApplication',
	#superclass : 'StargateApplication',
	#category : 'Stargate-API-Skeleton-Tests',
	#package : 'Stargate-API-Skeleton-Tests'
}

{ #category : 'accessing' }
ConcurrentConnectionsTestApplication class >> commandName [

	^ 'concurrent-connections-test'
]

{ #category : 'accessing' }
ConcurrentConnectionsTestApplication class >> description [

	^'A Test API making the request processing to wait a certain amount of time'
]

{ #category : 'initialization' }
ConcurrentConnectionsTestApplication class >> initialize [

	<ignoreForCoverage>
	self initializeVersion
]

{ #category : 'private' }
ConcurrentConnectionsTestApplication class >> projectName [

	^ 'Stargate'
]

{ #category : 'private - accessing' }
ConcurrentConnectionsTestApplication >> controllersToInstall [

	^ { DelayedRESTfulController new }
]
