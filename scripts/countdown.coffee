# Description
#   Set countdown date and retreive countdown (number of days remaining).
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot countdown set #meetupname# #datestring# e.g. countdown set punerbmeetup 21 Jan 2014
#   hubot countdown [for] #meetupname# e.g. countdown punerbmeetup
#   hubot countdown list
#   hubot countdown delete #meetupname# e.g. countdown delete seattlerbmeetup
#   hubot countdown clear
#
# Notes:
#   None
#
# Author:
#   @anildigital

module.exports = (robot) ->

  # Get countdown message
  getCountdownMsg = (countdownKey) ->
    now = new Date()
    eventTime = new Date(robot.brain.data.countdown[countdownKey].date)
    gap = eventTime.getTime() - now.getTime()
    gap =  Math.floor(gap / (1000 * 60 * 60 * 24));
    "¡Sólo quedan #{gap} días hasta la #{countdownKey}!"

  robot.respond /countdown set (\w+) (.*)/i, (msg) ->
    robot.brain.data.countdown or= {}

    dateString = msg.match[2];

    try
      date = new Date(dateString);
      if date == "Invalid Date"
        throw "Invalid date passed"
      countdownKey = msg.match[1]

      robot.brain.data.countdown[countdownKey] = {"date" : date.toDateString()}
      msg.send "Countdown set for #{countdownKey} at #{date.toDateString()}"
      msg.send getCountdownMsg(countdownKey)  if robot.brain.data.countdown.hasOwnProperty(countdownKey)
    catch error
        console.log(error.message)
        msg.send "Invalid date passed!"

  robot.respond /countdown list/i, (msg) ->
    countdowns = robot.brain.data.countdown;
    for countdownKey of countdowns
      msg.send countdownKey + " -> " + new Date(countdowns[countdownKey].date).toDateString() +
        " -> " + getCountdownMsg(countdownKey) if countdowns.hasOwnProperty(countdownKey)

  robot.respond /(countdown)( for)? (.*)/, (msg) ->
    countdownKey = msg.match[3]
    countdowns = robot.brain.data.countdown;
    msg.send getCountdownMsg(countdownKey)  if countdowns.hasOwnProperty(countdownKey)

  robot.respond /countdown clear/i, (msg) ->
    robot.brain.data.countdown = {}
    msg.send "Countdowns cleared"

  robot.respond /countdown delete (.*)/i, (msg) ->
    countdownKey = msg.match[1]
    if robot.brain.data.countdown.hasOwnProperty(countdownKey)
      delete robot.brain.data.countdown[countdownKey]
      msg.send "Countdown for #{countdownKey} deleted."
    else
      msg.send "Countdown for #{countdownKey} does not exist!"

  robot.respond /countdown set$|countdown help/i, (msg) ->
    msg.send "countdown set #meetupname# #datestring# e.g. countdown set BeerJS 27 May 2015"
    msg.send "countdown [for] #meetupname# e.g. countdown BeerJS"
    msg.send "countdown list"
    msg.send "countdown delete #meetupname# e.g. countdown delete BeerJS"
    msg.send "countdown clear"
