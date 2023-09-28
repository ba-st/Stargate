Class {
	#name : #ZnEntityStargateExtensionsTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-Extensions'
}

{ #category : #tests }
ZnEntityStargateExtensionsTest >> testAsString [

	self
		assert: ( ZnEntity text: 'Regression test' ) asString
		equals: 'text/plain;charset=utf-8  Regression test'.

	self
		assert: ( ZnEntity bytes: #[ 12 13 45 ] ) asString
		equals: 'application/octet-stream 3B #[12 13 45]'.

	self assert: ( ZnEntity json: '{"test":1}' ) asString equals: 'application/json  {"test":1}'.

	self
		assert: ( ZnEntity xml: '<test><sub></sub></test>' ) asString
		equals: 'application/xml  <test><sub></sub></test>'
]
