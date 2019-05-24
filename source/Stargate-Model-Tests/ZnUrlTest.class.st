"
I'm a test for extensions on ZnUrl
"
Class {
	#name : #ZnUrlTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-Zinc'
}

{ #category : #tests }
ZnUrlTest >> testQueryAtPutUrl [

	self
		assert:
			( 'https://api.example.com/pets' asUrl
				queryAt: 'relatedTo'
				putUrl: 'https://api.example.com/pets/99' )
		equals: 'https://api.example.com/pets?relatedTo=https%253A%252F%252Fapi.example.com%252Fpets%252F99' asUrl
]

{ #category : #tests }
ZnUrlTest >> testStartLimit [

	self
		assert: ( 'https://api.example.com/pets' asUrl start: 1 limit: 10 )
			equals: 'https://api.example.com/pets?limit=10&start=1' asUrl;
		assert: ( 'https://api.example.com/pets' asUrl start: 1 limit: 10 )
			equals: 'https://api.example.com/pets?start=1&limit=10' asUrl
]
