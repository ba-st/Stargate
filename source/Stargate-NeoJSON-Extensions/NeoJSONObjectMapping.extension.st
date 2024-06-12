Extension { #name : 'NeoJSONObjectMapping' }

{ #category : '*Stargate-NeoJSON-Extensions' }
NeoJSONObjectMapping >> mapAsHypermediaControls: aBlock [

  self mapProperty: #links getter: [ :object |
      | controls |
      controls := OrderedDictionary new.
      ( aBlock cull: object ) do: [ :webLink |
          controls at: webLink relationType put: webLink url printString ].
      controls
    ]
]

{ #category : '*Stargate-NeoJSON-Extensions' }
NeoJSONObjectMapping >> mapProperty: propertyName getter: readBlock [

	^ self mapProperty: propertyName getter: readBlock setter: [ :object :value |  ]
]

{ #category : '*Stargate-NeoJSON-Extensions' }
NeoJSONObjectMapping >> mapProperty: propertyName setter: writeBlock [

	^ self mapProperty: propertyName getter: [ :object |  ] setter: writeBlock
]
