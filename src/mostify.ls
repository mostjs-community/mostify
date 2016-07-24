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
	




mostify = (module,type = 'without error') ->

	switch typeof module
	|	'function' =>
		generate-stream type,	module
	| 'object' =>

		keys = Object.keys module

		output = {}

		for key in keys

			output[key] = generate-stream type, module[key]

		output

	| otherwise =>

			throw message:'Mostify: only accepts types function and object',name:'typeError'

			return
		

	




module.exports = mostify






# readFile = mostify ((require 'fs').readFile),'with error'


# list-of-files = ['foo.txt','bar.txt','hello.txt']

# response = []

# print = ([response]) ->

# 	console.log response
# 	most.empty!

# for I from 0 til list-of-files.length
# 	response.push do
# 		(readFile list-of-files[I],'utf8',I)
# 		.recoverWith print



# most.mergeArray response
# .recoverWith ([response]) ->
# 	most.empty!
# .map ([response,user-input]) ->

# 	console.log response.toString!

# 	console.log user-input

# .drain!








