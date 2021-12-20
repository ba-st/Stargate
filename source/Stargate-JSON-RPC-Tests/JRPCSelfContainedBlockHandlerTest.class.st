"
A JRPCSelfContainedBlockHandlerTest is a test class for testing the behavior of JRPCSelfContainedBlockHandler
"
Class {
	#name : #JRPCSelfContainedBlockHandlerTest,
	#superclass : #TestCase,
	#category : #'Stargate-JSON-RPC-Tests'
}

{ #category : #tests }
JRPCSelfContainedBlockHandlerTest >> testArgumentCountAndArgumentNamesDontMatch [

	self
		should: [ 
			JRPCSelfContainedBlockHandler forProcedureNamed: 'x'
				withArgumentNames: #(  )
				evaluating: [ :one |  ]
			]
		raise: InstanceCreationFailed
		withMessageText: 'The number of arguments must be consistent with the block to evaluate'
]
