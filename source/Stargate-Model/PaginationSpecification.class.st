"
I'm a pagination specification, used to know the start index and the expected page size
"
Class {
	#name : 'PaginationSpecification',
	#superclass : 'Object',
	#instVars : [
		'start',
		'limit'
	],
	#category : 'Stargate-Model-Pagination',
	#package : 'Stargate-Model',
	#tag : 'Pagination'
}

{ #category : 'Instance creation' }
PaginationSpecification class >> startingAt: aNumber limitedTo: aLimit [

	AssertionChecker
		enforce: [ aLimit strictlyPositive ]
		because: 'The page limit must be positive'
		raising: InstanceCreationFailed.	"We're forgiving with the starting index"
	^ self new initializeStartingAt: ( aNumber max: 1 ) limitedTo: aLimit
]

{ #category : 'accessing' }
PaginationSpecification >> end [

	^ start + limit - 1 
]

{ #category : 'initialize - release' }
PaginationSpecification >> initializeStartingAt: anStartIndex limitedTo: aLimitCount [

	start := anStartIndex.
	limit := aLimitCount
]

{ #category : 'accessing' }
PaginationSpecification >> limit [

	^ limit
]

{ #category : 'printing' }
PaginationSpecification >> printOn: aStream [

	aStream
		nextPutAll: 'start=';
		print: start;
		cr;
		nextPutAll: 'limit=';
		print: limit
]

{ #category : 'accessing' }
PaginationSpecification >> start [

	^ start
]
