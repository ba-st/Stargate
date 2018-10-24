Class {
	#name : #MediaTypeTest,
	#superclass : #TestCase,
	#category : #'Stargate-REST-API-Tests'
}

{ #category : #tests }
MediaTypeTest >> testPrecendce [

	self
		assert: 'text/html' asMediaType precedence equals: 3;
		assert: 'text/html;q=0.8' asMediaType precedence equals: 3;
		assert: 'text/*' asMediaType precedence equals: 2;
		assert: '*/*' asMediaType precedence equals: 1;
		assert: 'text/vnd.api+html' asMediaType precedence equals: 4
]

{ #category : #tests }
MediaTypeTest >> testQuality [

	self
		assert: 'text/html' asMediaType quality equals: 1.0;
		assert: 'text/html;q=0.8' asMediaType quality equals: 0.8
]
