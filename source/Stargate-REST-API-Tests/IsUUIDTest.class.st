Class {
	#name : #IsUUIDTest,
	#superclass : #TestCase,
	#category : #'Stargate-REST-API-Tests'
}

{ #category : #tests }
IsUUIDTest >> testMatches [

	self
		assert: (IsUUID matchesTo: '3wkyfiioh6vu12497yj6g20p2');
		assert: (IsUUID matchesTo: '5l0vw3e9434a49gz49hqz1xig');
		deny: (IsUUID matchesTo: 'ContainsCaps');
		deny: (IsUUID matchesTo: '-containsInvalidChars')
]

{ #category : #tests }
IsUUIDTest >> testParseString [

	| first second |

	first := UUID fromString: '0608b9dc-02e4-4dd0-9f8a-ea45160df641'.
	second := UUID fromString: 'e85ae7ba-3ca3-4bae-9f62-cc2ce51c525e'.

	self
		assert: (IsUUID parseString: first asString36) equals: first;
		assert: (IsUUID parseString: second asString36) equals: second
]
