###
	//
	//	seed
	//
###

require './env'
sys			= require 'sys'
sys.url 	= require 'url'
sys.path	= require 'path'


# base classes
class Node
	constructor: (@id, @parent = null, @children = {}) ->	


class SelfAssembling
	nextKey: (fullPath, partial) -> fullPath.replace(partial, '').split('/')[1]
	getChild:              (key) -> 
		return @ unless key 
		@children[key] = @children[key] or new @.constructor "#{@path}/#{key}", new RegExp("#{@route.source}\/#{key}"), @


# services
class GenericService
	service: "Generic"
	serve: (stream) -> stream.write "serving #{@service} request at #{@path}\n"
	
class FileService
	service: "File"
	serve: (stream) -> stream.write "serving #{@service} request at #{@path}\n"


# exports
class exports.Seed extends Node

	@.implements SelfAssembling, GenericService

	constructor: (@path, @route, node...) -> super sys.path.basename(@path), node...
	request:                  (req, resp) ->
		reqPath   = sys.path.normalize(sys.url.parse(req.url).pathname)
		fullPath  = sys.path.normalize(reqPath.replace(@route, @path))

		if reqPath.search(@route) > -1
			delegate = @getChild @nextKey fullPath, @path
			if delegate is @ then @serve resp else delegate.request req, resp	
	

class exports.Server extends exports.Seed
	@.implements FileService