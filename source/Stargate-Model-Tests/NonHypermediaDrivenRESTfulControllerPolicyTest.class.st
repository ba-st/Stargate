"
Unit test
"
Class {
	#name : #NonHypermediaDrivenRESTfulControllerPolicyTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-Controllers'
}

{ #category : #tests }
NonHypermediaDrivenRESTfulControllerPolicyTest >> testBehavior [

	| policy context |

	context := HttpRequestContext new.
	policy := NonHypermediaDrivenRESTfulControllerPolicy new.
	policy holdResource: 1 controlsWithin: context.
	self assert: context hypermediaControls isEmpty.

	policy holdCollection: #() controlsBasedOn: ZnRequest new within: context.
	self assert: context hypermediaControls isEmpty
]
