"
** PRIVATE **
I'm a wrapper over a collection. 
I'm used internally in Hypermedia driven controllers to ease the media control creation.
I'm not intended to be used externally.
"
Class {
	#name : #ResourceCollection,
	#superclass : #Object,
	#instVars : [
		'items'
	],
	#category : #'Stargate-Model-HATEOAS'
}

{ #category : #'instance creation' }
ResourceCollection class >> wrapping: aCollection [ 

	^self new initializeWrapping: aCollection
]

{ #category : #initialization }
ResourceCollection >> initializeWrapping: aCollection [ 

	items := aCollection
]

{ #category : #accessing }
ResourceCollection >> items [

	^ items
]
