"
I'm a test case for CrossOriginResourceSharingHandler
"
Class {
	#name : #CrossOriginResourceSharingHandlerTest,
	#superclass : #TestCase,
	#category : #'Stargate-Model-Tests-CORS'
}

{ #category : #tests }
CrossOriginResourceSharingHandlerTest >> testEvaluationOnRequest [

	| handler response |

	handler := CrossOriginResourceSharingHandler allowing: #('GET' 'POST').
	response := handler teaEvalActionOnRequest: (ZnRequest options: 'url').

	self
		assert: response code equals: 204;
		assert: (response headers at: 'Access-Control-Max-Age') equals: '86400';
		assert: (response headers at: 'Access-Control-Allow-Headers')
			equals: 'Access-Control-Allow-Origin, Content-Type, Accept';
		assert: (response headers at: 'Access-Control-Allow-Methods') equals: 'GET, POST'
]
