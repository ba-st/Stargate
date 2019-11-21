"
I'm a provider of basic information about the running application
"
Class {
	#name : #BasicApplicationInformationProvider,
	#superclass : #ApplicationInformationProvider,
	#instVars : [
		'applicationName',
		'applicationDescription',
		'version'
	],
	#classVars : [
		'UniqueInstance'
	],
	#category : #'Stargate-Application-Info'
}

{ #category : #'instance creation' }
BasicApplicationInformationProvider class >> new [

	UniqueInstance ifNil: [ UniqueInstance := super new ].
	^ UniqueInstance
]

{ #category : #accessing }
BasicApplicationInformationProvider class >> providerName [

	^ 'application'
]

{ #category : #configuring }
BasicApplicationInformationProvider >> applicationNamed: aName describedBy: aDescription version: aVersion [

	applicationName := aName.
	applicationDescription := aDescription.
	version := aVersion
]

{ #category : #querying }
BasicApplicationInformationProvider >> gatherInformation [

	^ OrderedDictionary new
		at: 'name' put: applicationName;
		at: 'description' put: applicationDescription;
		at: 'version' put: version;
		yourself
]

{ #category : #initialization }
BasicApplicationInformationProvider >> initialize [

	super initialize.
	self applicationNamed: '' describedBy: '' version: ''
]
