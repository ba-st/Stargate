"
I'm a builder easing the creation of media controls
"
Class {
	#name : #MediaControlsBuilder,
	#superclass : #Object,
	#instVars : [
		'mediaControls'
	],
	#category : #'Stargate-Model-HATEOAS'
}

{ #category : #adding }
MediaControlsBuilder >> addAsSelfLink: aUrl [

	^ self addLink: aUrl relatedTo: 'self'
]

{ #category : #adding }
MediaControlsBuilder >> addLink: aUrl relatedTo: aRelationType [

	mediaControls add: aRelationType -> aUrl
]

{ #category : #building }
MediaControlsBuilder >> build [

	^ mediaControls asArray
]

{ #category : #initialization }
MediaControlsBuilder >> initialize [

	super initialize.
	mediaControls := OrderedCollection new
]
