Extension { #name : #NeoJSONWriter }

{ #category : #'*Stargate-Model' }
NeoJSONWriter >> mapZincEvent [

	self for: ZnHeaders customDo: [ :mapping | 
		mapping writer: [ :jsonWriter :headers | 
			jsonWriter writeMap: headers ] ].
	self for: ZnRequest do: [ :mapper | 
		mapper
			mapAccessor: #method;
			mapProperty: #uri getter: [ :request | request uri printString ];
			mapProperty: #body getter: [ :request | request contents ];
			mapAccessor: #headers ].
	self for: ZnResponse do: [ :mapper | 
		mapper
			mapAccessor: #code;
			mapProperty: #totalSize
			getter: [ :response | response contentLength ];
			mapProperty: #content getter: [ :response | 
				(response hasEntity and: [ response entity hasContentType ])
					then: [ response contents asString copyNoMoreThanFirst: 4000 ]
					otherwise: [ nil ] ];
			mapAccessor: #headers ].

	{ 
		ZnServerTransactionEvent.
		ZnSimplifiedServerTransactionEvent.
		ZnClientTransactionEvent } do: [ :event | 
		self for: event do: [ :mapper | 
			mapper
				mapProperty: #summary getter: [ :thisEvent | thisEvent printString ];
				mapAccessor: #request;
				mapAccessor: #response ] ]
]
