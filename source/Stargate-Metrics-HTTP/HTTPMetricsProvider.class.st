"
I'm a provider of metrics related to HTTP requests
"
Class {
	#name : #HTTPMetricsProvider,
	#superclass : #MetricsProvider,
	#instVars : [
		'groupedRequestCount',
		'groupedResponseSize',
		'groupedRequestResponseDuration',
		'categoriesFilter'
	],
	#category : #'Stargate-Metrics-HTTP'
}

{ #category : #'instance creation' }
HTTPMetricsProvider class >> configuredBy: pluginConfiguration [

	^ self basicNew
		initializeConfiguredBy: ( pluginConfiguration at: self providerName ifAbsent: [ Dictionary new ] )
]

{ #category : #'instance creation' }
HTTPMetricsProvider class >> new [

	^ self configuredBy: Dictionary new
]

{ #category : #accessing }
HTTPMetricsProvider class >> providerName [

	^ 'http'
]

{ #category : #initialization }
HTTPMetricsProvider >> finalize [

	super finalize.
	self uninstall
]

{ #category : #calculating }
HTTPMetricsProvider >> gatherMetrics [

	^ groupedRequestCount
		ifEmpty: [ #() ]
		ifNotEmpty: [ Array
				with: self requestCountMetric
				with: self responseSizeMetric
				with: self requestResponseDurationMetric
			]
]

{ #category : #'event handling' }
HTTPMetricsProvider >> handleEvent: aZnServerTransactionEvent [

	| labels |

	labels := self labelsFor: aZnServerTransactionEvent.

	self
		increaseRequestCountAt: labels;
		increaseResponseSizeAt: labels
			with: ( aZnServerTransactionEvent response contentLength ifNil: [ 0 ] );
		increaseRequestResponseDurationAt: labels with: aZnServerTransactionEvent duration
]

{ #category : #'event handling' }
HTTPMetricsProvider >> handleSimplifiedEvent: aZnSimplifiedServerTransactionEvent [

	| labels |

	labels := self labelsFor: aZnSimplifiedServerTransactionEvent.

	self
		increaseRequestCountAt: labels;
		increaseResponseSizeAt: labels with: aZnSimplifiedServerTransactionEvent size;
		increaseRequestResponseDurationAt: labels with: aZnSimplifiedServerTransactionEvent duration
]

{ #category : #'private - accumulating' }
HTTPMetricsProvider >> increaseRequestCountAt: labels [

	| previousCount |

	previousCount := groupedRequestCount at: labels ifAbsent: [ 0 ].

	groupedRequestCount at: labels put: previousCount + 1
]

{ #category : #'private - accumulating' }
HTTPMetricsProvider >> increaseRequestResponseDurationAt: labels with: aMillisecondsCount [

	| previousDuration |

	previousDuration := groupedRequestResponseDuration at: labels ifAbsent: [ 0 ].
	groupedRequestResponseDuration at: labels put: previousDuration + aMillisecondsCount
]

{ #category : #'private - accumulating' }
HTTPMetricsProvider >> increaseResponseSizeAt: labels with: aByteCount [

	| previousSize |

	previousSize := groupedResponseSize at: labels ifAbsent: [ 0 ].
	groupedResponseSize at: labels put: previousSize + aByteCount
]

{ #category : #initialization }
HTTPMetricsProvider >> initializeConfiguredBy: providerConfiguration [

	categoriesFilter := providerConfiguration
		at: #breakdownCategories
		ifPresent: [ :categories | [ :labels | labels select: [ :label | categories includes: label key ] ] ]
		ifAbsent: [ [ :labels | labels ] ].
	groupedRequestCount := Dictionary new.
	groupedResponseSize := Dictionary new.
	groupedRequestResponseDuration := Dictionary new
]

{ #category : #actions }
HTTPMetricsProvider >> installOn: teapotServer [

	ZnLogEvent announcer
		when: ZnSimplifiedServerTransactionEvent do: [ :event | self handleSimplifiedEvent: event ];
		when: ZnServerTransactionEvent do: [ :event | self handleEvent: event ].

	teapotServer server setLogLevelAtLeastTo: 2
]

{ #category : #'private - metrics' }
HTTPMetricsProvider >> labelsFor: aServerTransactionEvent [

	^ categoriesFilter
		value:
			( Array
				with: #http_method -> aServerTransactionEvent method
				with: #url -> aServerTransactionEvent url asString
				with: #response_code -> aServerTransactionEvent responseCode
				with: #url_template -> aServerTransactionEvent urlTemplate )
]

{ #category : #'private - metrics' }
HTTPMetricsProvider >> requestCountMetric [

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
HTTPMetricsProvider >> requestResponseDurationMetric [

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
HTTPMetricsProvider >> responseSizeMetric [

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
HTTPMetricsProvider >> uninstall [

	ZnLogEvent announcer unsubscribe: self
]
