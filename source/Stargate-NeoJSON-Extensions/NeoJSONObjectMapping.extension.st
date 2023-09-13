Extension { #name : #NeoJSONObjectMapping }

{ #category : #'*Stargate-NeoJSON-Extensions' }
NeoJSONObjectMapping >> mapAsHypermediaControls: aBlock [

	self
		mapProperty: #links
		getter: [ :object | ( ( aBlock cull: object ) collect: [ :assoc | assoc key -> assoc value printString ] ) asDictionary ]
]

{ #category : #'*Stargate-NeoJSON-Extensions' }
NeoJSONObjectMapping >> mapProperty: propertyName getter: readBlock [

	^ self mapProperty: propertyName getter: readBlock setter: [ :object :value |  ]
]

{ #category : #'*Stargate-NeoJSON-Extensions' }
NeoJSONObjectMapping >> mapProperty: propertyName setter: writeBlock [

	^ self mapProperty: propertyName getter: [ :object |  ] setter: writeBlock
]
