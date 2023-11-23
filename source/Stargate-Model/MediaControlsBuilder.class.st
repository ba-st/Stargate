"
I'm a builder easing the creation of media controls
"
Class {
	#name : 'MediaControlsBuilder',
	#superclass : 'Object',
	#instVars : [
		'mediaControls',
		'resourceLocatorBinding'
	],
	#category : 'Stargate-Model-HATEOAS',
	#package : 'Stargate-Model',
	#tag : 'HATEOAS'
}

{ #category : 'instance creation' }
MediaControlsBuilder class >> locatingResourcesWith: aResourceLocator [

	^ self new initializeLocatingResourcesWith: aResourceLocator
]

{ #category : 'adding' }
MediaControlsBuilder >> addAsSelfLink: aUrl [

	^ self addLink: aUrl relatedTo: 'self'
]

{ #category : 'adding' }
MediaControlsBuilder >> addLink: aUrl relatedTo: aRelationType [

	mediaControls add: aRelationType -> aUrl
]

{ #category : 'adding' }
MediaControlsBuilder >> addRelativeLink: aRelativeUrl relatedTo: aRelationType [

	mediaControls add: aRelationType -> ( resourceLocatorBinding content baseUrl / aRelativeUrl )
]

{ #category : 'building' }
MediaControlsBuilder >> build [

	^ mediaControls asArray
]

{ #category : 'initialization' }
MediaControlsBuilder >> initialize [

	super initialize.
	mediaControls := OrderedCollection new.
	resourceLocatorBinding := Binding undefinedExplainedBy: 'Missing resource locator'
]

{ #category : 'initialization' }
MediaControlsBuilder >> initializeLocatingResourcesWith: aResourceLocator [

	resourceLocatorBinding := Binding to: aResourceLocator
]
