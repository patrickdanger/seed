###
	//
	//	seed
	//
###

require './env'


class Node
	constructor: (@id, @parent, @children = {}) ->

class SeedNode extends Node
	getChild: (id) -> @children[id] = @children[id] or new SeedNode id, @
	
	
#
#	Services
#

# base service class
class Service
	serve: (stream) -> 
	
# 
class APIService
	@.implements Service
	constructor: (@type = 'API') ->

class FileService
	@.implements Service
	constructor: (@type = 'file') ->

class CompilingService extends FileService


class exports.Seed 
	constructor: (@root) ->
	request: (req, resp) -> console.log "request received: #{req}"