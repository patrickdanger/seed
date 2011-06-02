

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
	
	route:               -> (@parent?.route() or "") + @routeKey
	match:        (path) -> new RegExp(@route()).test path
	rebase:       (path) -> @path
	nextRouteKey: (path) -> 
		tokens = path.replace( @path(), '' ).split "/"
		return tokens[1] if tokens[0] is ''
		return tokens[0]
		
		
class Server extends SeedNode
	
	@.implements PathNode, RouteNode

	constructor: (id, @routeKey, nodeArgs...)               -> super id, nodeArgs...
	getChild:    (key, routeKey = "")                       -> super key, Server, routeKey, @

