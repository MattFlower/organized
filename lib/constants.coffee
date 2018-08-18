moment = require 'moment'

class Constants
  @dateFormats: ['YYYY-MM-DD ddd HH:mm:ss', 'YYYY-MM-DD ddd HH:mm', 'YYYY-MM-DD ddd', moment.ISO_8601]

  @emptyLineOrStarLineRex:       /(^$)|(^\#)|(^\s*([\*\-\+]+|\d+\.|[A-z]\.))/
  @starLineRex:                  /(^\#)|(^\s*([\*\-\+]+|\d+\.|[A-z]\.))/
  @starWithBulletNoMarkersRex:   /^(\s*)([\*\-\+]+|\d+\.|[A-z]\.)/
  @starWithBulletRex:            /^(\s*)([\*\-\+]+|(\d+)\.|([A-z])\.)([ ]|$)((\[?TODO\]?|\[?(COMPLETED|DONE)\]?)(?:\s+))?(\[#([A-E])\]\s+)?/
  @starWithTextRex:              /^(\s*)([\*\-\+]+|(\d+)\.|[A-z]\.)([ ]|$)((\[?TODO\]?|\[?(COMPLETED|DONE)\]?)(?:\s+))?(\[#([A-E])\]\s+)?(.*)/
  @todoPriorityAndTextRex:       /(\[?TODO\]?)\s+(\[#([A-E])\]\s+)?(.*)$/

  @emptyLineOrStarLineRexGroups:  { EmptyStart: 1, WhitespacePlusStar: 2 }
  @starWithBulletNoMarkersGroups: { EmptyStart: 1, Star: 2 }
  @starWithBulletGroups:          { EmptyStart: 1, Star: 2, StarNum: 3, StarLetter: 4, ProgressWithWhitespace: 6, Progress: 7, PriorityWithWhitespace: 9, Priority: 10 }
  @starWithTextGroups:            { EmptyStart: 1, Star: 2, StarNum: 3, ProgressWithWhitespace: 5, Progress: 6, PriorityWithWhitespace: 8, Priority: 9, Text: 10 }

module.exports = Constants
