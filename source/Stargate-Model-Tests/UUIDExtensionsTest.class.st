Class {
	#name : #UUIDExtensionsTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-Extensions'
}

{ #category : #tests }
UUIDExtensionsTest >> testJSONMapping [

	| uuid |

	uuid := UUID fromString: '0ef0f918-1048-0d00-bdd7-535e0391dce2'.
	self assert: ( NeoJSONWriter toString: uuid ) equals: '"0ef0f918-1048-0d00-bdd7-535e0391dce2"'
]
