"
I'm a provider of information about the GemStone/S 64 version running this application
"
Class {
	#name : #GS64InformationProvider,
	#superclass : #ApplicationInformationProvider,
	#category : #'Stargate-Application-Info-GS64'
}

{ #category : #accessing }
GS64InformationProvider class >> providerName [

	^ 'gs64'
]

{ #category : #querying }
GS64InformationProvider >> gatherInformation [

	^ OrderedDictionary new
		  at: 'gem' put: self gemInfo;
		  at: 'gemConfiguration' put: self gemConfigInfo;
		  at: 'sharedPageCache' put: self sharedPageCacheInfo;
		  at: 'stone' put: self stoneInfo;
		  at: 'stoneConfiguration' put: self stoneConfigInfo;
		  yourself
]

{ #category : #querying }
GS64InformationProvider >> gemConfigInfo [

	^ System gemConfigurationReport
]

{ #category : #querying }
GS64InformationProvider >> gemInfo [

	^ System gemVersionReport
]

{ #category : #querying }
GS64InformationProvider >> sharedPageCacheInfo [

	^ System getSharedCacheAttributes
]

{ #category : #querying }
GS64InformationProvider >> stoneConfigInfo [

	^ System stoneConfigurationReport
]

{ #category : #querying }
GS64InformationProvider >> stoneInfo [

	^ System stoneVersionReport
]
