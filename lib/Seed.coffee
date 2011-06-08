
sys             = require 'sys'
sys.path        = require 'path'
sys.url         = require 'url'

require           './env'
ServiceRegistry = require './ServiceRegistry'


#//
#	Service
#
#	basic service object, designed to automatically reimplement itself
#	when the serve method is called.  because the match variable won't
#	ever match a type, we don't have to worry about cyclic calls.
#//
class Service

	name:  "stub"
	match: "$^"

	ServiceRegistry.register @

	serve: (context, stream) -> ServiceRegistry.reimplement @, @id; @serve context, stream


#//
#	GenericService
#	
#	basic service designed to capture requests not matched by any other
#	registered service types.
#//
class GenericService

	name:  "generic"
	match: ".*"

	ServiceRegistry.register @

	serve: (context, stream) -> stream.write "I am a #{@name} service for #{@id}.\n"

#//
#	DirectoryService
#
#	output directory information (currently unimplemented), but
#	could be useful for stats collection or for overriding in a
#	custom implementation.
#//
class DirectoryService

	name:  "directory"
	match: "^[^\.]"

	ServiceRegistry.register @


class FileService
	
	name: "file"
	match: "\.(html|css|js)$"

	ServiceRegistry.register @
	
	serve: (context, stream) -> stream.write "I am a #{@name} service for #{@id}.\n"

#//
#	Node
#
#	basic tree node class, supports parent and children
#	references as well as a debugging method for outputting
#	the entire node tree to the console.
#//
class Node

	#/
	#	CONSTRUCTOR
	#	
	#	create a new Node object containing an @id and, optionally,
	#	a reference to @parent and @children.
	#/
	constructor: (@id, @parent = null, @children = {}) ->

	#/
	#	toString
	#
	#	debugging method, will output the node tree begging at the
	#	current Node.  supports outputting any property of the 
	#	node(s)
	#/
	toString:               (prop = "id", indent = "") ->
		if @[prop]
			console.log "#{indent}#{@[prop]}"
			@.children[id].toString prop, "#{indent}  " for id of @.children


#//
#	SeedNode
#	extends Node
#
#	a self-assembling tree object which supports creating requested
#	child objects if none matching requested key exist.
#//
class SeedNode extends Node

	#/ 
	#	getChild
	#
	#	return child in @children matching requested key, or, 
	#	if no such child exists, create one and return it.  supports
	#	passing a custom object constructor and arguments for 
	#	creating child objects.
	#/
	getChild: (key, ctor = @.constructor, childArgs...)  ->
		return @             unless key
		childArgs      = [@] unless childArgs.length > 0
		@children[key] = @children[key] or new ctor key, childArgs...


#//
#	PathNode										// IMPLEMENTABLE
#
#	methods and properties supporting Node objects that represent
#	path fragments.
#//
class PathNode

	#/
	#	path
	#
	#	return full path from Node tree root to this fragment.
	#/
	path:                -> sys.path.join @parent?.path(), @id

	#/
	#	matchPath
	#
	#	return true if provided path is equal to the full path
	#	from the Node tree root to this fragment.
	#/
	matchPath:    (path) -> path is @path()

	#/
	#	tokenizePath
	#
	#	break the provided path into an array of tokens (each token
	#	should correspond to a path fragment).
	#/
	tokenizePath: (path) -> path.split "/"

	#/
	#	nextPathKey
	#
	#	return the key for the path fragment immediately following
	#	this object path fragment.
	#/
	nextPathKey:  (path) ->
		tokens = @tokenizePath path.replace( @path(), '' )
		return tokens[1] if tokens[0] is ''
		return tokens[0]


#//
#	RouteNode										// IMPLEMENTABLE
#
#	methods and properties supporting Node objects that accomodate
#	routing.
#//
class RouteNode 

	#/
	#	route
	#
	#	return full route from Node tree root to this fragment.
	#/
	route:               -> (@parent?.route() or "") + (@routeKey or "[^/]*/?")

	#/
	#	re
	#	
	#	return a regular expression object representing the full
	#	route from Node tree root to this fragment.
	#/
	re:                  -> new RegExp @route()

	#/
	#	rebase (relies on PathNode.path)
	#	
	#	re-orient the provided path to the path represented by this
	#	Node by replacing the segment matching this Node route with
	#	this Node path (requires PathNode.path).
	#/
	rebase:       (path) -> sys.path.join @path(), (path.replace @re(), '')

	#/
	#	matchRoute
	#
	#	test the provided path against the full route represented at
	#	this node.
	#/
	matchRoute:   (path) -> @re().test path

	#/
	#	nextRouteKey (relies on PathNode.tokenize)
	#
	#	return the route key for the fragment immediately following
	#	this object route fragment.  Requires PathNode.tokenize.
	#/
	nextRouteKey: (path) -> 
		tokens = @tokenizePath path.replace( @path(), '' )
		return tokens[1] if tokens[0] is ''
		return tokens[0]


#//
#	ServerNode
#	extends SeedNode
#	
#	Node object that supports routing and path node behaviors.
#//
class ServerNode extends SeedNode

	@.implements PathNode, RouteNode

	#/
	#	CONSTRUCTOR
	#
	#	create a ServerNode optionally supporting id as document root
	#	and routeKey as a route.
	#/
	constructor: (id, @routeKey, nodeArgs...)               -> super id or process.cwd(), nodeArgs...

	#/
	#	getChild (overloaded from parent)
	#
	#	version of the getChild method that supports routes in children,
	#	calls parent object version of same method (overloaded from parent).
	#/
	getChild:    (key, routeKey = "")                       -> super key, @constructor, routeKey, @


#//
#	Seed
#	extends ServerNode
#
#	the Seed object is the basic building block of the Seed package.
#	a self-assembling server, Seed supports posting requests and 
#	responses.
#//
class exports.Seed extends ServerNode

	@.implements Service

	#/
	#	request
	#	
	#	the request method drives the self-assembly behavior by delagating
	#	requests through the requested path until keys are exhausted and
	#	then serving the request at the leaf.
	#/
	request:  (req, resp) ->
		{pathname}       = sys.url.parse req.url
		return             unless @matchRoute pathname

		delegate         = @getChild @nextPathKey @rebase pathname
		if delegate is @   then @serve req, resp 
		else               delegate.request req, resp
