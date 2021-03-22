//===============================================================================
// GPI - Gunther Pippèrr
// DOAG Konferenz Nürnberg November 2016
// Vortrag Gunther Pippèrr - SQLcl
// see also https://github.com/oracle/oracle-db-tools/blob/master/sqlcl/examples/customCommand.js
//===============================================================================


// Refernz to the SQLcl Command Registry Class
var CommandRegistry = Java.type("oracle.dbtools.raptor.newscriptrunner.CommandRegistry");

// CommandListener for creating new any command Listener
var CommandListener =  Java.type("oracle.dbtools.raptor.newscriptrunner.CommandListener")

var ResultSet= Java.type("java.sql.ResultSet")

// Java Script object to hold the new methodes
var extCommand = {};


// fired before ANY command
extCommand.beginEvent = function (conn,ctx,sqlcl) {
	//  Get the actual command 
    if ( sqlcl.getSql().indexOf("ls") > 0 ){
   		ctx.putProperty("gpi.command.ls",true);
	    ctx.write("\n -- Debug sqlcl: " + sqlcl.getSql()+ " read GPI command \n");
		//remember the time
		ctx.putProperty("gpi.startTiming",new Date());
	} 
}

// Called to attempt to handle any command
extCommand.handleEvent = function (conn,ctx,sqlcl) {
    // ls commmand to the database
	sqlcl.setSql("select  t.table_name, t.num_rows, round(s.bytes/1024/1024,3) as size_MB from user_tables t , user_segments s  where t.table_name = s.segment_name(+)  order by t.table_name;");
	// return FALSE to indicate the command was not handled
    return true;
}

// fired after ANY Command
extCommand.endEvent = function (conn,ctx,sqlcl) {
   if ( ctx.getProperty("gpi.showTiming") ) {
	  var end = new Date().getTime();
 	  var start = ctx.getProperty("gpi.startTiming");   
      start = start.getTime();
  	  // print out elapsed time of all commands
      ctx.write("Command elapsed time :: " + (end - start) + " ms \n");
	  //unset 
	  ctx.putProperty("gpi.showTiming",false);
   }
}

// Actual Extend of the Java CommandListener

var ShowTimingCmd = Java.extend(CommandListener, {
		handleEvent: extCommand.handleEvent ,
        beginEvent:  extCommand.beginEvent  , 
        endEvent:    extCommand.endEvent    
});

// Registering the new Command
CommandRegistry.addForAllStmtsListener(ShowTimingCmd.class);

