
![](https://i.imgur.com/Whw8XEX.jpg)

### Mostify
Like promisify but for `most.js`

```
npm install @partially-applied/mostify
```

### Quick Guide in Code

**JavaScript (ES5)**

```javascript

// mostify returns an object 
// with two functions .withError and .default

var mostify = (require ('@partially-applied/mostify')).withError 

// since we are dealing with fs in this example 
// we will be using .withError option

var fsRaw = require ('fs')


var fs = mostify(fsRaw)

fs.readFile ('hello.txt')

.map(function (input){  
 response = input[0] // returns an array   
 console.log (response.toString()) // text file string
})
.drain()

```


**Babel User**

Using preset `es2015`, the only issue you need to worry about is imports:

```javascript

import mostify from "@partially-applied/mostify" // for .default

import {withError as mostify} from '@partially-applied/mostify' 
// for .withError

```


**LiveScript (ES5)**

```livescript

# mostify returns an object 
# with two functions .withError and .default

mostify = (require '@partially-applied/mostify').withError 

# since we are dealing with fs in this example 
# we will be using .withError option

fs-raw = require 'fs'


fs = mostify fs-raw

fs.readFile 'hello.txt'
.map ([response]) -> # returns an array
    console.log response.toString! # text file string
.drain!
```

## Features

#### 1. Input Tracking

The return value as you can observe is an array, the array has two elements

```js

fs.readFile('hello.txt').map(function(file) {
    console.log(file[0][0].toString()) // file contents
    console.log(file[1]) // [ 'hello.txt' ]
}).drain()

```

or with destructing to make it nicer

```js

fs.readFile('hello.txt').map(([[value],[textFile]]) => {
    console.log(value.toString())
    console.log(textFile) // 'hello.txt'
}).drain()

```

**Application of Input Tracking**

Input tracking is useful if you want to  match requests and responses:

```livescript

 request stream : --a--b--c--->
response stream : --b--c--a--->

```

The letters are paired - `--a--` in request stream corresponds to `--a--` in respose stream. Due to the nature of async computation its not possible to guarantee order, this is why sometimes you want to pass some variable id from request stream into the response stream as a way to track and pair them.

```js

var most = require('most')

var fs = (require('@partially-applied/mostify')).withError(require('fs'))

// a list of sample files to read
var listOfFiles = ['hello.txt','foo.txt','bar.txt']

var responses = [] // an array that will store a list of streams

listOfFiles.forEach(file => responses.push(fs.readFile(file)))

// merge all the streams in the array
most.mergeArray(responses).map(function([[value], [filename]]) {
    // how will you match which value is the output of which file ?
    // good thing the secound array element has filenames.
    console.log(filename + ":", value.toString())
}).drain()

```


**Example with passing extra arguments**


```js

// we can even pass an unique index in case file names are not unique

var files = ['hello.txt','foo.txt','bar.txt'] // make sure the files exist !

var responses = []

files.forEach((file, i) => responses.push(fs.readFile(file, 'utf8', i)))

most.mergeArray(responses).map(([[value],[filename,encoding,index]]) => {
    console.log(index) // => 0 then 1 then 2
    // essentially all input arguments get passed
}).drain()

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


If you are using `most.js` , creating a promise object seem like a extra unwanted step. Callbacks are the lowest level of abstraction you can find and rather than wrapping callbacks using promises and then rewrapping it using `most` streams, I think its more elegant to use `most` streams directly. It also helps that most streams are also more general while providing all the error handling goodiness that promise provides.

```livescript

#Before
Node.js style Callback -> Promise -> Most Stream

#After
Node.js style Callback  -> Most Stream

```
