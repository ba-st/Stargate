Extension { #name : #NeoJSONObjectMapping }

{ #category : #'*Stargate-Model' }
NeoJSONObjectMapping >> mapAsHypermediaControls: aBlock [

	self
		mapProperty: #links
		getter: [ :object | ( ( aBlock cull: object ) collect: [ :assoc | assoc key -> assoc value printString ] ) asDictionary ]
]

{ #category : #'*Stargate-Model' }
NeoJSONObjectMapping >> mapHypermediaControlsIn: aContext [

	self mapAsHypermediaControls: [ aContext hypermediaControls ]
]

{ #category : #'*Stargate-Model' }
NeoJSONObjectMapping >> mapProperty: propertyName getter: readBlock [

	self mapProperty: propertyName getter: readBlock setter: [:object :value | ]
]

{ #category : #'*Stargate-Model' }
NeoJSONObjectMapping >> mapProperty: propertyName setter: writeBlock [

	self mapProperty: propertyName getter: [ :object |  ] setter: writeBlock
]
