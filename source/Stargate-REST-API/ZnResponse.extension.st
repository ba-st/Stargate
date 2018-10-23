Extension { #name : #ZnResponse }

{ #category : #'*Stargate-REST-API' }
ZnResponse >> addLink: aLink [

	self headers
		at: 'Link'
		put: aLink
		ifPresentMerge: [ :old :new | old asString , ',' , new asString ]
]
