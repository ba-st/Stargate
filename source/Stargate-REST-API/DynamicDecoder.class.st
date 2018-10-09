Class {
	#name : #DynamicDecoder,
	#superclass : #Object,
	#instVars : [
		'key',
		'decoders'
	],
	#category : #'Stargate-REST-API'
}

{ #category : #'instance creation' }
DynamicDecoder class >> determiningDecoderBy: aKey [

	^ self new initializeDeterminingDecoderBy: aKey 
	
	
]

{ #category : #configuring }
DynamicDecoder >> decoding: aKey applying: aBlock [
	
	decoders at: aKey put: aBlock
]

{ #category : #'initialize-release' }
DynamicDecoder >> initializeDeterminingDecoderBy: aKey [
	
	key := aKey.
	decoders := Dictionary new
]

{ #category : #decoding }
DynamicDecoder >> value: aDictionary [

	| criteria |

	criteria := aDictionary
		at: key
		ifAbsent:
			[ DecodingFailed signal: ('Key <1s> not found' expandMacrosWith: key) ].

	^ decoders
		at: criteria
		ifPresent: [ :block | block value: aDictionary ]
		ifAbsent: [ DecodingFailed
				signal: ('Parser to parse <1s> not found' expandMacrosWith: key) ]
]
