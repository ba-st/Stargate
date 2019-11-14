"
I'm a provider of metrics related to HTTP requests
"
Class {
	#name : #HTTPMetrics,
	#superclass : #MetricProvider,
	#instVars : [
		'groupedRequestCount',
		'groupedResponseSize',
		'groupedRequestResponseDuration'
	],
	#category : #'Stargate-Metrics-HTTP'
}

{ #category : #accessing }
HTTPMetrics class >> providerName [

	^ 'http'
]

{ #category : #initialization }
HTTPMetrics >> finalize [

	super finalize.
	self uninstall
]

{ #category : #calculating }
HTTPMetrics >> gatherMetrics [

	^ groupedRequestCount
		ifEmpty: [ #() ]
		ifNotEmpty: [ Array
				with: self requestCountMetric
				with: self responseSizeMetric
				with: self requestResponseDurationMetric
			]
]

{ #category : #'event handling' }
HTTPMetrics >> handleEvent: aZnServerTransactionEvent [

	| labels |

	labels := self
		labelsForHttpMethod: aZnServerTransactionEvent request method
		responding: aZnServerTransactionEvent response code
		on: aZnServerTransactionEvent request url.
	self
		increaseRequestCountAt: labels;
		increaseResponseSizeAt: labels
			with: ( aZnServerTransactionEvent response contentLength ifNil: [ 0 ] );
		increaseRequestResponseDurationAt: labels with: aZnServerTransactionEvent duration
]

{ #category : #'event handling' }
HTTPMetrics >> handleSimplifiedEvent: aZnSimplifiedServerTransactionEvent [

	| labels |

	labels := self
		labelsForHttpMethod: aZnSimplifiedServerTransactionEvent method
		responding: aZnSimplifiedServerTransactionEvent responseCode
		on: aZnSimplifiedServerTransactionEvent url.
	self
		increaseRequestCountAt: labels;
		increaseResponseSizeAt: labels with: aZnSimplifiedServerTransactionEvent size;
		increaseRequestResponseDurationAt: labels with: aZnSimplifiedServerTransactionEvent duration
]

{ #category : #'private - accumulating' }
HTTPMetrics >> increaseRequestCountAt: labels [

	| previousCount |

	previousCount := groupedRequestCount at: labels ifAbsent: [ 0 ].

	groupedRequestCount at: labels put: previousCount + 1
]

{ #category : #'private - accumulating' }
HTTPMetrics >> increaseRequestResponseDurationAt: labels with: aMillisecondsCount [

	| previousDuration |

	previousDuration := groupedRequestResponseDuration at: labels ifAbsent: [ 0 ].
	groupedRequestResponseDuration at: labels put: previousDuration + aMillisecondsCount
]

{ #category : #'private - accumulating' }
HTTPMetrics >> increaseResponseSizeAt: labels with: aByteCount [

	| previousSize |

	previousSize := groupedResponseSize at: labels ifAbsent: [ 0 ].
	groupedResponseSize at: labels put: previousSize + aByteCount
]

{ #category : #initialization }
HTTPMetrics >> initialize [

	super initialize.
	groupedRequestCount := Dictionary new.
	groupedResponseSize := Dictionary new.
	groupedRequestResponseDuration := Dictionary new
]

{ #category : #actions }
HTTPMetrics >> installOn: teapotServer [

	ZnLogEvent announcer
		when: ZnSimplifiedServerTransactionEvent do: [ :event | self handleSimplifiedEvent: event ];
		when: ZnServerTransactionEvent do: [ :event | self handleEvent: event ].

	teapotServer server setLogLevelAtLeastTo: 1
]

{ #category : #'private - accumulating' }
HTTPMetrics >> labelsForHttpMethod: aMethod responding: anStatusCode on: anUrl [

	^ Array
		with: #http_method -> aMethod
		with: #url -> anUrl asString
		with: #response_code -> anStatusCode
]

{ #category : #'private - metrics' }
HTTPMetrics >> requestCountMetric [

	| builder |

	builder := CompositeMetricBuilder forCounter.
	builder
		named: 'HTTP request count';
		describedBy: 'Number of HTTP requests received'.
	groupedRequestCount
		keysAndValuesDo:
			[ :labels :value | builder addValue: value labeledBy: labels asDictionary at: self currentTimestamp ].
	^ builder build
]

{ #category : #'private - metrics' }
HTTPMetrics >> requestResponseDurationMetric [

	| builder |

	builder := CompositeMetricBuilder forCounter.
	builder
		named: 'HTTP request/response duration in ms';
		describedBy: 'Milliseconds to process a request and produce a response'.
	groupedRequestResponseDuration
		keysAndValuesDo:
			[ :labels :value | builder addValue: value labeledBy: labels asDictionary at: self currentTimestamp ].
	^ builder build
]

{ #category : #'private - metrics' }
HTTPMetrics >> responseSizeMetric [

	| builder |

	builder := CompositeMetricBuilder forCounter.
	builder
		named: 'HTTP response size in bytes';
		describedBy: 'Size in bytes of content in the HTTP responses'.
	groupedResponseSize
		keysAndValuesDo:
			[ :labels :value | builder addValue: value labeledBy: labels asDictionary at: self currentTimestamp ].
	^ builder build
]

{ #category : #actions }
HTTPMetrics >> uninstall [

	ZnLogEvent announcer unsubscribe: self
]
