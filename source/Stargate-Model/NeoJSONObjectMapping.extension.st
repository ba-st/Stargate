Extension { #name : #NeoJSONObjectMapping }

{ #category : #'*Stargate-Model' }
NeoJSONObjectMapping >> mapAsHypermediaControls: aBlock [

	self
		mapProperty: #links
		getter: [ :object | ((aBlock cull: object) collect: [ :assoc | assoc key -> assoc value printString ]) asDictionary ]
		setter: [ :object :value |  ]
]

{ #category : #'*Stargate-Model' }
NeoJSONObjectMapping >> mapHypermediaControlsIn: aContext [

	self mapAsHypermediaControls: [ aContext hypermediaControls ]
]
