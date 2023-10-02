Extension { #name : #ZnHeaders }

{ #category : #'*Stargate-Zinc-Extensions' }
ZnHeaders >> at: headerName addSeparatedWithComma: aValue [

	self at: headerName put: aValue ifPresentMerge: [ :existing :new | existing , ', ' , new ]
]
