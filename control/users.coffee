response = require('./response')()
tokenGenerator = require('./token')()

module.exports = (User) =>
	errors =
		USER_NOT_FOUND: 
			error: true
			message: "Not Found"
			code: 401
		NOT_AUTHENTICATED: 
			error: true
			message: "Not Authenticated"
			code: 401

	createUser: (req, res)=>
		email = req.body.email
		password = req.body.password
		
		User.getUser email, (err, user)=>
			return res.json {error: true, message: err.message}, 500 if err?
			return res.json normalize user if user?.password is password
			
			body = req.body
			body.token = tokenGenerator.generateToken()
			user = new User body
			user.save (err) =>
				return res.send {error: true, message: err.message}, 500 if err?
				result = normalize user
				res.json result 

	getUser: (req, res) =>
		user_id = req.params.user_id
		User.getUserById user_id, (err, user) =>
			return res.json {error: true, message: err.message}, 500 if err?
			return response.error errors.USER_NOT_FOUND, res if not user?
			user = user[0]
			res.json normalize user

	deleteUser: (req, res) =>
		user_id = req.params.user_id
		User.deleteUserById user_id, (err, user) =>
			return res.json {error: true, message: err.message}, 500 if err?
			res.json {message: "deleted"}, 200

	authenticateUser: (req, res, next)=>
		if req?.query
			user_id = req.query.user_id
			token = req.query.token
		else if req?.body
			user_id = req.body.user_id
			token = req.body.token

		if not user_id
			user_id = req.params.user_id

		User.getUserById user_id, (err, user) =>
			return res.json {error: true, message: err.message}, 500 if err?
			return response.error errors.USER_NOT_FOUND, res if not user?
			user = user[0]
			return response.error errors.USER_NOT_FOUND, res if not user?
			return response.error errors.NOT_AUTHENTICATED, res if user.token != token
			next user

errors = ()->
	USER_NOT_FOUND: 
		error: true
		message: "Not Found"
		code: 401
	NOT_AUTHENTICATED: 
		error: true
		message: "Not Authenticated"
		code: 401

base = ()-> [
      'user_id'
      'email'
      'token'
  ]

normalize = (user) ->
	result = {}
	fields = base()
	for key in fields
		if user[key]?
        result[key] = user[key]
	for key in fields
		if user[key]?
        result[key] = user[key]
    else if key is 'user_id' and user._id?
        result[key] = user._id
	
  return result