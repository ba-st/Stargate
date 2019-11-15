"
I'm an encoder to convert a metric or metric collection into the Phrometheus v0.0.4 plain text format
"
Class {
	#name : #PrometheusMetricsEncoder,
	#superclass : #Object,
	#instVars : [
		'encodingActionByMetricType'
	],
	#category : #'Stargate-Metrics'
}

{ #category : #'encoding - private' }
PrometheusMetricsEncoder >> encode: aType asTypeLineFor: aMetric on: aWriteStream [

	aWriteStream nextPutAll: '# TYPE '.
	self encodeMetricNameFor: aMetric on: aWriteStream.
	aWriteStream space.
	aType = Gauge then: [ aWriteStream nextPutAll: 'gauge' ].
	aType = Counter then: [ aWriteStream nextPutAll: 'counter' ].	
	aWriteStream lf
]

{ #category : #encoding }
PrometheusMetricsEncoder >> encode: aMetric on: aWriteStream [

	self
		encodeHelpLineFor: aMetric on: aWriteStream;
		encode: aMetric type asTypeLineFor: aMetric on: aWriteStream.
	self valueEncodingActionFor: aMetric on: aWriteStream.
	aWriteStream lf
]

{ #category : #'encoding - private' }
PrometheusMetricsEncoder >> encodeBasic: aBasicMetric on: aWriteStream [

	self encodeMetricNameFor: aBasicMetric on: aWriteStream.
	aWriteStream space.
	self encodeMetricValue: aBasicMetric value on: aWriteStream
]

{ #category : #'encoding - private' }
PrometheusMetricsEncoder >> encodeComposite: aCompositeMetric on: aWriteStream [

	aCompositeMetric metrics
		do: [ :metric | self valueEncodingActionFor: metric on: aWriteStream ]
		separatedBy: [ aWriteStream lf ]
]

{ #category : #'encoding - private' }
PrometheusMetricsEncoder >> encodeHelpLineFor: aMetric on: aWriteStream [

	aWriteStream
		nextPut: $#;
		space;
		nextPutAll: 'HELP';
		space.
	self encodeMetricNameFor: aMetric on: aWriteStream.
	aWriteStream
		space;
		nextPutAll: ( self escapeBackslashAndLineFeeds: aMetric description );
		lf
]

{ #category : #'encoding - private' }
PrometheusMetricsEncoder >> encodeLabeledMetric: aLabeledMetric on: aWriteStream [

	self encodeMetricNameFor: aLabeledMetric metric on: aWriteStream.
	aWriteStream nextPut: ${.
	aLabeledMetric labels associations
		do: [ :association | 
			self encodeName: association key asString on: aWriteStream.
			aWriteStream
				nextPut: $=;
				nextPut: $";
				nextPutAll: ( self escapeQuotesBackslashAndLineFeeds: association value asString );
				nextPut: $"
			]
		separatedBy: [ aWriteStream nextPut: $, ].
	aWriteStream
		nextPut: $};
		space.
	self encodeMetricValue: aLabeledMetric metric value on: aWriteStream
]

{ #category : #'encoding - private' }
PrometheusMetricsEncoder >> encodeMetricNameFor: aMetric on: aWriteStream [

	self encodeName: aMetric name on: aWriteStream
]

{ #category : #'encoding - private' }
PrometheusMetricsEncoder >> encodeMetricValue: aNumber on: aWriteStream [

	aWriteStream nextPutAll: ( [ aNumber asFloat ] unless: aNumber isInteger inWhichCase: [ aNumber ] ) asString
]

{ #category : #'encoding - private' }
PrometheusMetricsEncoder >> encodeName: aName on: aWriteStream [

	aName
		do: [ :character | 
			( character isDigit
				or: [ character asLowercase digitValue between: $a digitValue and: $z digitValue ] )
				then: [ aWriteStream nextPut: character asLowercase ]
				otherwise: [ aWriteStream nextPut: $_ ]
			]
]

{ #category : #'encoding - private' }
PrometheusMetricsEncoder >> encodeTimestampedMetric: aTimestampedMetric on: aWriteStream [

	self valueEncodingActionFor: aTimestampedMetric metric on: aWriteStream.
	aWriteStream
		space;
		nextPutAll: ( aTimestampedMetric timestamp asUTC - DateAndTime unixEpoch ) asMilliSeconds asString
]

{ #category : #'encoding - private' }
PrometheusMetricsEncoder >> encodingActionFor: aMetricType [

	^ encodingActionByMetricType at: aMetricType
]

{ #category : #'encoding - private' }
PrometheusMetricsEncoder >> escapeBackslashAndLineFeeds: aString [

	^ ( aString copyReplaceAll: '\' with: '\\' ) copyReplaceAll: String lf linefeed with: '\n'
]

{ #category : #'encoding - private' }
PrometheusMetricsEncoder >> escapeQuotesBackslashAndLineFeeds: aString [

	^ ( self escapeBackslashAndLineFeeds: aString ) copyReplaceAll: '"' with: '\"'
]

{ #category : #initialization }
PrometheusMetricsEncoder >> initialize [

	super initialize.
	encodingActionByMetricType := Dictionary new.
	encodingActionByMetricType
		at: Counter put: [ :metric :stream | self encodeBasic: metric on: stream ];
		at: Gauge put: [ :metric :stream | self encodeBasic: metric on: stream ];
		at: CompositeMetric put: [ :metric :stream | self encodeComposite: metric on: stream ];
		at: LabeledMetric put: [ :metric :stream | self encodeLabeledMetric: metric on: stream ];
		at: TimestampedMetric put: [ :metric :stream | self encodeTimestampedMetric: metric on: stream ]
]

{ #category : #'encoding - private' }
PrometheusMetricsEncoder >> valueEncodingActionFor: aMetric on: aWriteStream [

	( self encodingActionFor: aMetric class ) value: aMetric value: aWriteStream
]
