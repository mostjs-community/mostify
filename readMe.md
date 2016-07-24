
![](http://imgur.com/NXjwaZr)

### Mostify
Like promisify but for `most.js`


### How to use

```livescript
mostify = require '@partially-applied/mostify'

fs-raw = require 'fs'


fs = mostify fs-raw,'with error' 

# if first argument is error use 'with error' flag

fs.readFile 'hello.txt'
.map ([response]) -> # returns an array
    console.log response.toString() # text file string
.drain!
```

## Features

#### 1. Input Tracking

The return value as you can observe is an array, the array has two elements

```livescript

fs.readFile 'hello.txt'
.map ([response,user-input]) -> 
    console.log user-input[0] # 'hello.txt'
.drain!

```

or with livescript pattern matching to make it nicer

```livescript

fs.readFile 'hello.txt'
.map ([response,[text-file]]) -> # important! returns an array
    console.log text-file # 'hello.txt'
.drain!

```

**Application of Input Tracking**

Input tracking is useful if you want to track the match requests to responses:

```livescript

 request stream : --a--b--c--->
response stream : --b--c--a--->

```

The letters are paired - `--a--` request corrospondes to `--a--` in respose stream. Due to the nature of async computation its not possible to guarantee order, this is why sometimes you want to pass some variable id from request stream into the response stream as a way to track and pair them.

```livescript

most = require 'most'

fs = (require '@partially-applied/mostify') (require 'fs'),'with error'

list-of-files = ['hello.txt','foo.txt','bar.txt']

responses = []

for file in list-of-files
    response.push (fs.readFile file)


most.mergeArray  response
.map ([responses]) ->
    console.log responses # how will you know which response is which file ?
    # good thing the recound array element for each response is file name :)
.drain!




```


**Example with passing extra arguments**


```livescript

# we can even pass an unique index in case file names are not unique

files = ['hello.txt','foo.txt','bar.txt'] # make sure the files exist !

responses = []

for I from 0 til files.length
    response.push (fs.readFile files[I],'ut8',I)


most.mergeArray  response
.map (response) ->
    [output,[filename,encoding,index]] = response
    console.log index # => 0 then 1 then 2 
    # essentially all input arguments get passed
.drain!

```

#### 2. Single Functions

Sometimes you do not want to mostify the entire module but singleton functions. The entry function *type checks* and if the parameter is a function then it only mostifies the function. 


### Type Signature
```livescript

:: [response,userinput]

```

- staying close to all stream API specs, returns a single argument in this    case a Array.
- where `response` is the argument object from the callback that we are intercepting.
- where `userinput` is the argument object which the user passed to the orignal function call
- If you pass 'with error' flag then the assumption is made that the first argument of the callback we are intercepting is the error object:
    - if error object is defined then the error stream is activated
    - `response` argument would be shifted by one element to the left.

 



*Why use mostify rather than just use promises ?*


If you are using `most.js` , creating a promise object seem like a extra unwanted step. Callbacks are the lowest level of absraction you can find and rather than wrapping callbacks using promises and then rewrapping it using `most` streams, I think its more elegant to use use `most` streams directly. It also helps that most streams are also more general while provinding all the error handling goodiness that promise provides.

```livescript
#Before

Node.js style Callback -> Promise -> Most Stream

#After

Node.js style Callback  -> Most Stream
```