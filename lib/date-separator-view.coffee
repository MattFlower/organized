{View} = require 'space-pen'

class DateSeparator extends View
  @content: (date, displayDate) ->
    @date = date
    @displayDate = displayDate
    @li class: "date-separator-item", =>
        @span class: 'date-separator-title', displayDate

module.exports = DateSeparator
