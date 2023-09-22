Extension { #name : 'StandardStreamLogger' }

{ #category : '*Stargate-Loggers-Tests' }
StandardStreamLogger class >> onStandardErrorFor: beacon [

	^ ( StandardErrorLogger for: beacon )
		  initializeOn: Stdio stderr;
		  yourself
]

{ #category : '*Stargate-Loggers-Tests' }
StandardStreamLogger class >> onStandardOutputFor: beacon [

	^ ( StandardOutputLogger for: beacon )
		  initializeOn: Stdio stdout;
		  yourself
]
