Class {
	#name : #HypermediaAwareJSONWriter,
	#superclass : #NeoJSONWriter,
	#instVars : [
		'mediaControls'
	],
	#category : #'Stargate-REST-API'
}

{ #category : #'initialize-release' }
HypermediaAwareJSONWriter >> initialize [

	super initialize.
	mediaControls := Dictionary new
]

{ #category : #'initialize-release' }
HypermediaAwareJSONWriter >> mediaControls: aDictionary [

	mediaControls := aDictionary
]

{ #category : #writing }
HypermediaAwareJSONWriter >> writeMapStreamingDo: block [

	| controls |

	writeStream nextPut: ${.
	controls := mediaControls.
	mediaControls := Dictionary new.
	self writeStreamingDo: block.
	controls
		ifNotEmpty: [ self mapElementSeparator.
			self encodeKey: 'links' value: controls ].
	writeStream nextPut: $}
]
