Extension { #name : #ZnHeaders }

{ #category : #'*Stargate-Model' }
ZnHeaders >> at: headerName addSeparatedWithComma: aValue [

	self at: headerName put: aValue ifPresentMerge: [ :existing :new | existing , ', ' , new ]
]
