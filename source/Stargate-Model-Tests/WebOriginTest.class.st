Class {
	#name : #WebOriginTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-Routing'
}

{ #category : #tests }
WebOriginTest >> testComparing [

	self assert: 'http://example.com/' asUrl origin hash equals: 'http://example.com' hash.
	self assert: 'http://example.com/' asUrl origin equals: 'http://example.com'.
	self assert: 'http://example.com:80/' asUrl origin equals: 'http://example.com'.
	self assert: 'http://example.com/path/file' asUrl origin equals: 'http://example.com'.
	self assert: 'http://example.com:8080/' asUrl origin equals: 'http://example.com:8080'.
	self assert: 'http://www.example.com/' asUrl origin equals: 'http://www.example.com'.
	self assert: 'https://example.com:80/' asUrl origin equals: 'https://example.com'.
	self assert: 'https://example.com/' asUrl origin equals: 'https://example.com'.
	self assert: 'http://example.org/' asUrl origin equals: 'http://example.org'.
	self assert: 'http://ietf.org/' asUrl origin equals: 'http://ietf.org'.
	self assert: 'http://127.0.0.1:8081/the/path/' asUrl origin equals: 'http://127.0.0.1:8081'.
	self assert: 'https://johndoe@www.example.com:123/forum/questions?id=1' asUrl origin equals: 'https://www.example.com:123'.
	self
		should: [ 'mailto:John.doe@example.com' asUrl origin ]
		raise: InstanceCreationFailed
		withMessageText: 'mailto:John.doe@example.com does not comply with a valid origin'
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
