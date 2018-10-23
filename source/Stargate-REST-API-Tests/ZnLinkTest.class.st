"
I'm a test case for ZnLink
"
Class {
	#name : #ZnLinkTest,
	#superclass : #TestCase,
	#category : #'Stargate-REST-API-Tests-Model'
}

{ #category : #support }
ZnLinkTest >> googleUrl [

	^ 'https://google.com' asZnUrl
]

{ #category : #tests }
ZnLinkTest >> testComparing [

	| googleLink other |

	googleLink := ZnLink to: self googleUrl.
	other := ZnLink to: self googleUrl.

	self
		assert: googleLink equals: other;
		assert: googleLink hash equals: other hash.

	other rel: 'next'.

	self deny: googleLink equals: other
]

{ #category : #tests }
ZnLinkTest >> testCopying [

	| googleLink copy |

	googleLink := ZnLink to: self googleUrl.
	copy := googleLink copy.

	self
		deny: googleLink hasParameters;
		deny: copy hasParameters.

	copy rel: 'next'.
	self
		deny: googleLink hasParameters;
		assert: copy hasParameters
]

{ #category : #tests }
ZnLinkTest >> testParameters [

	| link |

	link := ZnLink to: self googleUrl.
	self should: [ link parameterAt: 'foo' ] raise: KeyNotFound.
	self assert: (link parameterAt: 'foo' ifAbsent: [ #none ]) equals: #none.
	link parameterAt: 'foo' put: '1'.
	self assert: (link parameterAt: 'foo') equals: '1'.
	self assert: (link parameterAt: 'foo' ifAbsent: [ #none ]) equals: '1'.
	link removeParameter: 'foo'.
	link removeParameter: 'bar'.
	self should: [ link parameterAt: 'foo' ] raise: KeyNotFound.
	self assert: (link parameterAt: 'foo' ifAbsent: [ #none ]) equals: #none
]

{ #category : #tests }
ZnLinkTest >> testPrinting [

	self assert: (ZnLink to: self googleUrl) printString equals: '<https://google.com/>'.

	self
		assert:
			((ZnLink to: self googleUrl)
				rel: 'search';
				yourself) printString
		equals: '<https://google.com/>;rel=search'
]
