
let _ = require( 'wcensor' );
let filePath = _.path.resolve( __dirname, 'File.txt' );

/**/

console.log( `File.txt:\n${_.fileProvider.fileRead( filePath )}\n` );

_.censor.arrangementDel();
_.censor.filesReplace( filePath, 'line', 'abc' );
_.censor.do();

console.log( `File.txt:\n${_.fileProvider.fileRead( filePath )}\n` );

_.censor.undo();

/**/
