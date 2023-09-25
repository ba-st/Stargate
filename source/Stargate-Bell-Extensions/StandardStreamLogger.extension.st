Extension { #name : 'StandardStreamLogger' }

{ #category : '*Stargate-Bell-Extensions' }
StandardStreamLogger class >> isSupportedInStargate [

	^ true
]

{ #category : '*Stargate-Bell-Extensions' }
StandardStreamLogger class >> onStandardErrorFor: beacon [

	^ ( StandardErrorLogger for: beacon )
		  initializeOn: Stdio stderr;
		  yourself
]

{ #category : '*Stargate-Bell-Extensions' }
StandardStreamLogger class >> onStandardOutputFor: beacon [

	^ ( StandardOutputLogger for: beacon )
		  initializeOn: Stdio stdout;
		  yourself
]

{ #category : '*Stargate-Bell-Extensions' }
StandardStreamLogger class >> typeDescription [

	^ self subclassResponsibility
]
