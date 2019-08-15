Class {
	#name : #EncodingMappingRule,
	#superclass : #Object,
	#category : #'Stargate-Deprecated-V3'
}

{ #category : #'instance creation' }
EncodingMappingRule class >> encoding: anObjectType to: aMediaType using: aWriter [

	self
		deprecated: 'Use enconding:using:'
		transformWith:
			'`@receiver encoding: `@anObjectType to: `@aMediaType using: `@aWriter'
				-> 'ResourceEncodingRule encoding: `@aMediaType using: `@aWriter'.
	^ ResourceEncodingRule encoding: aMediaType using: aWriter
]

{ #category : #'instance creation' }
EncodingMappingRule class >> encoding: aMediaType using: aWriter [

	self
		deprecated: 'Use enconding:using:'
		transformWith:
			'`@receiver encoding: `@aMediaType using: `@aWriter'
				-> 'ResourceEncodingRule encoding: `@aMediaType using: `@aWriter'.
	^ ResourceEncodingRule encoding: aMediaType using: aWriter
]
