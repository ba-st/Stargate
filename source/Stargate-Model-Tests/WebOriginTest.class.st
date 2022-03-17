Class {
	#name : #WebOriginTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-CORS'
}

{ #category : #tests }
WebOriginTest >> testAsUrl [

	| origin |
	origin := 'http://example.com/' asWebOrigin.

	self assertUrl: origin asUrl equals: 'http://example.com'
]

{ #category : #tests }
WebOriginTest >> testAsWebOrigin [

	| origin |
	origin := 'http://example.com/' asWebOrigin.

	self assert: origin asWebOrigin == origin
]

{ #category : #tests }
WebOriginTest >> testComparing [

	self assert: 'http://example.com/' asWebOrigin hash equals: 'http://example.com' hash.
	self assert: 'http://example.com/' asWebOrigin equals: 'http://example.com'.
	self assert: 'http://example.com:80/' asWebOrigin equals: 'http://example.com'.
	self assert: 'http://example.com/path/file' asWebOrigin equals: 'http://example.com'.
	self assert: 'http://example.com:8080/' asWebOrigin equals: 'http://example.com:8080'.
	self assert: 'http://www.example.com/' asWebOrigin equals: 'http://www.example.com'.
	self assert: 'https://example.com:443/' asWebOrigin equals: 'https://example.com'.
	self assert: 'https://example.com/' asWebOrigin equals: 'https://example.com'.
	self assert: 'http://example.org/' asWebOrigin equals: 'http://example.org'.
	self assert: 'http://ietf.org/' asWebOrigin equals: 'http://ietf.org'.
	self assert: 'http://127.0.0.1:8081/the/path/' asWebOrigin equals: 'http://127.0.0.1:8081'.
	self assert: 'https://johndoe@www.example.com:123/forum/questions?id=1' asWebOrigin equals: 'https://www.example.com:123'.
	self
		should: [ 'mailto:John.doe@example.com' asWebOrigin ]
		raise: InstanceCreationFailed
		withMessageText: 'mailto:John.doe@example.com does not comply with a valid origin'
]

{ #category : #tests }
WebOriginTest >> testPrintString [

	self
		assert: 'http://example.com/' asWebOrigin printString
		equals: 'http://example.com';
		assert: 'http://example.com:80/' asWebOrigin printString
		equals: 'http://example.com';
		assert: 'http://example.com/path/file' asWebOrigin printString
		equals: 'http://example.com';
		assert:
			'https://johndoe@www.example.com:123/forum/questions?id=1'
				asWebOrigin printString
		equals: 'https://www.example.com:123'
]

{ #category : #tests }
WebOriginTest >> testValidOrigins [

	self assert: 'http://example.com/' asUrl hasValidOrigin.
	self assert: 'http://example.com:80/' asUrl hasValidOrigin.
	self assert: 'http://example.com/path/file' asUrl hasValidOrigin.
	self assert: 'http://example.com:8080/' asUrl hasValidOrigin.
	self assert: 'http://www.example.com/' asUrl hasValidOrigin.
	self assert: 'https://example.com:80/' asUrl hasValidOrigin.
	self assert: 'https://example.com/' asUrl hasValidOrigin.
	self assert: 'http://example.org/' asUrl hasValidOrigin.
	self assert: 'http://ietf.org/' asUrl hasValidOrigin.
	self assert: 'http://127.0.0.1:8081/the/path/' asUrl hasValidOrigin.
	self assert: 'https://johndoe@www.example.com:123/forum/questions?id=1' asUrl hasValidOrigin.
	self assert: 'https://johndoe@www.example.com:123/forum/questions?id=1' asUrl hasValidOrigin.
	self deny: 'mailto:John.doe@example.com' asUrl hasValidOrigin.

]
