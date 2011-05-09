###
	//
	//	seed web server platform
	//	seed.lib.seed
	//
###

events 	= require 'events'
path 	= require 'path'
url		= require 'url'

class EventEmitter extends events.EventEmitter
	constructor:					-> super
	receive:	   (event, args...) -> @delegate.apply @, arguments
	delegate:	   (event, args...) -> @emit.apply @, arguments


class Server extends EventEmitter
	constructor:					-> super
	delegateRequest: 	(req, resp) -> @
	emitRequest:		(req, resp) -> @receive 'request', req, resp
	receiveRequest:		(req, resp) ->
		
		delegate = @delegateRequest req, resp
		return unless delegate
		
		if delegate is @ then delegate.emitRequest req, resp
		else
			if delegate instanceof exports.Server 	then delegate.receiveRequest req, resp
			else if typeof delegate is 'function' 	then delegate req, resp
			else 									console.log "can't delegate request to specified object: #{JSON.stringify delegate}"
			
class HierarchicalServer extends Server
	constructor:  ( @fullName
				  , @name
				  , @parent
				  , @children = {}) -> super
	constructChild: 		 (name) -> new HierarchicalServer @fullName + name, name, @
	getChild:				 (name) -> @children[name] = @constructChild name unless name in @children;	@children[name]
	getChildName:			  (req) -> null
	
class DelegatingServer extends HierarchicalServer
	constructor:		  (args...) -> super args...
	delegateRequest:	(req, resp) -> if @getChildName(req) and @getChild(name) then @getChild name else @
	
	
class HttpServer extends DelegatingServer
	constructor:		  (args...) -> super args...; @addListener 'request', (req, resp) -> @serveRequest req, resp
	serveRequest:					->
	sendNone:			(req, resp) -> resp.writeHead 404, server: 'seed'; resp.end()
	sendCached:		 (req, resp, h) -> resp.writeHead 304, h; resp.end()
	sendAuthorize:		(req, resp) -> throw new Error "sendAuthorize is Not Implemented."
	sendForbidden:		(req, resp) -> resp.writeHead 403, server: 'seed'; resp.end()
	sendClientError: (req, resp, e) -> resp.writeHead 400; resp.end()
	sendServerError: (req, resp, e) -> resp.writeHead 500; resp.end()
	
class exports.FileServer extends HttpServer
	constructor:		( fullName
						 , name
						 , parent ) -> 
		super fullName, name, parent
		@fileCache			= {}
		@mimeTypes 			= Object.create exports.FileServer.MimeTypes
		@directoryIndices 	= ['index.html', 'home.html', 'index.js'] 
		
	constructChild:			 (name) -> new exports.FileServer path.join(@fullName, name), name, @
	getNextPathElement: (req, resp) -> 
	translateUrl:		(req, resp) -> path.join @fullName, url.parse(req.url).pathname
	getFile:				 (path) -> @fileCache[path] = new exports.File path unless @fileCache[path]; @fileCache[path]
	
	locate:				(req, resp) ->
		filename = @translateUrl req, resp
		console.log "translating to filename #{filename}"
		
		if filename.indexOf(@fullName) is not 0
			console.log "that file is outside of this file server"
			return @sendFile req, resp
			
		file = @getFile filename
		file.stat (error, stat) =>
			if error																		# file doesn't exist
				console.log "requested file (#{filename}) doesn't exist"
				return @sendFile req, resp
			else if not stat.isDirectory()													# file is regular file
				console.log "serving #{filename}"
				return @sendFile req, resp
			else if stat.isDirectory()														# file is a directory
				console.log "requested file (#{filename}) is a directory"
	
	sendFile: 	  (req, resp, file) ->
		return @sendNone req, resp unless file
		console.log "sending file #{file.name}"
		
		file.stat (statErr) =>
			return @sendNone if statErr
			ext = path.extname file.path
			if ext and ext.indexOf('.') is 0 then ext = ext.slice 1
			
			headers = 
				'content-type':			@mimeTypes[ext] or 'text/plain'
				'last-modified':		new(Date)(file.header.mtime).toUTCString
				'transfer-encoding':	'chunked'
				'server':				'seed'
	
			if Date.parse(file.header.mtime) <= Date.parse(req.headers['if-modified-since']) then @sendCached req, resp, headers
			else
				resp.writeHead 200, headers
				if req.method is 'HEAD' then resp.end()
				else file.readFile (err, data) ->
					console.log err if err
					resp.write data
					resp.end()
				
		
exports.FileServer.MimeTypes =
	"": 	"text/plain"
	html: 	"text/html"
	css: 	"text/css"
	js: 	"text/javascript"
	
	
