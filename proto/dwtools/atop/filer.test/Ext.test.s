( function _Ext_test_s_( )
{

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../dwtools/Tools.s' );
  _.include( 'wTesting' );;
}

let _ = _testerGlobal_.wTools;

// --
// context
// --

function onSuiteBegin()
{
  let context = this;
  context.suiteTempPath = _.path.pathDirTempOpen( _.path.join( __dirname, '../..' ), 'filer' );
  context.assetsOriginalPath = _.path.join( __dirname, '_asset' );
  context.appJsPath = _.path.nativize( _.module.resolve( 'wFiler' ) );
}

//

function onSuiteEnd()
{
  let context = this;
  _.assert( _.strHas( context.suiteTempPath, '/filer' ) )
  _.path.pathDirTempClose( context.suiteTempPath );
}

// --
// tests
// --

function replaceBasic( test )
{
  let context = this;
  let a = test.assetFor( 'basic' );

  a.reflect();
  let file1Before = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
  let file2Before = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = '.replace filePath:before/** ins:line sub:abc';
    a.reflect();
    return null;
  })

  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  .then( ( op ) =>
  {
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '. Found 2 file(s). Arranged 8 replacement(s) in 2 file(s)' ), 1 );

    var exp =
`
+ replace 3 in ${ a.abs( 'before/File1.txt' ) }
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
+ replace 5 in ${ a.abs( 'before/File2.txt' ) }
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Fourth line
4 : Third line
5 : Fourth lineabc
6 : Fifth line
5 : Fourth line
6 : Fifth lineabc
7 : Last one
. Found 2 file(s). Arranged 8 replacement(s) in 2 file(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  /* - */

  return a.ready;
}

//

function replaceStatusOptionVerbosity( test )
{
  let context = this;
  let a = test.assetFor( 'basic' );

  a.reflect();
  let file1Before = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
  let file2Before = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );

  /* - */

  a.ready.then( ( op ) =>
  {
    test.description = 'setup';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  .then( ( op ) =>
  {
    test.description = '.replace filePath:before/** ins:line sub:abc';
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '. Found 2 file(s). Arranged 8 replacement(s) in 2 file(s)' ), 1 );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  /* - */

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.case = '.status v:1';
    test.identical( op.exitCode, 0 );

    var exp =
`
  redo : 2
  undo : 0
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  /* */

  a.appStart( '.status v:2' )
  .then( ( op ) =>
  {
    test.case = '.status v:2';
    test.identical( op.exitCode, 0 );

    var exp =
`
  redo :
     + replace 3 in ${ a.abs( 'before/File1.txt' ) }
     + replace 5 in ${ a.abs( 'before/File2.txt' ) }
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  /* */

  a.appStart( '.status' )
  .then( ( op ) =>
  {
    test.case = '.status';
    test.identical( op.exitCode, 0 );

    var exp =
`
redo :
  + replace 3 in ${ a.abs( 'before/File1.txt' ) }
  1 : First lineabc
  2 : Second line
  2 : First line
  3 : Second lineabc
  4 : Third line
  3 : Second line
  4 : Third lineabc
  5 : Last one
  + replace 5 in ${ a.abs( 'before/File2.txt' ) }
  1 : First lineabc
  2 : Second line
  2 : First line
  3 : Second lineabc
  4 : Third line
  3 : Second line
  4 : Third lineabc
  5 : Fourth line
  4 : Third line
  5 : Fourth lineabc
  6 : Fifth line
  5 : Fourth line
  6 : Fifth lineabc
  7 : Last one
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  /* */

  a.appStart( '.status v:3' )
  .then( ( op ) =>
  {
    test.case = '.status v:3';
    test.identical( op.exitCode, 0 );

    var exp =
`
redo :
  + replace 3 in ${ a.abs( 'before/File1.txt' ) }
  1 : First lineabc
  2 : Second line
  2 : First line
  3 : Second lineabc
  4 : Third line
  3 : Second line
  4 : Third lineabc
  5 : Last one
  + replace 5 in ${ a.abs( 'before/File2.txt' ) }
  1 : First lineabc
  2 : Second line
  2 : First line
  3 : Second lineabc
  4 : Third line
  3 : Second line
  4 : Third lineabc
  5 : Fourth line
  4 : Third line
  5 : Fourth lineabc
  6 : Fifth line
  5 : Fourth line
  6 : Fifth lineabc
  7 : Last one
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  /* - */

  return a.ready;
}

//

function replaceRedoOptionVerbosity( test )
{
  let context = this;
  let a = test.assetFor( 'basic' );

  a.reflect();

  let file1Before = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
  let file2Before = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
  let file1After = a.fileProvider.fileRead( a.abs( 'after/File1.txt' ) );
  let file2After = a.fileProvider.fileRead( a.abs( 'after/File2.txt' ) );

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'v:0';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  .then( ( op ) =>
  {
    test.description = '.replace filePath:before/** ins:line sub:abc';
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '. Found 2 file(s). Arranged 8 replacement(s) in 2 file(s)' ), 1 );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1 v:0' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 1
undo : 1
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1 v:0' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1 v:0' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'v:1';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  .then( ( op ) =>
  {
    test.description = '.replace filePath:before/** ins:line sub:abc';
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '. Found 2 file(s). Arranged 8 replacement(s) in 2 file(s)' ), 1 );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1 v:1' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
Done 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 1
undo : 1
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1 v:1' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
Done 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1 v:1' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to redo.
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'v:2';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  .then( ( op ) =>
  {
    test.description = '.replace filePath:before/** ins:line sub:abc';
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '. Found 2 file(s). Arranged 8 replacement(s) in 2 file(s)' ), 1 );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1 v:2' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
+ replace 3 in ${ a.abs( 'before/File1.txt' ) }
Done 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 1
undo : 1
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1 v:2' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Fourth line
4 : Third line
5 : Fourth lineabc
6 : Fifth line
5 : Fourth line
6 : Fifth lineabc
7 : Last one
+ replace 5 in ${ a.abs( 'before/File2.txt' ) }
Done 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1 v:2' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to redo.
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'v:3';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  .then( ( op ) =>
  {
    test.description = '.replace filePath:before/** ins:line sub:abc';
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '. Found 2 file(s). Arranged 8 replacement(s) in 2 file(s)' ), 1 );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
+ replace 3 in ${ a.abs( 'before/File1.txt' ) }
Done 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 1
undo : 1
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Fourth line
4 : Third line
5 : Fourth lineabc
6 : Fifth line
5 : Fourth line
6 : Fifth lineabc
7 : Last one
+ replace 5 in ${ a.abs( 'before/File2.txt' ) }
Done 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to redo.
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'verbosity : default';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  .then( ( op ) =>
  {
    test.description = '.replace filePath:before/** ins:line sub:abc';
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '. Found 2 file(s). Arranged 8 replacement(s) in 2 file(s)' ), 1 );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
+ replace 3 in ${ a.abs( 'before/File1.txt' ) }
Done 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 1
undo : 1
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Fourth line
4 : Third line
5 : Fourth lineabc
6 : Fifth line
5 : Fourth line
6 : Fifth lineabc
7 : Last one
+ replace 5 in ${ a.abs( 'before/File2.txt' ) }
Done 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to redo.
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  /* - */

  return a.ready;
}

//

function replaceRedoOptionDepth( test )
{
  let context = this;
  let a = test.assetFor( 'basic' );

  a.reflect();

  let file1Before = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
  let file2Before = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
  let file1After = a.fileProvider.fileRead( a.abs( 'after/File1.txt' ) );
  let file2After = a.fileProvider.fileRead( a.abs( 'after/File2.txt' ) );

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'd:1';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
+ replace 3 in ${ a.abs( 'before/File1.txt' ) }
Done 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 1
undo : 1
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Fourth line
4 : Third line
5 : Fourth lineabc
6 : Fifth line
5 : Fourth line
6 : Fifth lineabc
7 : Last one
+ replace 5 in ${ a.abs( 'before/File2.txt' ) }
Done 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to redo.
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })
  a.ready.then( ( op ) =>
  {
    test.case = 'd:1';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
+ replace 3 in ${ a.abs( 'before/File1.txt' ) }
Done 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 1
undo : 1
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Fourth line
4 : Third line
5 : Fourth lineabc
6 : Fifth line
5 : Fourth line
6 : Fifth lineabc
7 : Last one
+ replace 5 in ${ a.abs( 'before/File2.txt' ) }
Done 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to redo.
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'd:2';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:2' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
+ replace 3 in ${ a.abs( 'before/File1.txt' ) }
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Fourth line
4 : Third line
5 : Fourth lineabc
6 : Fifth line
5 : Fourth line
6 : Fifth lineabc
7 : Last one
+ replace 5 in ${ a.abs( 'before/File2.txt' ) }
Done 2 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:2' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to redo.
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'd:3';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
+ replace 3 in ${ a.abs( 'before/File1.txt' ) }
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Fourth line
4 : Third line
5 : Fourth lineabc
6 : Fifth line
5 : Fourth line
6 : Fifth lineabc
7 : Last one
+ replace 5 in ${ a.abs( 'before/File2.txt' ) }
Done 2 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to redo.
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'd:0';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:0' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
+ replace 3 in ${ a.abs( 'before/File1.txt' ) }
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Fourth line
4 : Third line
5 : Fourth lineabc
6 : Fifth line
5 : Fourth line
6 : Fifth lineabc
7 : Last one
+ replace 5 in ${ a.abs( 'before/File2.txt' ) }
Done 2 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:0' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to redo.
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'd : default';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
+ replace 3 in ${ a.abs( 'before/File1.txt' ) }
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Fourth line
4 : Third line
5 : Fourth lineabc
6 : Fifth line
5 : Fourth line
6 : Fifth lineabc
7 : Last one
+ replace 5 in ${ a.abs( 'before/File2.txt' ) }
Done 2 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to redo.
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  /* - */

  return a.ready;
}

//

function replaceChangeRedo( test )
{
  let context = this;
  let a = test.assetFor( 'basic' );

  a.reflect();

  let file1Before = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
  let file2Before = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
  let file1After = a.fileProvider.fileRead( a.abs( 'after/File1.txt' ) );
  let file2After = a.fileProvider.fileRead( a.abs( 'after/File2.txt' ) );

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'outdated File1.txt';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );

    a.fileProvider.fileWrite( a.abs( 'before/File1.txt' ), file1Before + 'xyz' );

    return null;
  })

  a.appStartNonThrowing( '.redo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.notIdentical( op.exitCode, 0 );

    var exp =
`
 ! failed to redo action::replace 3 in ${ a.abs( 'before/File1.txt' ) }
    Files are outdated:
      ${ a.abs( 'before/File1.txt' ) }
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Fourth line
4 : Third line
5 : Fourth lineabc
6 : Fifth line
5 : Fourth line
6 : Fifth lineabc
7 : Last one
 + replace 5 in ${ a.abs( 'before/File2.txt' ) }
Done 1 action(s). Thrown 1 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before + 'xyz' );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 1 -- 1 error(s)
undo : 1
`
    test.equivalent( op.output, exp );

    return null;
  })

  a.appStartNonThrowing( '.redo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.notIdentical( op.exitCode, 0 );

    var exp =
`
 ! failed to redo action::replace 3 in ${ a.abs( 'before/File1.txt' ) }
    Files are outdated:
      ${ a.abs( 'before/File1.txt' ) }
Done 0 action(s). Thrown 1 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before + 'xyz' );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 1 -- 1 error(s)
undo : 1
`
    test.equivalent( op.output, exp );

    a.fileProvider.fileWrite( a.abs( 'before/File1.txt' ), file1Before );

    return null;
  })

  a.appStartNonThrowing( '.redo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
+ replace 3 in ${ a.abs( 'before/File1.txt' ) }
Done 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'outdated File2.txt';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );

    a.fileProvider.fileWrite( a.abs( 'before/File2.txt' ), file2Before + 'xyz' );

    return null;
  })

  a.appStartNonThrowing( '.redo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.notIdentical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
 + replace 3 in ${ a.abs( 'before/File1.txt' ) }
 ! failed to redo action::replace 5 in ${ a.abs( 'before/File2.txt' ) }
    Files are outdated:
      ${ a.abs( 'before/File2.txt' ) }
Done 1 action(s). Thrown 1 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before + 'xyz' );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 1 -- 1 error(s)
undo : 1
`
    test.equivalent( op.output, exp );

    return null;
  })

  a.appStartNonThrowing( '.redo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.notIdentical( op.exitCode, 0 );

    var exp =
`
 ! failed to redo action::replace 5 in ${ a.abs( 'before/File2.txt' ) }
    Files are outdated:
      ${ a.abs( 'before/File2.txt' ) }
Done 0 action(s). Thrown 1 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before + 'xyz' );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 1 -- 1 error(s)
undo : 1
`
    test.equivalent( op.output, exp );

    a.fileProvider.fileWrite( a.abs( 'before/File2.txt' ), file2Before );

    return null;
  })

  a.appStartNonThrowing( '.redo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Fourth line
4 : Third line
5 : Fourth lineabc
6 : Fifth line
5 : Fourth line
6 : Fifth lineabc
7 : Last one
+ replace 5 in ${ a.abs( 'before/File2.txt' ) }
Done 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'outdated File1.txt File2.txt';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );

    a.fileProvider.fileWrite( a.abs( 'before/File1.txt' ), file1Before + 'xyz' );
    a.fileProvider.fileWrite( a.abs( 'before/File2.txt' ), file2Before + 'xyz' );

    return null;
  })

  a.appStartNonThrowing( '.redo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.notIdentical( op.exitCode, 0 );

    var exp =
`
 ! failed to redo action::replace 3 in ${ a.abs( 'before/File1.txt' ) }
    Files are outdated:
      ${ a.abs( 'before/File1.txt' ) }
 ! failed to redo action::replace 5 in ${ a.abs( 'before/File2.txt' ) }
    Files are outdated:
      ${ a.abs( 'before/File2.txt' ) }
Done 0 action(s). Thrown 2 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before + 'xyz' );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before + 'xyz' );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2 -- 2 error(s)
undo : 0
`
    test.equivalent( op.output, exp );

    return null;
  })

  a.appStartNonThrowing( '.redo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.notIdentical( op.exitCode, 0 );

    var exp =
`
 ! failed to redo action::replace 3 in ${ a.abs( 'before/File1.txt' ) }
    Files are outdated:
      ${ a.abs( 'before/File1.txt' ) }
 ! failed to redo action::replace 5 in ${ a.abs( 'before/File2.txt' ) }
    Files are outdated:
      ${ a.abs( 'before/File2.txt' ) }
Done 0 action(s). Thrown 2 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before + 'xyz' );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before + 'xyz' );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2 -- 2 error(s)
undo : 0
`
    test.equivalent( op.output, exp );

    a.fileProvider.fileWrite( a.abs( 'before/File1.txt' ), file1Before );
    a.fileProvider.fileWrite( a.abs( 'before/File2.txt' ), file2Before );

    return null;
  })

  a.appStartNonThrowing( '.redo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
+ replace 3 in ${ a.abs( 'before/File1.txt' ) }
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Fourth line
4 : Third line
5 : Fourth lineabc
6 : Fifth line
5 : Fourth line
6 : Fifth lineabc
7 : Last one
+ replace 5 in ${ a.abs( 'before/File2.txt' ) }
Done 2 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );

    return null;
  })

  /* - */

  return a.ready;
}

//

function replaceRedoDepth0OptionVerbosity( test )
{
  let context = this;
  let a = test.assetFor( 'basic' );

  a.reflect();
  let file1Before = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
  let file2Before = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
  let file1After = a.fileProvider.fileRead( a.abs( 'after/File1.txt' ) );
  let file2After = a.fileProvider.fileRead( a.abs( 'after/File2.txt' ) );

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'v:0';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  .then( ( op ) =>
  {
    test.description = '.replace filePath:before/** ins:line sub:abc';
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '. Found 2 file(s). Arranged 8 replacement(s) in 2 file(s)' ), 1 );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.do v:0' )
  .then( ( op ) =>
  {
    test.description = '.do';
    test.identical( op.exitCode, 0 );

    var exp =
`
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.do v:0' )
  .then( ( op ) =>
  {
    test.description = '.do';
    test.identical( op.exitCode, 0 );

    var exp =
`
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'v:1';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  .then( ( op ) =>
  {
    test.description = '.replace filePath:before/** ins:line sub:abc';
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '. Found 2 file(s). Arranged 8 replacement(s) in 2 file(s)' ), 1 );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.do v:1' )
  .then( ( op ) =>
  {
    test.description = '.do';
    test.identical( op.exitCode, 0 );

    var exp =
`
Done 2 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.do v:1' )
  .then( ( op ) =>
  {
    test.description = '.do';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to redo.
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'v:2';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  .then( ( op ) =>
  {
    test.description = '.replace filePath:before/** ins:line sub:abc';
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '. Found 2 file(s). Arranged 8 replacement(s) in 2 file(s)' ), 1 );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.do v:2' )
  .then( ( op ) =>
  {
    test.description = '.do';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
+ replace 3 in ${ a.abs( 'before/File1.txt' ) }
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Fourth line
4 : Third line
5 : Fourth lineabc
6 : Fifth line
5 : Fourth line
6 : Fifth lineabc
7 : Last one
+ replace 5 in ${ a.abs( 'before/File2.txt' ) }
Done 2 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.do v:2' )
  .then( ( op ) =>
  {
    test.description = '.do';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to redo.
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'v:3';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  .then( ( op ) =>
  {
    test.description = '.replace filePath:before/** ins:line sub:abc';
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '. Found 2 file(s). Arranged 8 replacement(s) in 2 file(s)' ), 1 );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.do v:3' )
  .then( ( op ) =>
  {
    test.description = '.do';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
+ replace 3 in ${ a.abs( 'before/File1.txt' ) }
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Fourth line
4 : Third line
5 : Fourth lineabc
6 : Fifth line
5 : Fourth line
6 : Fifth lineabc
7 : Last one
+ replace 5 in ${ a.abs( 'before/File2.txt' ) }
Done 2 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.do v:3' )
  .then( ( op ) =>
  {
    test.description = '.do';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to redo.
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'verbosity : default';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  .then( ( op ) =>
  {
    test.description = '.replace filePath:before/** ins:line sub:abc';
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '. Found 2 file(s). Arranged 8 replacement(s) in 2 file(s)' ), 1 );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.do' )
  .then( ( op ) =>
  {
    test.description = '.do';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
+ replace 3 in ${ a.abs( 'before/File1.txt' ) }
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Fourth line
4 : Third line
5 : Fourth lineabc
6 : Fifth line
5 : Fourth line
6 : Fifth lineabc
7 : Last one
+ replace 5 in ${ a.abs( 'before/File2.txt' ) }
Done 2 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.do' )
  .then( ( op ) =>
  {
    test.description = '.do';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to redo.
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  /* - */

  return a.ready;
}

//

function replaceRedoHardLinked( test )
{
  let context = this;
  let a = test.assetFor( 'basic' );

  a.reflect();

  let file1Before = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
  let file2Before = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
  let file1After = a.fileProvider.fileRead( a.abs( 'after/File1.txt' ) );
  let file2After = a.fileProvider.fileRead( a.abs( 'after/File2.txt' ) );

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'basic';
    a.reflect();
    a.fileProvider.hardLink
    ({
      dstPath : a.abs( 'before/dir/Link.txt' ),
      srcPath : a.abs( 'before/File1.txt' ),
      makingDirectory : 1,
    });
    test.is( a.fileProvider.areHardLinked( a.abs( 'before/dir/Link.txt' ), a.abs( 'before/File1.txt' ) ) );
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )

  a.appStart( '.status v:2' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
  redo :
     + replace 3 in ${ a.abs( 'before/File1.txt' ) }
     + replace 5 in ${ a.abs( 'before/File2.txt' ) }
`
    test.equivalent( op.output, exp );

    return null;
  })

  a.appStart( '.redo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
 + replace 3 in ${ a.abs( 'before/File1.txt' ) }
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Fourth line
4 : Third line
5 : Fourth lineabc
6 : Fifth line
5 : Fourth line
6 : Fifth lineabc
7 : Last one
 + replace 5 in ${ a.abs( 'before/File2.txt' ) }
Done 2 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp =
    [
      '.',
      './after',
      './after/File1.txt',
      './after/File2.txt',
      './before',
      './before/File1.txt',
      './before/File2.txt',
      './before/dir',
      './before/dir/Link.txt',
    ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );
    var got = a.fileProvider.fileRead( a.abs( 'before/dir/Link.txt' ) );
    test.identical( got, file1After );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'dir only';
    a.reflect();
    a.fileProvider.hardLink
    ({
      dstPath : a.abs( 'before/dir/Link.txt' ),
      srcPath : a.abs( 'before/File1.txt' ),
      makingDirectory : 1,
    });
    test.is( a.fileProvider.areHardLinked( a.abs( 'before/dir/Link.txt' ), a.abs( 'before/File1.txt' ) ) );
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/dir/** ins:line sub:abc' )

  a.appStart( '.status v:2' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
  redo :
     + replace 3 in ${ a.abs( 'before/dir/Link.txt' ) }
`
    test.equivalent( op.output, exp );

    return null;
  })

  a.appStart( '.redo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
 + replace 3 in ${ a.abs( 'before/dir/Link.txt' ) }
Done 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp =
    [
      '.',
      './after',
      './after/File1.txt',
      './after/File2.txt',
      './before',
      './before/File1.txt',
      './before/File2.txt',
      './before/dir',
      './before/dir/Link.txt',
    ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/dir/Link.txt' ) );
    test.identical( got, file1After );

    return null;
  })

  /* - */

  return a.ready;
}

//

function replaceRedoSoftLinked( test )
{
  let context = this;
  let a = test.assetFor( 'basic' );

  a.reflect();

  let file1Before = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
  let file2Before = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
  let file1After = a.fileProvider.fileRead( a.abs( 'after/File1.txt' ) );
  let file2After = a.fileProvider.fileRead( a.abs( 'after/File2.txt' ) );

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'basic';
    a.reflect();
    a.fileProvider.softLink
    ({
      dstPath : a.abs( 'before/dir/Link.txt' ),
      srcPath : a.abs( 'before/File1.txt' ),
      makingDirectory : 1,
    });
    test.is( a.fileProvider.areSoftLinked( a.abs( 'before/dir/Link.txt' ), a.abs( 'before/File1.txt' ) ) );
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )

  a.appStart( '.status v:2' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
  redo :
     + replace 3 in ${ a.abs( 'before/File1.txt' ) }
     + replace 5 in ${ a.abs( 'before/File2.txt' ) }
`
    test.equivalent( op.output, exp );

    return null;
  })

  a.appStart( '.redo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
 + replace 3 in ${ a.abs( 'before/File1.txt' ) }
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Fourth line
4 : Third line
5 : Fourth lineabc
6 : Fifth line
5 : Fourth line
6 : Fifth lineabc
7 : Last one
 + replace 5 in ${ a.abs( 'before/File2.txt' ) }
Done 2 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp =
    [
      '.',
      './after',
      './after/File1.txt',
      './after/File2.txt',
      './before',
      './before/File1.txt',
      './before/File2.txt',
      './before/dir',
      './before/dir/Link.txt',
    ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );
    var got = a.fileProvider.fileRead( a.abs( 'before/dir/Link.txt' ) );
    test.identical( got, file1After );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'dir only';
    a.reflect();
    a.fileProvider.softLink
    ({
      dstPath : a.abs( 'before/dir/Link.txt' ),
      srcPath : a.abs( 'before/File1.txt' ),
      makingDirectory : 1,
    });
    test.is( a.fileProvider.areSoftLinked( a.abs( 'before/dir/Link.txt' ), a.abs( 'before/File1.txt' ) ) );
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/dir/** ins:line sub:abc' )

  a.appStart( '.status v:2' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
  redo :
     + replace 3 in ${ a.abs( 'before/dir/Link.txt' ) }
`
    test.equivalent( op.output, exp );

    debugger;
    return null;
  })

  a.appStart( '.redo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );
    debugger;

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
 + replace 3 in ${ a.abs( 'before/dir/Link.txt' ) }
Done 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp =
    [
      '.',
      './after',
      './after/File1.txt',
      './after/File2.txt',
      './before',
      './before/File1.txt',
      './before/File2.txt',
      './before/dir',
      './before/dir/Link.txt',
    ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/dir/Link.txt' ) );
    test.identical( got, file1After );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'dir only';
    a.reflect();
    a.fileProvider.dirMake( a.abs( 'before/dir1' ) );
    a.fileProvider.softLink
    ({
      dstPath : a.abs( 'before/dir2' ),
      srcPath : a.abs( 'before/dir1' ),
      makingDirectory : 1,
    });
    a.fileProvider.softLink
    ({
      dstPath : a.abs( 'before/dir2/Link.txt' ),
      srcPath : a.abs( 'before/File1.txt' ),
      makingDirectory : 1,
    });

    test.is( !a.fileProvider.isSoftLink( a.abs( 'before/dir1' ) ) );
    test.is( a.fileProvider.isSoftLink( a.abs( 'before/dir1/Link.txt' ) ) );
    test.is( a.fileProvider.isSoftLink( a.abs( 'before/dir2' ) ) );
    test.is( a.fileProvider.isSoftLink( a.abs( 'before/dir2/Link.txt' ) ) );

    test.is( a.fileProvider.areSoftLinked( a.abs( 'before/dir2' ), a.abs( 'before/dir1' ) ) );
    test.is( a.fileProvider.areSoftLinked( a.abs( 'before/dir2/Link.txt' ), a.abs( 'before/dir1/Link.txt' ) ) );
    test.is( a.fileProvider.areSoftLinked( a.abs( 'before/dir2/Link.txt' ), a.abs( 'before/File1.txt' ) ) );
    test.is( a.fileProvider.areSoftLinked( a.abs( 'before/dir1/Link.txt' ), a.abs( 'before/File1.txt' ) ) );

    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/dir2/** ins:line sub:abc' )

  a.appStart( '.status v:2' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
  redo :
     + replace 3 in ${ a.abs( 'before/dir2/Link.txt' ) }
`
    test.equivalent( op.output, exp );

    debugger;
    return null;
  })

  a.appStart( '.redo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );
    debugger;

    var exp =
`
1 : First lineabc
2 : Second line
2 : First line
3 : Second lineabc
4 : Third line
3 : Second line
4 : Third lineabc
5 : Last one
 + replace 3 in ${ a.abs( 'before/dir2/Link.txt' ) }
Done 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp =
    [
      '.',
      './after',
      './after/File1.txt',
      './after/File2.txt',
      './before',
      './before/File1.txt',
      './before/File2.txt',
      './before/dir1',
      './before/dir1/Link.txt',
      './before/dir2',
      './before/dir2/Link.txt'
    ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/dir2/Link.txt' ) );
    test.identical( got, file1After );

    test.is( !a.fileProvider.isSoftLink( a.abs( 'before/dir1' ) ) );
    test.is( a.fileProvider.isSoftLink( a.abs( 'before/dir1/Link.txt' ) ) );
    test.is( a.fileProvider.isSoftLink( a.abs( 'before/dir2' ) ) );
    test.is( a.fileProvider.isSoftLink( a.abs( 'before/dir2/Link.txt' ) ) );

    test.is( a.fileProvider.areSoftLinked( a.abs( 'before/dir2' ), a.abs( 'before/dir1' ) ) );
    test.is( a.fileProvider.areSoftLinked( a.abs( 'before/dir2/Link.txt' ), a.abs( 'before/dir1/Link.txt' ) ) );
    test.is( a.fileProvider.areSoftLinked( a.abs( 'before/dir2/Link.txt' ), a.abs( 'before/File1.txt' ) ) );
    test.is( a.fileProvider.areSoftLinked( a.abs( 'before/dir1/Link.txt' ), a.abs( 'before/File1.txt' ) ) );

    return null;
  })

  /* - */

  return a.ready;
}

// --
// redo - undo
// --

function replaceRedoUndo( test )
{
  let context = this;
  let a = test.assetFor( 'basic' );

  a.reflect();
  let file1Before = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
  let file2Before = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
  let file1After = a.fileProvider.fileRead( a.abs( 'after/File1.txt' ) );
  let file2After = a.fileProvider.fileRead( a.abs( 'after/File2.txt' ) );

  /* - */

  a.ready.then( ( op ) =>
  {
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  .then( ( op ) =>
  {
    test.description = '.replace filePath:before/** ins:line sub:abc';
    test.identical( op.exitCode, 0 );
    test.identical( _.strCount( op.output, '. Found 2 file(s). Arranged 8 replacement(s) in 2 file(s)' ), 1 );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1' )
  a.appStart( '.status v:1' )
  a.appStart( '.undo d:1' )
  .then( ( op ) =>
  {
    test.description = '.redo d:1 .undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
+ undo replace 3 in ${ a.abs( 'before/File1.txt' ) }
Undone 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1' )
  a.appStart( '.redo d:1' )
  a.appStart( '.undo d:1' )
  .then( ( op ) =>
  {
    test.description = '.redo d:1 .redo .undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
+ undo replace 5 in ${ a.abs( 'before/File2.txt' ) }
Undone 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 1
undo : 1
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.undo d:1' )
  .then( ( op ) =>
  {
    test.description = '.redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
+ undo replace 3 in ${ a.abs( 'before/File1.txt' ) }
Undone 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );
    return null;
  })

  a.appStart( '.redo d:1' )
  a.appStart( '.redo d:1' )
  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.redo d:1 .redo';
    test.identical( op.exitCode, 0 );

    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After );

    return null;
  })

  a.appStart( '.undo d:1' )
  a.appStart( '.undo d:1' )
  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.undo .undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.undo d:1' )
  .then( ( op ) =>
  {
    test.description = '.undo d:1';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to undo.
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  /* */

  return a.ready;
}

//

function replaceRedoChangeUndo( test )
{
  let context = this;
  let a = test.assetFor( 'basic' );

  a.reflect();

  let file1Before = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
  let file2Before = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
  let file1After = a.fileProvider.fileRead( a.abs( 'after/File1.txt' ) );
  let file2After = a.fileProvider.fileRead( a.abs( 'after/File2.txt' ) );

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'outdated File1.txt';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  a.appStart( '.redo d:0 v:3' )
  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );

    a.fileProvider.fileWrite( a.abs( 'before/File1.txt' ), file1After + 'xyz' );

    return null;
  })

  a.appStartNonThrowing( '.undo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.undo';
    test.notIdentical( op.exitCode, 0 );

    var exp =
`
 + undo replace 5 in ${ a.abs( 'before/File2.txt' ) }
 ! failed to undo action::replace 3 in ${ a.abs( 'before/File1.txt' ) }
    Files are outdated:
      ${ a.abs( 'before/File1.txt' ) }
Undone 1 action(s). Thrown 1 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After + 'xyz' );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 1
undo : 1 -- 1 error(s)
`
    test.equivalent( op.output, exp );

    return null;
  })

  a.appStartNonThrowing( '.undo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.undo';
    test.notIdentical( op.exitCode, 0 );

    var exp =
`
 ! failed to undo action::replace 3 in ${ a.abs( 'before/File1.txt' ) }
    Files are outdated:
      ${ a.abs( 'before/File1.txt' ) }
Undone 0 action(s). Thrown 1 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After + 'xyz' );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 1
undo : 1 -- 1 error(s)
`
    test.equivalent( op.output, exp );

    a.fileProvider.fileWrite( a.abs( 'before/File1.txt' ), file1After );

    return null;
  })

  a.appStartNonThrowing( '.undo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
+ undo replace 3 in ${a.abs( 'before/File1.txt' )}
Undone 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'outdated File2.txt';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  a.appStart( '.redo d:0 v:3' )
  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );

    a.fileProvider.fileWrite( a.abs( 'before/File2.txt' ), file2After + 'xyz' );

    return null;
  })

  a.appStartNonThrowing( '.undo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.undo';
    test.notIdentical( op.exitCode, 0 );

    var exp =
`
 ! failed to undo action::replace 5 in ${ a.abs( 'before/File2.txt' ) }
    Files are outdated:
      ${ a.abs( 'before/File2.txt' ) }
 + undo replace 3 in ${ a.abs( 'before/File1.txt' ) }
Undone 1 action(s). Thrown 1 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After + 'xyz' );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 1
undo : 1 -- 1 error(s)
`
    test.equivalent( op.output, exp );

    return null;
  })

  a.appStartNonThrowing( '.undo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.undo';
    test.notIdentical( op.exitCode, 0 );

    var exp =
`
 ! failed to undo action::replace 5 in ${ a.abs( 'before/File2.txt' ) }
    Files are outdated:
      ${ a.abs( 'before/File2.txt' ) }
Undone 0 action(s). Thrown 1 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After + 'xyz' );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 1
undo : 1 -- 1 error(s)
`
    test.equivalent( op.output, exp );

    a.fileProvider.fileWrite( a.abs( 'before/File2.txt' ), file2After );

    return null;
  })

  a.appStartNonThrowing( '.undo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
+ undo replace 5 in ${a.abs( 'before/File2.txt' )}
Undone 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'outdated File2.txt';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  a.appStart( '.redo d:0 v:3' )
  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2
`
    test.equivalent( op.output, exp );

    a.fileProvider.fileWrite( a.abs( 'before/File1.txt' ), file1After + 'xyz' );
    a.fileProvider.fileWrite( a.abs( 'before/File2.txt' ), file2After + 'xyz' );

    return null;
  })

  a.appStartNonThrowing( '.undo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.undo';
    test.notIdentical( op.exitCode, 0 );

    var exp =
`
 ! failed to undo action::replace 5 in ${ a.abs( './before/File2.txt' ) }
    Files are outdated:
      ${ a.abs( './before/File2.txt' ) }
 ! failed to undo action::replace 3 in ${ a.abs( './before/File1.txt' ) }
    Files are outdated:
      ${ a.abs( './before/File1.txt' ) }
Undone 0 action(s). Thrown 2 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After + 'xyz' );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After + 'xyz' );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2 -- 2 error(s)
`
    test.equivalent( op.output, exp );

    return null;
  })

  a.appStartNonThrowing( '.undo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.undo';
    test.notIdentical( op.exitCode, 0 );

    var exp =
`
 ! failed to undo action::replace 5 in ${ a.abs( './before/File2.txt' ) }
    Files are outdated:
      ${ a.abs( './before/File2.txt' ) }
 ! failed to undo action::replace 3 in ${ a.abs( './before/File1.txt' ) }
    Files are outdated:
      ${ a.abs( './before/File1.txt' ) }
Undone 0 action(s). Thrown 2 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After + 'xyz' );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2After + 'xyz' );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 0
undo : 2 -- 2 error(s)
`
    test.equivalent( op.output, exp );

    a.fileProvider.fileWrite( a.abs( 'before/File1.txt' ), file1After );
    a.fileProvider.fileWrite( a.abs( 'before/File2.txt' ), file2After );

    return null;
  })

  a.appStartNonThrowing( '.undo d:0 v:3' )
  .then( ( op ) =>
  {
    test.description = '.undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
+ undo replace 5 in ${ a.abs( './before/File2.txt' ) }
+ undo replace 3 in ${ a.abs( './before/File1.txt' ) }
Undone 2 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var exp = [ '.', './after', './after/File1.txt', './after/File2.txt', './before', './before/File1.txt', './before/File2.txt' ];
    var files = a.findAll( a.abs( '.' ) );
    test.identical( files, exp );
    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.status v:1' )
  .then( ( op ) =>
  {
    test.description = '.status';
    test.identical( op.exitCode, 0 );
    var exp =
`
redo : 2
undo : 0
`
    test.equivalent( op.output, exp );

    return null;
  })

  /* - */

  return a.ready;
}

//

function replaceRedoUndoOptionVerbosity( test )
{
  let context = this;
  let a = test.assetFor( 'basic' );

  a.reflect();

  let file1Before = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
  let file2Before = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
  let file1After = a.fileProvider.fileRead( a.abs( 'after/File1.txt' ) );
  let file2After = a.fileProvider.fileRead( a.abs( 'after/File2.txt' ) );

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'verbosity : default';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  a.appStart( '.undo d:1' )
  .then( ( op ) =>
  {
    test.description = '.undo d:1';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to undo.
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.redo d:1' )
  a.appStart( '.undo d:1' )
  .then( ( op ) =>
  {
    test.description = '.redo d:1 .undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
+ undo replace 3 in ${ a.abs( 'before/File1.txt' ) }
Undone 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.redo d:1' )
  a.appStart( '.redo d:1' )
  a.appStart( '.undo d:1' )
  .then( ( op ) =>
  {
    test.description = '.redo d:1 .redo .undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
+ undo replace 5 in ${ a.abs( 'before/File2.txt' ) }
Undone 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.undo d:1' )
  .then( ( op ) =>
  {
    test.description = '.undo d:1';
    test.identical( op.exitCode, 0 );

    var exp =
`
+ undo replace 3 in ${ a.abs( 'before/File1.txt' ) }
Undone 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.undo d:1' )
  .then( ( op ) =>
  {
    test.description = '.undo d:1';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to undo.
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.redo d:1' )
  a.appStart( '.redo d:1' )
  a.appStart( '.redo d:1' )
  a.appStart( '.undo d:1' )
  a.appStart( '.undo d:1' )
  a.appStart( '.undo d:1' )
  .then( ( op ) =>
  {
    test.description = '.redo d:1 .redo .redo .undo .undo .undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to undo.
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'v:3';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  a.appStart( '.undo d:1 v:3' )
  .then( ( op ) =>
  {
    test.description = '.undo d:1';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to undo.
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.redo d:1 v:3' )
  a.appStart( '.undo d:1 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo d:1 .undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
+ undo replace 3 in ${ a.abs( 'before/File1.txt' ) }
Undone 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.redo d:1 v:3' )
  a.appStart( '.redo d:1 v:3' )
  a.appStart( '.undo d:1 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo d:1 .redo .undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
+ undo replace 5 in ${ a.abs( 'before/File2.txt' ) }
Undone 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.undo d:1 v:3' )
  .then( ( op ) =>
  {
    test.description = '.undo d:1';
    test.identical( op.exitCode, 0 );

    var exp =
`
+ undo replace 3 in ${ a.abs( 'before/File1.txt' ) }
Undone 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.undo d:1 v:3' )
  .then( ( op ) =>
  {
    test.description = '.undo d:1';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to undo.
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.redo d:1 v:3' )
  a.appStart( '.redo d:1 v:3' )
  a.appStart( '.redo d:1 v:3' )
  a.appStart( '.undo d:1 v:3' )
  a.appStart( '.undo d:1 v:3' )
  a.appStart( '.undo d:1 v:3' )
  .then( ( op ) =>
  {
    test.description = '.redo d:1 .redo .redo .undo .undo .undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to undo.
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'v:2';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  a.appStart( '.undo d:1 v:2' )
  .then( ( op ) =>
  {
    test.description = '.undo d:1';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to undo.
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.redo d:1 v:2' )
  a.appStart( '.undo d:1 v:2' )
  .then( ( op ) =>
  {
    test.description = '.redo d:1 .undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
+ undo replace 3 in ${ a.abs( 'before/File1.txt' ) }
Undone 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.redo d:1 v:2' )
  a.appStart( '.redo d:1 v:2' )
  a.appStart( '.undo d:1 v:2' )
  .then( ( op ) =>
  {
    test.description = '.redo d:1 .redo .undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
+ undo replace 5 in ${ a.abs( 'before/File2.txt' ) }
Undone 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.undo d:1 v:2' )
  .then( ( op ) =>
  {
    test.description = '.undo d:1';
    test.identical( op.exitCode, 0 );

    var exp =
`
+ undo replace 3 in ${ a.abs( 'before/File1.txt' ) }
Undone 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.undo d:1 v:2' )
  .then( ( op ) =>
  {
    test.description = '.undo d:1';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to undo.
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.redo d:1 v:2' )
  a.appStart( '.redo d:1 v:2' )
  a.appStart( '.redo d:1 v:2' )
  a.appStart( '.undo d:1 v:2' )
  a.appStart( '.undo d:1 v:2' )
  a.appStart( '.undo d:1 v:2' )
  .then( ( op ) =>
  {
    test.description = '.redo d:1 .redo .redo .undo .undo .undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to undo.
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'v:1';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  a.appStart( '.undo d:1 v:1' )
  .then( ( op ) =>
  {
    test.description = '.undo d:1';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to undo.
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.redo d:1 v:1' )
  a.appStart( '.undo d:1 v:1' )
  .then( ( op ) =>
  {
    test.description = '.redo d:1 .undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
Undone 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.redo d:1 v:1' )
  a.appStart( '.redo d:1 v:1' )
  a.appStart( '.undo d:1 v:1' )
  .then( ( op ) =>
  {
    test.description = '.redo d:1 .redo .undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
Undone 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.undo d:1 v:1' )
  .then( ( op ) =>
  {
    test.description = '.undo d:1';
    test.identical( op.exitCode, 0 );

    var exp =
`
Undone 1 action(s). Thrown 0 error(s).
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.undo d:1 v:1' )
  .then( ( op ) =>
  {
    test.description = '.undo d:1';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to undo.
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.redo d:1 v:1' )
  a.appStart( '.redo d:1 v:1' )
  a.appStart( '.redo d:1 v:1' )
  a.appStart( '.undo d:1 v:1' )
  a.appStart( '.undo d:1 v:1' )
  a.appStart( '.undo d:1 v:1' )
  .then( ( op ) =>
  {
    test.description = '.redo d:1 .redo .redo .undo .undo .undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
Nothing to undo.
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  /* - */

  a.ready.then( ( op ) =>
  {
    test.case = 'v:0';
    a.reflect();
    return null;
  })

  a.appStart( '.storage.reset' )
  a.appStart( '.replace filePath:before/** ins:line sub:abc' )
  a.appStart( '.undo d:1 v:0' )
  .then( ( op ) =>
  {
    test.description = '.undo d:1';
    test.identical( op.exitCode, 0 );

    var exp =
`
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.redo d:1 v:0' )
  a.appStart( '.undo d:1 v:0' )
  .then( ( op ) =>
  {
    test.description = '.redo d:1 .undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.redo d:1 v:0' )
  a.appStart( '.redo d:1 v:0' )
  a.appStart( '.undo d:1 v:0' )
  .then( ( op ) =>
  {
    test.description = '.redo d:1 .redo .undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1After );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.undo d:1 v:0' )
  .then( ( op ) =>
  {
    test.description = '.undo d:1';
    test.identical( op.exitCode, 0 );

    var exp =
`
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.undo d:1 v:0' )
  .then( ( op ) =>
  {
    test.description = '.undo d:1';
    test.identical( op.exitCode, 0 );

    var exp =
`
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  a.appStart( '.redo d:1 v:0' )
  a.appStart( '.redo d:1 v:0' )
  a.appStart( '.redo d:1 v:0' )
  a.appStart( '.undo d:1 v:0' )
  a.appStart( '.undo d:1 v:0' )
  a.appStart( '.undo d:1 v:0' )
  .then( ( op ) =>
  {
    test.description = '.redo d:1 .redo .redo .undo .undo .undo';
    test.identical( op.exitCode, 0 );

    var exp =
`
`
    test.equivalent( op.output, exp );

    var got = a.fileProvider.fileRead( a.abs( 'before/File1.txt' ) );
    test.identical( got, file1Before );
    var got = a.fileProvider.fileRead( a.abs( 'before/File2.txt' ) );
    test.identical( got, file2Before );

    return null;
  })

  /* - */

  return a.ready;
}

//

function hlinkBasic( test )
{
  let context = this;
  let a = test.assetFor( 'hlink' );

  /* - */

  a.ready
  .then( ( op ) =>
  {
    test.case = 'basic';
    a.reflect();

    test.is( !a.fileProvider.areHardLinked( a.abs( 'F1.txt' ), a.abs( 'F2.txt' ) ) );
    test.is( !a.fileProvider.areHardLinked( a.abs( 'F1.txt' ), a.abs( 'dir/F3.txt' ) ) );
    test.is( !a.fileProvider.areHardLinked( a.abs( 'F2.txt' ), a.abs( 'dir/F3.txt' ) ) );

    return null;
  })

  a.appStart( '.hlink' )
  .then( ( op ) =>
  {
    test.description = '.hlink';
    test.identical( op.exitCode, 0 );

    var exp =
`
 + hardLink : ${ a.abs( '.' ) }/ : ./dir/F3.txt <- ./F1.txt
Linked files at ${ a.abs( '.' ) }
`
    test.equivalent( op.output, exp );

    test.is( !a.fileProvider.areHardLinked( a.abs( 'F1.txt' ), a.abs( 'F2.txt' ) ) );
    test.is( a.fileProvider.areHardLinked( a.abs( 'F1.txt' ), a.abs( 'dir/F3.txt' ) ) );
    test.is( !a.fileProvider.areHardLinked( a.abs( 'F2.txt' ), a.abs( 'dir/F3.txt' ) ) );

    return null;
  })

  /* - */

  return a.ready;
}

//

function hlinkOptionBasePath( test )
{
  let context = this;
  let a = test.assetFor( 'hlinkAdvanced' );

  /* - */

//   a.ready
//   .then( ( op ) =>
//   {
//     test.case = 'basic';
//     a.reflect();
//
//     test.equivalent( a.fileProvider.statRead( a.abs( 'F.txt' ) ).nlink, 1 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'F.txt2' ) ).nlink, 1 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir1/F.txt' ) ).nlink, 1 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir1/F.txt2' ) ).nlink, 1 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir2/F.txt' ) ).nlink, 1 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir2/F.txt2' ) ).nlink, 1 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir3/F.txt' ) ).nlink, 1 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir3/F.txt2' ) ).nlink, 1 );
//
//     var exp =
//     [
//       '.',
//       './F.txt',
//       './F.txt2',
//       './dir1',
//       './dir1/F.txt',
//       './dir1/F.txt2',
//       './dir2',
//       './dir2/F.txt',
//       './dir2/F.txt2',
//       './dir3',
//       './dir3/F.txt',
//       './dir3/F.txt2'
//     ]
//     var files = a.findAll( a.abs( '.' ) );
//     test.identical( files, exp );
//
//     return null;
//   })
//
//   a.appStart( '.hlink' )
//   .then( ( op ) =>
//   {
//     test.description = '.hlink';
//     test.identical( op.exitCode, 0 );
//
//     var exp =
// `
// + hardLink : ${ a.abs( '.' ) }/ : ./F.txt2 <- ./F.txt
// + hardLink : ${ a.abs( '.' ) }/ : ./dir1/F.txt <- ./F.txt
// + hardLink : ${ a.abs( '.' ) }/ : ./dir1/F.txt2 <- ./F.txt
// + hardLink : ${ a.abs( '.' ) }/ : ./dir2/F.txt <- ./F.txt
// + hardLink : ${ a.abs( '.' ) }/ : ./dir2/F.txt2 <- ./F.txt
// + hardLink : ${ a.abs( '.' ) }/ : ./dir3/F.txt <- ./F.txt
// + hardLink : ${ a.abs( '.' ) }/ : ./dir3/F.txt2 <- ./F.txt
// Linked files at ${ a.abs( '.' ) }
// `
//     test.equivalent( op.output, exp );
//
//     test.identical( a.fileProvider.areHardLinked( a.abs( 'F.txt' ), a.abs( 'F.txt2' ) ), true );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'F.txt' ) ).nlink, 8 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'F.txt2' ) ).nlink, 8 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir1/F.txt' ) ).nlink, 8 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir1/F.txt2' ) ).nlink, 8 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir2/F.txt' ) ).nlink, 8 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir2/F.txt2' ) ).nlink, 8 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir3/F.txt' ) ).nlink, 8 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir3/F.txt2' ) ).nlink, 8 );
//
//     return null;
//   })
//
//   /* - */
//
//   a.ready
//   .then( ( op ) =>
//   {
//     test.case = 'basePath:dir1';
//     a.reflect();
//     return null;
//   })
//
//   a.appStart( '.hlink basePath:dir1' )
//   .then( ( op ) =>
//   {
//     test.description = '.hlink';
//     test.identical( op.exitCode, 0 );
//
//     var exp =
// `
// + hardLink : ${ a.abs( 'dir1/' ) } : ./F.txt2 <- ./F.txt
// Linked files at ${ a.abs( 'dir1' ) }
// `
//     test.equivalent( op.output, exp );
//
//     test.identical( a.fileProvider.areHardLinked( a.abs( 'dir1/F.txt' ), a.abs( 'dir1/F.txt2' ) ), true );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'F.txt' ) ).nlink, 1 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'F.txt2' ) ).nlink, 1 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir1/F.txt' ) ).nlink, 2 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir1/F.txt2' ) ).nlink, 2 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir2/F.txt' ) ).nlink, 1 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir2/F.txt2' ) ).nlink, 1 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir3/F.txt' ) ).nlink, 1 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir3/F.txt2' ) ).nlink, 1 );
//
//     return null;
//   })

  /* - */

  a.ready
  .then( ( op ) =>
  {
    test.case = `basePath:'dir1/**'`;
    a.reflect();
    return null;
  })

  a.appStart( `.hlink basePath:'dir1/**'` )
  .then( ( op ) =>
  {
    test.description = '.hlink';
    test.identical( op.exitCode, 0 );

    var exp =
`
+ hardLink : ${ a.abs( 'dir1/' ) } : ./F.txt2 <- ./F.txt
Linked files at ${ a.abs( 'dir1' ) }
`
    test.equivalent( op.output, exp );

    test.identical( a.fileProvider.areHardLinked( a.abs( 'dir1/F.txt' ), a.abs( 'dir1/F.txt2' ) ), true );
    test.equivalent( a.fileProvider.statRead( a.abs( 'F.txt' ) ).nlink, 1 );
    test.equivalent( a.fileProvider.statRead( a.abs( 'F.txt2' ) ).nlink, 1 );
    test.equivalent( a.fileProvider.statRead( a.abs( 'dir1/F.txt' ) ).nlink, 2 );
    test.equivalent( a.fileProvider.statRead( a.abs( 'dir1/F.txt2' ) ).nlink, 2 );
    test.equivalent( a.fileProvider.statRead( a.abs( 'dir2/F.txt' ) ).nlink, 1 );
    test.equivalent( a.fileProvider.statRead( a.abs( 'dir2/F.txt2' ) ).nlink, 1 );
    test.equivalent( a.fileProvider.statRead( a.abs( 'dir3/F.txt' ) ).nlink, 1 );
    test.equivalent( a.fileProvider.statRead( a.abs( 'dir3/F.txt2' ) ).nlink, 1 );

    return null;
  })

  /* - */

//   a.ready
//   .then( ( op ) =>
//   {
//     test.case = 'basePath:dir1 basePath:dir3';
//     a.reflect();
//     return null;
//   })
//
//   a.appStart( '.hlink basePath:dir1 basePath:dir3' )
//   .then( ( op ) =>
//   {
//     test.description = '.hlink';
//     test.identical( op.exitCode, 0 );
//
//     var exp =
// `
//  + hardLink : ${ a.abs( '.' ) }/dir1/ : ./F.txt2 <- ./F.txt
//  + hardLink : ${ a.abs( '.' ) }/ : ./dir3/F.txt <- ./dir1/F.txt
//  + hardLink : ${ a.abs( '.' ) }/ : ./dir3/F.txt2 <- ./dir1/F.txt
// Linked files at ( ${ a.abs( '.' ) }/ + [ ./dir1 , ./dir3 ] )
// `
//     test.equivalent( op.output, exp );
//
//     test.identical( a.fileProvider.areHardLinked( a.abs( 'dir1/F.txt' ), a.abs( 'dir1/F.txt2' ) ), true );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'F.txt' ) ).nlink, 1 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'F.txt2' ) ).nlink, 1 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir1/F.txt' ) ).nlink, 4 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir1/F.txt2' ) ).nlink, 4 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir2/F.txt' ) ).nlink, 1 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir2/F.txt2' ) ).nlink, 1 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir3/F.txt' ) ).nlink, 4 );
//     test.equivalent( a.fileProvider.statRead( a.abs( 'dir3/F.txt2' ) ).nlink, 4 );
//
//     return null;
//   })

  /* - */

  return a.ready;
}

// --
// declare
// --

var Self =
{

  name : 'Tools.atop.Filer.Ext',
  silencing : 1,

  onSuiteBegin,
  onSuiteEnd,
  routineTimeOut : 300000,

  context :
  {
    suiteTempPath : null,
    assetsOriginalPath : null,
    appJsPath : null,
  },

  tests :
  {

    replaceBasic,
    replaceStatusOptionVerbosity,
    replaceRedoOptionVerbosity,
    replaceRedoOptionDepth,
    replaceChangeRedo,
    replaceRedoDepth0OptionVerbosity,
    replaceRedoHardLinked,
    replaceRedoSoftLinked,
    // replaceRedoTextLinked, /* qqq : implement. look replaceRedoSoftLinked */

    replaceRedoUndo,
    replaceRedoChangeUndo,
    replaceRedoUndoOptionVerbosity,
    // replaceRedoUndoOptionDepth, /* qqq : implement. look replaceRedoOptionDepth */

    // /* qqq : implement test to check locking */

    hlinkBasic,
    hlinkOptionBasePath,

  }

}

//

Self = wTestSuite( Self );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();
