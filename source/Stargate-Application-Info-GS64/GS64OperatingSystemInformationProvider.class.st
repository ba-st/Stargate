"
I'm a provider of information about the Operating System running this application
"
Class {
	#name : #GS64OperatingSystemInformationProvider,
	#superclass : #ApplicationInformationProvider,
	#category : #'Stargate-Application-Info-GS64'
}

{ #category : #accessing }
GS64OperatingSystemInformationProvider class >> providerName [

	^ 'os'
]

{ #category : #private }
GS64OperatingSystemInformationProvider >> environmentInfo [

	| environmentInfo |

	environmentInfo := OrderedDictionary new.
	( System performOnServer: 'env | sort' ) linesDo: [ :line |
		| keyValue |
		keyValue := $= split: line.
		environmentInfo at: keyValue first put: keyValue last
		].
	^ environmentInfo
]

{ #category : #querying }
GS64OperatingSystemInformationProvider >> gatherInformation [

	^ OrderedDictionary new
		at: 'general' put: self operatingSystemGeneralInfo;
		at: 'details' put: self operatingSystemDetails;
		at: 'environment' put: self environmentInfo;
		yourself
]

{ #category : #private }
GS64OperatingSystemInformationProvider >> operatingSystemDetails [

	| details |

	details := OrderedDictionary new.
	[ details at: 'version' put: ( System performOnServer: 'cat /proc/version' ) trimSeparators ]
		on: Error
		do: [ :error | error return ].
	[
	| releaseData releaseInfo |

	releaseData := '/etc/os-release' asFileReference contents.
	releaseInfo := OrderedDictionary new.
	releaseData linesDo: [ :line |
		| labelAndData |

		labelAndData := $= split: line.
		labelAndData size = 2 then: [
			releaseInfo
				at: labelAndData first asLowercase trimBoth
				put: ( labelAndData last trimBoth copyWithout: $" )
			]
		].
	details at: 'release' put: releaseInfo
	]
		on: Error
		do: [ :error | error return ].
	^ details
]

{ #category : #private }
GS64OperatingSystemInformationProvider >> operatingSystemGeneralInfo [

	| report |

	report := System gemVersionReport.
	^ OrderedDictionary new
		  at: 'platform' put: 'unix';
		  at: 'version' put: ( report at: 'osName' );
		  at: 'subtype' put: ( report at: 'cpuKind' );
		  yourself
]
