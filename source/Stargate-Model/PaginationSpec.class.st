"
I'm a pagination specification, used to know the start index and the expected page size
"
Class {
	#name : #PaginationSpec,
	#superclass : #Object,
	#instVars : [
		'start',
		'limit'
	],
	#category : #'Stargate-Model-Services'
}

{ #category : #'Instance creation' }
PaginationSpec class >> startingAt: aNumber limitedTo: aLimit [

	AssertionChecker enforce: [ aLimit strictlyPositive ] because: 'The page limit must be positive' raising: InstanceCreationFailed.
	"We're forgiving with the starting index"
	^ self new initializeStartingAt: (aNumber max: 1) limitedTo: aLimit
]

{ #category : #accessing }
PaginationSpec >> end [

	^ start + limit - 1 
]

{ #category : #'initialize - release' }
PaginationSpec >> initializeStartingAt: anStartIndex limitedTo: aLimitCount [

	start := anStartIndex.
	limit := aLimitCount
]

{ #category : #accessing }
PaginationSpec >> limit [

	^ limit
]

{ #category : #printing }
PaginationSpec >> printOn: aStream [

	aStream
		nextPutAll: 'start=';
		print: start;
		cr;
		nextPutAll: 'limit=';
		print: limit
]

{ #category : #accessing }
PaginationSpec >> start [

	^ start
]
