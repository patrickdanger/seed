

require './env'
path = require 'path'


class Node
	
	constructor: (@id, @parent = null, @children = {}) ->
	
	
class SeedNode
	
	getChild: (key, constructor = @.constructor, childArgs...)  ->
		return @             unless key
		childArgs      = [@] unless childArgs.length > 0
		@children[key] = @children[key] or new @.constructor key, childArgs...
		

class PathNode
	
	path:           -> path.join @parent?.path(), @id
	nextKey: (path) ->
		tokens = path.replace( @path(), '' ).split "/"
		return tokens[1] if tokens[0] is ''
		return tokens[0]


class RouteNode 
	
	route:            -> new RegExp @route
	rebase:    (path) -> @path
	nextRoute: (path) -> @route
		
		
class Server extends Node
	
	@.implements SeedNode, PathNode, RouteNode
	
	constructor: (id, @route, nodeArgs...) -> super id, nodeArgs...
	getChild:    (key, route)              -> super key, null, route or @nextRoute @path()
		

 