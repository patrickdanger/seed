

require './env'
sys      = require 'sys'
sys.path = require 'path'


class Node

	constructor: (@id, @parent = null, @children = {}) ->
	toString:               (prop = "id", indent = "") ->
		if @[prop]
			console.log "#{indent}#{@[prop]}"
			@.children[id].toString prop, "#{indent}  " for id of @.children

class SeedNode extends Node

	getChild: (key, ctor = @.constructor, childArgs...)  ->
		return @             unless key
		childArgs      = [@] unless childArgs.length > 0
		@children[key] = @children[key] or new ctor key, childArgs...


class PathNode

	path:                -> sys.path.join @parent?.path(), @id
	matchPath:    (path) -> path is @path
	tokenizePath: (path) -> path.split "/"
	nextPathKey:  (path) ->
		tokens = @tokenizePath path.replace( @path(), '' )
		return tokens[1] if tokens[0] is ''
		return tokens[0]

class RouteNode 

	route:               -> (@parent?.route() or "") + (@routeKey or "[^/]*/?")
	re:                  -> new RegExp @route()
	rebase:       (path) -> sys.path.join @path(), (path.replace @re(), '')
	matchRoute:   (path) -> @re().test path
	nextRouteKey: (path) -> 
		tokens = @tokenizePath path.replace( @path(), '' )
		return tokens[1] if tokens[0] is ''
		return tokens[0]


class ServerNode extends SeedNode

	@.implements PathNode, RouteNode

	constructor: (id, @routeKey, nodeArgs...)               -> super id, nodeArgs...
	getChild:    (key, routeKey = "")                       -> super key, @constructor, routeKey, @



class Service
	



###

	debugging 

###

dev    = new ServerNode  "/webroot/dev/", "^/development/"
static = dev.getChild    "static"
css    = static.getChild "css"
file   = css.getChild    "standard.css"

dev.toString()