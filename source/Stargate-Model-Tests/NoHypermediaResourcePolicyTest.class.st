"
Unit test
"
Class {
	#name : #NoHypermediaResourcePolicyTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-Controllers'
}

{ #category : #tests }
NoHypermediaResourcePolicyTest >> testBehavior [

	| policy context |

	context := HttpRequestContext new.
	policy := NoHypermediaResourcePolicy new.
	policy holdResource: 1 controlsWithin: context.
	self assert: context hypermediaControls isEmpty.

	policy holdCollection: #() controlsBasedOn: ZnRequest new within: context.
	self assert: context hypermediaControls isEmpty
]
