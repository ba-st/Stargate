"
I'm a provider of information about the Operating System running this application
"
Class {
	#name : #OperatingSystemInformationProvider,
	#superclass : #ApplicationInformationProvider,
	#category : #'Stargate-Application-Info-Pharo'
}

{ #category : #accessing }
OperatingSystemInformationProvider class >> providerName [

	^ 'os'
]

{ #category : #private }
OperatingSystemInformationProvider >> environmentInfo [

	^ Smalltalk os environment asDictionary
]

{ #category : #querying }
OperatingSystemInformationProvider >> gatherInformation [

	^ Dictionary new
		at: 'general' put: self operatingSystemGeneralInfo;
		at: 'details' put: self operatingSystemDetails;
		at: 'environment' put: self environmentInfo;
		yourself
]

{ #category : #private }
OperatingSystemInformationProvider >> includeLinuxDetailsOn: details [

	[ details at: 'version' put: '/proc/version' asFileReference contents ]
		on: Error
		do: [ :error | error return ].
	[ | releaseData releaseInfo |

	releaseData := '/etc/lsb-release' asFileReference contents.
	releaseInfo := OrderedDictionary new.
	releaseData
		linesDo: [ :line | 
			| labelAndData |

			labelAndData := $= split: line .
			labelAndData size = 2
				then: [ releaseInfo
						at: labelAndData first asLowercase trimBoth
						put: ( labelAndData last trimBoth copyWithout: $" )
					]
			].
	details at: 'release' put: releaseInfo
	]
		on: Error
		do: [ :error | error return ]
]

{ #category : #private }
OperatingSystemInformationProvider >> operatingSystemDetails [

	| details |

	details := OrderedDictionary new.
	Smalltalk os isUnix then: [ self includeLinuxDetailsOn: details ].
	^ details
]

{ #category : #private }
OperatingSystemInformationProvider >> operatingSystemGeneralInfo [

	^ OrderedDictionary new
		at: 'platform' put: Smalltalk os platformName;
		at: 'version' put: Smalltalk os version;
		at: 'subtype' put: Smalltalk os subtype;
		yourself
]
