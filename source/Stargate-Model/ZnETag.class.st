"
The ETag HTTP response header is an identifier for a specific version of a resource. It allows caches to be more efficient, and saves bandwidth, as a web server does not need to send a full response if the content has not changed. On the other side, if the content has changed, etags are useful to help prevent simultaneous updates of a resource from overwriting each other (""mid-air collisions"").

If the resource at a given URL changes, a new Etag value must be generated. Etags are therefore similar to fingerprints and might also be used for tracking purposes by some servers. A comparison of them allows to quickly determine whether two representations of a resource are the same, but they might also be set to persist indefinitely by a tracking server.
"
Class {
	#name : #ZnETag,
	#superclass : #Object,
	#instVars : [
		'value'
	],
	#category : #'Stargate-Model-Zinc'
}

{ #category : #'instance creation' }
ZnETag class >> fromString: aString [

	AssertionCheckerBuilder new
		raising: InstanceCreationFailed;
		checking: [ :asserter | 
			asserter
				enforce: [ aString size >= 3 ]
					because: 'Empty ETag values are invalid.'
					onSuccess: [ :successAsserter | 
					successAsserter
						enforce: [ aString first = $" ] because: 'ETags must be enclosed in ".';
						enforce: [ aString last = $" ] because: 'ETags must be enclosed in ".' ];
				enforce: [ aString isAsciiString ] because: 'ETags only allows ASCII characters.' ];
		buildAndCheck.

	^ self with: (aString copyFrom: 2 to: aString size - 1)
]

{ #category : #'instance creation' }
ZnETag class >> with: anETagValue [

	^ self new initializeWith: anETagValue
]

{ #category : #comparing }
ZnETag >> = anObject [

	^ self class = anObject class and: [ value = anObject value ]
]

{ #category : #converting }
ZnETag >> asETag [

	^ self
]

{ #category : #printing }
ZnETag >> asString [

	^self printString
]

{ #category : #comparing }
ZnETag >> hash [

	^ value hash
]

{ #category : #initialization }
ZnETag >> initializeWith: anETagValue [

	value := anETagValue
]

{ #category : #printing }
ZnETag >> printOn: aStream [

	aStream
		nextPut: $";
		nextPutAll: value;
		nextPut: $"
]

{ #category : #evaluating }
ZnETag >> value [

	^ value
]
