"
I'm a test case for HttpRequestContext
"
Class {
	#name : 'HttpRequestContextTest',
	#superclass : 'TestCase',
	#category : 'Stargate-Model-Tests-Controllers',
	#package : 'Stargate-Model-Tests',
	#tag : 'Controllers'
}

{ #category : 'tests' }
HttpRequestContextTest >> testHasTargetLanguageTag [

  | requestContext |
  requestContext := HttpRequestContext new.
  self deny: requestContext hasTargetLanguageTag.

  requestContext targetLanguageTag: 'es-AR' asLanguageTag.
  self assert: requestContext hasTargetLanguageTag
]
