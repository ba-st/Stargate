"
I'm a RESTful controllers handling only one resource, so I can make some assumptions and provide some ready to use behavior.
"
Class {
	#name : #SingleResourceRESTfulController,
	#superclass : #ResourceRESTfulController,
	#category : #'Stargate-Model-Controllers'
}

{ #category : #testing }
SingleResourceRESTfulController class >> isAbstract [

	<ignoreForCoverage>
	^ self = SingleResourceRESTfulController
]

{ #category : #private }
SingleResourceRESTfulController >> endpoint [

	^ self requestHandler endpoint
]

{ #category : #private }
SingleResourceRESTfulController >> identifierIn: httpRequest [

	^ httpRequest at: self identifierKey
]

{ #category : #private }
SingleResourceRESTfulController >> identifierKey [

	^ #identifier asString
]

{ #category : #private }
SingleResourceRESTfulController >> identifierTemplate [

	^ '<1s>/%<<2s>:<3s>>'
		expandMacrosWith: self endpoint
		with: self identifierKey
		with: self typeIdConstraint asString
]

{ #category : #private }
SingleResourceRESTfulController >> requestHandler [

	^ self subclassResponsibility
]

{ #category : #configuring }
SingleResourceRESTfulController >> serverUrl: aServerUrl [

	self requestHandler serverUrl: aServerUrl
]

{ #category : #private }
SingleResourceRESTfulController >> typeIdConstraint [

	^ self subclassResponsibility
]
