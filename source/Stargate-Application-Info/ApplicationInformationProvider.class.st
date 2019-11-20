"
I'm a provider of information over the running application
"
Class {
	#name : #ApplicationInformationProvider,
	#superclass : #Object,
	#category : #'Stargate-Application-Info'
}

{ #category : #accessing }
ApplicationInformationProvider class >> allProviderNames [

	^ ApplicationInformationProvider allSubclasses collect: [ :class | class providerName ]
]

{ #category : #accessing }
ApplicationInformationProvider class >> providerName [

	^ self subclassResponsibility
]

{ #category : #querying }
ApplicationInformationProvider >> gatherInformation [

	^ self subclassResponsibility
]

{ #category : #accessing }
ApplicationInformationProvider >> name [

	^ self class providerName
]
