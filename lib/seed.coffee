

require './env'
sys      = require 'sys'
sys.path = require 'path'


class Node
	
	constructor: (@id, @parent = null, @children = {}) ->
	
	
class SeedNode extends Node
	
	getChild: (key, ctor = @.constructor, childArgs...)  ->
		return @             unless key
		childArgs      = [@] unless childArgs.length > 0
		@children[key] = @children[key] or new ctor key, childArgs...
		

class PathNode
	
	path:               -> sys.path.join @parent?.path(), @id
	nextPathKey: (path) ->
		tokens = path.replace( @path(), '' ).split "/"
		return tokens[1] if tokens[0] is ''
		return tokens[0]


class RouteNode 
	
	route:               -> (@parent?.route() or "") + (@routeKey or "[^/]*/?")		#/ return string route
	re:                  -> new RegExp @route()										#/ return RegExp route
	match:        (path) -> @re().test path											#/ test route against path
	rebase:       (path) -> sys.path.join @path(), (path.replace @re(), '')			#/ rebase path to root
	nextRouteKey: (path) -> 
		tokens = path.replace( @path(), '' ).split "/"
		return tokens[1] if tokens[0] is ''
		return tokens[0]
		
		
class Server extends SeedNode
	
	@.implements PathNode, RouteNode

	constructor: (id, @routeKey, nodeArgs...)               -> super id, nodeArgs...
	getChild:    (key, routeKey = "")                       -> super key, Server, routeKey, @




###

	debugging 
	
###

walk = (base, prop = "id", indent = "") ->
	if base[prop]
		console.log "#{indent}#{base[prop]}"
		walk base.children[id], prop, "#{indent}  " for id of base.children


dev 	= new Server "webroot/dev", "^/dev/"
static 	= dev.getChild "static"
css		= static.getChild "css"

console.log css.rebase "/dev/static/css/standard/modules/hello.css"

#walk dev