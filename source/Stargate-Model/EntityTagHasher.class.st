"
I'm responsible for generating a valid ETag hashing the objects included
"
Class {
	#name : #EntityTagHasher,
	#superclass : #Object,
	#instVars : [
		'toHash'
	],
	#category : #'Stargate-Model-Controllers'
}

{ #category : #calculating }
EntityTagHasher >> calculateHash [

	| message |

	message := String
		streamContents:
			[ :stream | toHash do: [ :object | stream nextPutAll: object asString ] separatedBy: [ stream nextPut: $- ] ].
	^ ( SHA1 new hashMessage: message ) hex
]

{ #category : #configuring }
EntityTagHasher >> include: anObjectToHash [

	toHash add: anObjectToHash
]

{ #category : #initialization }
EntityTagHasher >> initialize [

	super initialize.
	toHash := OrderedCollection new
]
