"
Test case
"
Class {
	#name : #IsUUIDTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-Teapot'
}

{ #category : #tests }
IsUUIDTest >> testMatches [

	self
		assert: (IsUUID matchesTo: '0608b9dc-02e4-4dd0-9f8a-ea45160df641');
		assert: (IsUUID matchesTo: 'e85ae7ba-3ca3-4bae-9f62-cc2ce51c525e');
		deny: (IsUUID matchesTo: 'ContainsCaps');
		deny: (IsUUID matchesTo: '-containsInvalidChars');
		deny: (IsUUID matchesTo: 3)
]

{ #category : #tests }
IsUUIDTest >> testParseString [

	| first second |

	first := '0608b9dc-02e4-4dd0-9f8a-ea45160df641'.
	second := 'e85ae7ba-3ca3-4bae-9f62-cc2ce51c525e'.

	self
		assert: (IsUUID parseString: first) equals: (UUID fromString: first);
		assert: (IsUUID parseString: second) equals: (UUID fromString: second)
]
