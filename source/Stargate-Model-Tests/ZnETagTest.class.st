"
I'm a test case for ZnETag
"
Class {
	#name : #ZnETagTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-Zinc'
}

{ #category : #tests }
ZnETagTest >> testAsEtag [

	self
		assert: '"12345"' asETag equals: (ZnETag fromString: '"12345"');
		assert: (ZnETag fromString: '"12345"') asETag equals: (ZnETag fromString: '"12345"')
]

{ #category : #tests }
ZnETagTest >> testFromString [

	self
		assert: (ZnETag fromString: '"12345"') value equals: '12345';
		should: [ ZnETag fromString: '""' ] raise: InstanceCreationFailed;
		should: [ ZnETag fromString: '' ] raise: InstanceCreationFailed;
		should: [ ZnETag fromString: '123' ] raise: InstanceCreationFailed
]

{ #category : #tests }
ZnETagTest >> testHash [

	self assert: (ZnETag fromString: '"12345"') hash equals: (ZnETag fromString: '"12345"') hash
]

{ #category : #tests }
ZnETagTest >> testPrinting [

	self assert: (ZnETag with: '12345') printString equals: '"12345"'
]
