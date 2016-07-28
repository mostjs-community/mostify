var most, create, _, generateStream, mostify, slice$ = [].slice;
most = require('most');
create = require('@most/create')['default'];
_ = require('ramda');
generateStream = function(type, mainWithCallback){
  return function(){
    var userInput;
    userInput = slice$.call(arguments);
    return create(function(add, end, error){
      userInput[userInput.length] = function(){
        var ioResponse;
        ioResponse = slice$.call(arguments);
        if (type === 'with error') {
          if (ioResponse[0]) {
            error([ioResponse, userInput]);
          } else {
            ioResponse.shift();
            add([ioResponse, _.init(userInput)]);
          }
        } else {
          add([ioResponse, _.init(userInput)]);
        }
        return end();
      };
      return mainWithCallback.apply(null, userInput);
    });
  };
};
mostify = _.curry(function(type, module){
  var keys, output, i$, len$, key;
  switch (typeof module) {
  case 'function':
    return generateStream(type, module);
  case 'object':
    keys = Object.keys(module);
    output = {};
    for (i$ = 0, len$ = keys.length; i$ < len$; ++i$) {
      key = keys[i$];
      output[key] = generateStream(type, module[key]);
    }
    return output;
  default:
    throw {
      message: 'Mostify: only accepts types function and object',
      name: 'typeError'
    };
  }
});
module.exports = {
  'default': mostify('no error'),
  withError: mostify('with error')
};