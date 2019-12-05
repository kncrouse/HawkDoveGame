globals [
  doves-extinct?
  hawks-extinct?
  retaliators-extinct?
  dove-payoff
  hawk-payoff
  retaliator-payoff
]

; THREE STRATEGIES:
breed [hawks hawk]
breed [doves dove]
breed [retaliators retaliator]

turtles-own [ payoff fighting? ]

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;::::: SETUP ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

to setup

  clear-all
  ask patches [ set pcolor white ]

  set doves-extinct? false
  set hawks-extinct? false
  set retaliators-extinct? false

  create-hawks initial-number-hawks [ set color red ]
  create-doves initial-number-doves [ set color blue ]
  create-retaliators initial-number-retaliators [ set color green ]

  ask turtles [
    set fighting? false
    move-to one-of patches
  ]

  reset-ticks

end

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;::::: GO :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

to go

  update-payoff-plots
  update-turtles
  ask turtles [ move fight ]

  if ( doves-extinct? = false ) and initial-number-doves > 0 and count doves = 0 [ set doves-extinct? true output-print (word "Doves went extinct at " ticks " ticks when the mean payoff structure was: " dove-payoff " for doves, " hawk-payoff " for hawks, " retaliator-payoff " for retaliators.")]
  if ( hawks-extinct? = false ) and initial-number-hawks > 0 and count hawks = 0 [ set hawks-extinct? true output-print (word "Hawks went extinct at " ticks " ticks when the mean payoff structure was: " dove-payoff " for doves, " hawk-payoff " for hawks, " retaliator-payoff " for retaliators.")]
  if ( retaliators-extinct? = false ) and initial-number-retaliators > 0 and count retaliators = 0 [ set retaliators-extinct? true output-print (word "Retaliators went extinct at " ticks " ticks when the mean payoff structure was: " dove-payoff " for doves, " hawk-payoff " for hawks, " retaliator-payoff " for retaliators.")]

  if ( stop-at > 0 and ticks >= stop-at ) or not any? turtles [ stop ]

  tick
end

to update-turtles
  ask turtles with [ fighting? = true and payoff < 0 ] [ die ]
  ask turtles with [ fighting? = true and payoff >= 0 ] [ reproduce ]
  ask n-of ( count turtles - initial-number-hawks - initial-number-doves - initial-number-retaliators ) turtles [ die ]
end

to update-payoff-plots
  set dove-payoff precision ifelse-value (any? doves with [fighting? = true]) [ mean [payoff] of doves with [ fighting? = true] ][ dove-payoff ] 0
  set hawk-payoff precision ifelse-value (any? hawks with [fighting? = true]) [ mean [payoff] of hawks with [ fighting? = true] ][ hawk-payoff ] 0
  set retaliator-payoff precision ifelse-value (any? retaliators with [fighting? = true]) [ mean [payoff] of retaliators with [ fighting? = true] ][ retaliator-payoff ] 0
end

to move
  rt random 180
  lt random 180
  fd 2
end

to reproduce
  hatch 2 [
    set payoff 0
    set fighting? false
    move-to one-of patches ]
  die
end

to fight

  if fighting? = false
  [
    let opponent one-of other turtles-here with [ fighting? = false ]
    if opponent != nobody
    [
      set fighting? true
      ask opponent [ set fighting? true ]

      ; HAWK vs. DOVE
      if is-hawk? self and is-dove? opponent [
        set payoff (payoff + win-gain)
      ]

      ; DOVE vs. HAWK
      if is-dove? self and is-hawk? opponent [
        ask opponent [ set payoff (payoff + win-gain) ]
      ]

      ; DOVE vs. DOVE or DOVE vs. RETALIATOR or RETALIATOR vs. DOVE or RETALIATOR vs. RETALIATOR
      if ( is-dove? self and is-dove? opponent ) or ( is-dove? self and is-retaliator? opponent ) or ( is-retaliator? self and is-dove? opponent ) or ( is-retaliator? self and is-retaliator? opponent ) [
        ifelse ( random-float 1 < 0.5 )
        [ ; LOSER
          set payoff (payoff - time-cost - loss-cost)
          ask opponent [ set payoff (payoff + win-gain - time-cost) ]
        ]
        [ ; WINNER
          set payoff (payoff + win-gain - time-cost)
          ask opponent [ set payoff (payoff - time-cost - loss-cost) ]
        ]
      ]

      ; HAWK vs. HAWK or HAWK vs. RETALIATOR or RETALIATOR vs. HAWK
      if ( is-hawk? self and is-hawk? opponent ) or ( is-hawk? self and is-retaliator? opponent ) or ( is-retaliator? self and is-hawk? opponent ) [
        ifelse ( random-float 1 < 0.5 )
        [ ; LOSER
          set payoff (payoff - injury-cost - loss-cost)
          ask opponent [ set payoff (payoff + win-gain) ]
        ]
        [ ; WINNER
          set payoff (payoff + win-gain)
          ask opponent [ set payoff (payoff - injury-cost - loss-cost) ]
        ]
      ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
209
72
714
578
-1
-1
12.744
1
10
1
1
1
0
1
1
1
-19
19
-19
19
1
1
1
ticks
30.0

SLIDER
9
235
202
268
initial-number-doves
initial-number-doves
0
500
0.0
2
1
NIL
HORIZONTAL

SLIDER
7
339
203
372
win-gain
win-gain
0.0
500
50.0
1.0
1
NIL
HORIZONTAL

SLIDER
9
195
202
228
initial-number-hawks
initial-number-hawks
0
500
100.0
2
1
NIL
HORIZONTAL

SLIDER
7
418
203
451
injury-cost
injury-cost
0.0
200.0
100.0
1.0
1
NIL
HORIZONTAL

BUTTON
30
77
99
110
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
106
77
173
110
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
813
72
898
117
# Doves
count doves
3
1
11

MONITOR
722
72
809
117
# Hawks
count hawks
3
1
11

SWITCH
818
224
959
257
show-payoff?
show-payoff?
1
1
-1000

SLIDER
7
458
203
491
time-cost
time-cost
0
100
10.0
1
1
NIL
HORIZONTAL

PLOT
723
389
1021
576
Strategy Payoffs over Time
Time
Mean Payoff
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"hawks" 1.0 0 -2674135 true "" "if count hawks > 0 [ plot hawk-payoff ]"
"doves" 1.0 0 -13345367 true "" "if count doves > 0 [ plot dove-payoff ]"
"retaliators" 1.0 0 -10899396 true "" "if count retaliators > 0 [ plot retaliator-payoff ]"

MONITOR
724
338
810
383
Dove Payoff
dove-payoff
2
1
11

MONITOR
817
338
904
383
Hawk Payoff
hawk-payoff
2
1
11

PLOT
723
174
1017
331
Ratio of Strategies over Time
Time
Ratio
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"hawks" 1.0 0 -2674135 true "" "if any? turtles [ plot count hawks / count turtles ]"
"doves" 1.0 0 -13345367 true "" "if any? turtles [ plot count doves / count turtles ]"
"retaliators" 1.0 0 -10899396 true "" "if any? turtles [ plot count retaliators / count turtles ]"

MONITOR
814
124
900
169
Doves / Total
count doves / count turtles
3
1
11

MONITOR
722
124
809
169
Hawks / Total
count hawks / count turtles
3
1
11

SLIDER
8
274
203
307
initial-number-retaliators
initial-number-retaliators
0
500
0.0
2
1
NIL
HORIZONTAL

MONITOR
904
72
1018
117
# Retaliators
count retaliators
17
1
11

MONITOR
906
124
1018
169
Retaliators / Total
count retaliators / count turtles
3
1
11

MONITOR
911
338
1019
383
Retaliators Payoff
retaliator-payoff
3
1
11

SLIDER
7
378
203
411
loss-cost
loss-cost
0
100
0.0
1
1
NIL
HORIZONTAL

TEXTBOX
35
317
184
347
---- Payoff Values ----
12
0.0
1

MONITOR
44
502
173
551
Carrying Capacity
initial-number-hawks +\ninitial-number-doves +\ninitial-number-retaliators
0
1
12

OUTPUT
13
10
1020
64
13

SLIDER
8
122
201
155
stop-at
stop-at
0
10000
1000.0
100
1
ticks
HORIZONTAL

TEXTBOX
27
169
193
199
---- Initial Population ----
12
0.0
1

@#$#@#$#@
This version is compatible with NetLogo 6.0.2

## WHAT IS IT?

This model simulates the Hawk-Dove game as first described by John Maynard Smith, and furthr elaborated by Richard Dawkins in "The Selfish Gene." In the game, two strategies, Hawks and Doves, compete against each other, and themselves, for reproductive benefits. A third strategy can be introduced, Retaliators, which act like either Hawks or Doves, depending on the context. All three strategies are described below:

Doves: These agents are not aggressive. When competing over a resource, Doves “display,” performing some sort of seemingly ritualized behavior, such as strutting with their tail feathers held high. When both opponents display (Dove vs. Dove), one of them randomly eventually gives up the reward to the other; they both pay a small cost for wasting time. If their opponent is aggressive (such as a Hawk), they always retreat rather than fight. 

Hawks: These agents are aggressive and fight with opponents that do not retreat (Hawk vs. Hawk) until one of them is seriously injured; the other one gets the resource. Hawks always win against Doves because Doves retreat. 

Retaliators: These agents begin by displaying (like a Dove) but become aggressive if their opponents are aggressive. Therefore, they behave as a Dove when confronted with a Dove or another Retaliator, but as a Hawk when they encounter another Hawk.

You can choose which types of strategies play against each other, and what the payoff structure is for their encounters.

## HOW IT WORKS

Upon initialization, agents of each strategy are created, depending upon the population parameter settings. At each time step, agents move about randomly. If they encounter another individual, they play a "game" to determine a winner. The winner is determined by the types of strategies being played. The reward for winning and the cost for losing are determined by the payoff parameter settings.

## HOW TO USE IT

### PARAMETERS

SETUP: returns the model to the starting state.
GO: runs the simulation.
STOP-AT: if set to greater than zero, this defines when the simulation stops

INITIAL-NUMBER-HAWKS: initial number of individuals created with the hawk strategy
INITIAL-NUMBER-DOVES: initial number of individuals created with the dove strategy
INITIAL-NUMBER-RETALIATORS: initial number of individuals created with the retaliator strategy

WIN-GAIN: value gained by winner of a contest
LOSS-COST: value lost by the loser of a contest
INJURY-COST: value lost by the loser of a physical contest
TIME-COST: value lost by the loser of a display contest

### MONITORS & PLOTS

CARRYING CAPACITY: the maximum amount of individuals allowed in the simulation
 # HAWKS: the number of hawks present
 # DOVES: the number of doves present
 # RETALIATORS: the number of retaliators present
HAWKS / TOTAL: ratio of hawks to total individuals present
DOVES / TOTAL: ratio of doves to total individuals present
RETALIATORS / TOTAL: ratio of retaliators to total individuals present


## THINGS TO NOTICE

An evolutionarily stable strategy (ESS) is one that cannot be invaded by another strategy. Which strategy or strategies are an ESS?


## HOW TO CITE

Crouse, K. N. (2018).  The Hawk-Dove Game model. Evolutionary Anthropology Lab, Department of Anthropology, University of Minnesota, Minneapolis, MN.


## COPYRIGHT AND LICENSE

Copyright 2018 K N Crouse

This model was created at the University of Minnesota as part of a series of applets to illustrate principles in biological evolution.

The model may be freely used, modified and redistributed provided this copyright is included and the resulting models are not used for profit.

Contact K N Crouse at crou0048@umn.edu if you have questions about its use.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Rectangle -1 true true 166 225 195 285
Rectangle -1 true true 62 225 90 285
Rectangle -1 true true 30 75 210 225
Circle -1 true true 135 75 150
Circle -7500403 true false 180 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Rectangle -7500403 true true 195 106 285 150
Rectangle -7500403 true true 195 90 255 105
Polygon -7500403 true true 240 90 217 44 196 90
Polygon -16777216 true false 234 89 218 59 203 89
Rectangle -1 true false 240 93 252 105
Rectangle -16777216 true false 242 96 249 104
Rectangle -16777216 true false 241 125 285 139
Polygon -1 true false 285 125 277 138 269 125
Polygon -1 true false 269 140 262 125 256 140
Rectangle -7500403 true true 45 120 195 195
Rectangle -7500403 true true 45 114 185 120
Rectangle -7500403 true true 165 195 180 270
Rectangle -7500403 true true 60 195 75 270
Polygon -7500403 true true 45 105 15 30 15 75 45 150 60 120

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
setup
set grass? true
repeat 75 [ go ]
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
