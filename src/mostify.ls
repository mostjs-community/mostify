most = require 'most'

create = (require '@most/create').default

_ = require 'ramda'

generate-stream = (type,main-with-callback) -> ->

	user-input = [...arguments] # like .. 'hello.txt',(encoding:'uft')

	(add,end,error) <- create

	user-input[user-input.length] = -> # edit the final argument for add callback

		io-response = [...arguments]

		if (type is 'with error') 

			if io-response[0]

				error [io-response,user-input]

			else

				io-response.shift!

				add [io-response,(_.init user-input)]

		else

			add [io-response,(_.init user-input)]


		end!

	main-with-callback.apply null, user-input





mostify = _.curry (type,module) ->

	switch typeof module
	| 'function' =>
		generate-stream type,module
	| 'object' =>

		keys = Object.keys module

		output = {}

		for key in keys

			output[key] = generate-stream type, module[key]

		output

	| otherwise =>

			throw message:'Mostify: only accepts types function and object',name:'typeError'

			return






module.exports = 
	default:mostify 'no error' # since there are only two options - I haven't used 'no error' string anywhere
	with-error:mostify 'with error'
	__esModule:true # only to maintain babel compatibility - will be removed when babel hype dies down


