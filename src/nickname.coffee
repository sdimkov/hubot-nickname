# Description:
#   
#
# Commands:
#   

# Configure roles for set/remove other people nicknames
roles = false
if process.env.HUBOT_NICKNAME_ROLES 
  roles = ['admin']
  newRoles = process.env.HUBOT_NICKNAME_ROLES.split ','
  roles.push role for role in newRoles when role not in roles


module.exports = (robot) ->


  verifyUser = (res) ->
    matchedUsers = robot.brain.usersForAny res.match[1]
    if matchedUsers.length > 1
      res.reply 'More than one user matches your description. Be more precise.'
      return false
    if matchedUsers.length < 1
      res.reply "I couldn't find users matching your description."
      return false
    return matchedUsers[0]


  verifyNickname = (res) ->
    lowerNick = res.match[res.match.length-1].toLowerCase()
    for key, user of robot.brain.users
      if user.nickname and user.nickname.toLowerCase() == lowerNick
        res.reply "Nah! #{nick} is already taken by #{user.name}"
        return false
    return res.match[res.match.length-1]


  authorize = (res) ->
    if robot.auth and roles
      if user = res.envelope.user
        for role in roles
          return true if robot.auth.hasRole user, role
        res.reply "Nicknames of other people are not your business!"
        return false
    return true


  robot.respond /my nickname is (.+)/i, (res) ->    
    if nick = verifyNickname res
      res.reply "Okay! I'll call you #{nick} from now on!"
      res.envelope.user.nickname = nick


  robot.respond /(?:give me|tell me|show me|what is)?\s*my nickname\s*.?$/i, (res) ->
    if nick = res.envelope.user.nickname
      res.reply "Your nickname is #{nick}!"
    else 
      res.reply "You don't have one, yet!"


  robot.respond /(?:I (?:don.?t|do not) (?:like|want)|forget) my nickname\s*.?$/i, (res) ->
    if nick = res.envelope.user.nickname
      res.send "Ok #{nick}! That was the last time I call you like that ;)"
    else 
      res.reply "That's fine. You don't have a nickname anyway!"
    delete res.envelope.user.nickname


  robot.respond /(?:the)?\s*nickname of (.+) is (.+)/i, (res) ->
    if authorize res
      if user = verifyUser res
        if nick = verifyNickname res
          user.nickname = nick
          res.reply "Okay! #{user.name} is now known as #{nick}!"


  robot.respond /what is (?:the )?nickname of (.+)/i, (res) ->
    if user = verifyUser res
      if nick = user.nickname
        res.reply "The nickname of #{user.name} is #{nick}!"
      else 
        res.reply "#{user.name} doesn't have one, yet ;)"


  robot.respond /forget (?:the )?nickname of (.+)/i, (res) ->
    if authorize res
      if user = verifyUser res
        if nick = user.nickname
          res.reply "Okay! #{user.name} is no longer known as #{nick}!"
          delete user.nickname
        else 
          res.reply "#{user.name} doesn't have one, yet ;)"