Class {
	#name : #DynamicDecoderTest,
	#superclass : #TestCase,
	#category : #'Stargate-REST-API-Tests'
}

{ #category : #tests }
DynamicDecoderTest >> testDecoding [

	| decoder aJson decoded |

	decoder := (DynamicDecoder determiningDecoderBy: #type)
		decoding: #number applying: [ :json | (json at: #amount) asNumber ];
		decoding: #string applying: [ :json | json at: #name ];
		yourself.

	aJson := '{
	"type" : "number",
	"amount" : "5"
}'.

	decoded := decoder value: (STONJSON fromString: aJson).
	self assert: decoded equals: 5.

	aJson := '{
	"type" : "string",
	"name" : "a string"
}'.

	decoded := decoder value: (STONJSON fromString: aJson).
	self assert: decoded equals: 'a string'
]
