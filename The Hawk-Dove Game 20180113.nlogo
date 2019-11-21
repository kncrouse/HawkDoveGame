globals [
  hawks-extinct?
  doves-extinct?
  retaliators-extinct?
  generation
  hawks-mean-payoff
  doves-mean-payoff
  retaliators-mean-payoff ]

; THREE STRATEGIES:
breed [hawks hawk]
breed [doves dove]
breed [retaliators retaliator]

turtles-own [payoff engaged ]

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;::::: SETUP ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

to setup

  clear-all
  ask patches [ set pcolor white ]

  ; these variables check if any strategy has gone extinct
  set doves-extinct? false
  set hawks-extinct? false
  set retaliators-extinct? false
  set generation 0

  ; create turtles based on initial parameters
  create-hawks initial-number-hawks [ set color red ]
  create-doves initial-number-doves [ set color blue ]
  create-retaliators initial-number-retaliators [ set color green ]

  ask turtles [
    set engaged 0
    move-to one-of patches
  ]

  ask one-of patches [ set pcolor green ]

  reset-ticks

end


;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;::::: GO :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

to go

  if ( count turtles with [ engaged > 0 ] = count turtles ) [ update ]

  ; logical checks for when to stop the simulation
  ;if ticks >= 100000 or not any? turtles [ stop ]
  if ( doves-extinct? = false ) and initial-number-doves > 0 and count doves = 0 [ set doves-extinct? true output-print (word "Doves wents extinct at " generation " generations.")]
  if ( hawks-extinct? = false ) and initial-number-hawks > 0 and count hawks = 0 [ set hawks-extinct? true output-print (word "Hawks wents extinct at " generation " generations.")]
  if ( retaliators-extinct? = false ) and initial-number-retaliators > 0 and count retaliators = 0 [ set retaliators-extinct? true output-print (word "Retaliators wents extinct at " generation " generations.")]

;  ask turtles with [ engaged = 1 ] [ move ]
;  ask turtles with [ engaged = 0 ] [ go-nearest-patch ]
  ask turtles [ move ]

  ask doves [ fight-as-dove ]
  ask hawks [ fight-as-hawk ]
  ask retaliators [ fight-as-retaliator ]


  tick

end

to go-nearest-patch
  face min-one-of patches with [ pcolor = green ] [ distance myself ]
  fd 1
end

to update
  ;print count turtles with [ engaged = 1 ]
  if any? hawks [ set hawks-mean-payoff mean [payoff] of hawks ]
  if any? doves [ set doves-mean-payoff mean [payoff] of doves ]
  if any? retaliators [ set retaliators-mean-payoff mean [payoff] of retaliators ]
;  ;ask min-n-of (count turtles / 2 ) turtles [ payoff ] [ die ]
;  ask max-n-of (count turtles / 2 ) turtles [ payoff ] [ reproduce ]
;  ask n-of ( count turtles - initial-number-hawks - initial-number-doves - initial-number-retaliators ) turtles [ die ]
;  ask turtles [ set engaged 0 ]

  ask max-n-of ( count turtles / 2 ) turtles [ payoff ] [ reproduce ]
  ;ask turtles with [ engaged = 1 ] [ die ]

  ask n-of ( count turtles - initial-number-hawks - initial-number-doves - initial-number-retaliators ) turtles [ die ]
  ask turtles [ set engaged 0 set payoff 0 ]
end


to move
  rt random 180
  fd 2
end

to fight

  if engaged = 0
  [
    let opponent one-of other turtles-here with [ engaged = 0 ]
    if opponent != nobody [
      set engaged 1
      ask opponent [ set engaged 1 ]

      ifelse is-hawk? opponent
      ;; Retaliator behaves as a hawk against a hawk
      [
        ifelse (random 10) < 5
        [
          set payoff (payoff - injury-cost)
          ask opponent [ set payoff (payoff + win-gain) ]
        ]
        [
          set payoff (payoff + win-gain)
          ask opponent [ set payoff (payoff - injury-cost) ]
        ]
      ]
      ;; Retaliator behaves as a dove agains another retaliator or a dove
      [
        ifelse (random 10) < 5
        [
          set payoff (payoff - time-cost)
          ask opponent [ set payoff (payoff + win-gain - time-cost) ]
        ]
        [
          set payoff (payoff + win-gain - time-cost)
          ask opponent [ set payoff (payoff - time-cost) ]
        ]
      ]

    ]
  ]

end


to reproduce
  print (word "REPRODUCE " breed " " payoff )
  hatch 2 [
    set payoff 0
    set engaged 0
    move-to one-of patches ]
  die
end


to fight-as-dove
  ;; Only not engaged dove can start a fight
  if engaged = 0
  [
    ;; Checking if there are available opponents in the patch to
    ;; start a fight
    let opponent one-of other turtles-here with [ engaged = 0 ]
    if opponent != nobody
    [
      ;;If there is a free oponent both get engaged in a fight
      set engaged 1
      ask opponent [ set engaged 1 ]

      ifelse is-hawk? opponent
      [
        ;; If opponent is a hawk, doves flee and hawks get the win-gain
        ask opponent [ set payoff (payoff + win-gain) ]
      ]
      [
        ;; If opponent is a dove or retaliator, doves pose for some time
        ;; which produces a penalty for wasting time. The probability of
        ;; eventually getting the win-gain is 0.5
        ifelse (random 10) < 5
        [ ; LOSER
          set payoff (payoff - time-cost)
          ask opponent [ set payoff (payoff + win-gain - time-cost) ]
        ]
        [ ; WINNER
          set payoff (payoff + win-gain - time-cost)
          ask opponent [ set payoff (payoff - time-cost) ]
        ]
      ]

    ]

  ]

end


to fight-as-hawk
  ;; Only not engaged hawks can start a fight
  if engaged = 0
  [
    ;; Checking if there are available opponents in the patch to
    ;; start a fight
    let opponent one-of other turtles-here with [ engaged = 0 ]
    if opponent != nobody
    [
      ;;If there is a free oponent both get engaged in a fight
      set engaged 1
      ask opponent [ set engaged 1 ]

      ifelse is-dove? opponent
      ;; If opponent is a dove, hawks get the win-gain and doves flee
      [
        set payoff (payoff + win-gain)
        ;print "is-dove"
      ]
      ;; If opponent is a hawk or a retaliator, they fight until one of them gets seriously injured
      [
        ifelse (random 10) < 5
        [ ; LOSER
          set payoff (payoff - injury-cost)
          ask opponent [ set payoff (payoff + win-gain) ]
        ]
        [ ; WINNER
          set payoff (payoff + win-gain)
          ask opponent [ set payoff (payoff - injury-cost) ]
        ]
      ]

    ]
  ]

end



to fight-as-retaliator
  ;; Only not engaged retaliators can start a fight
  if engaged = 0
  [
    ;; Checking if there are available opponents in the patch to
    ;; start a fight
    let opponent one-of other turtles-here with [ engaged = 0 ]
     if opponent != nobody
    [
      ;;If there is a free oponent both get engaged in a fight
      set engaged 1
      ask opponent [ set engaged 1 ]

      ifelse is-hawk? opponent
      ;; Retaliator behaves as a hawk against a hawk
      [
        ifelse (random 10) < 5
        [
          set payoff (payoff - injury-cost)
          ask opponent [ set payoff (payoff + win-gain) ]
        ]
        [
          set payoff (payoff + win-gain)
          ask opponent [ set payoff (payoff - injury-cost) ]
        ]
      ]
      ;; Retaliator behaves as a dove agains another retaliator or a dove
      [
        ifelse (random 10) < 5
        [
          set payoff (payoff - time-cost)
          ask opponent [ set payoff (payoff + win-gain - time-cost) ]
        ]
        [
          set payoff (payoff + win-gain - time-cost)
          ask opponent [ set payoff (payoff - time-cost) ]
        ]
      ]

    ]
  ]

end




;  print ""
;  set generation generation + 1
;
;  let winners max-n-of ( count turtles / 2) turtles [payoff]
;  let losers turtles with [ not member? self winners ]
;
;
;  ;ask winners [ reproduce ]

;  print ""
;  ask losers [
;    print (word "DIE: " breed " " payoff)
;    die ]
@#$#@#$#@
GRAPHICS-WINDOW
185
10
648
474
-1
-1
11.67
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
8
170
173
203
initial-number-doves
initial-number-doves
0
500
2.0
2
1
NIL
HORIZONTAL

SLIDER
6
274
175
307
win-gain
win-gain
0.0
500
50.0
5
1
NIL
HORIZONTAL

SLIDER
8
130
173
163
initial-number-hawks
initial-number-hawks
0
500
98.0
2
1
NIL
HORIZONTAL

SLIDER
6
353
175
386
injury-cost
injury-cost
0.0
200.0
100.0
5
1
NIL
HORIZONTAL

BUTTON
17
23
86
56
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
93
23
160
56
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
465
417
536
462
# Doves
count doves
3
1
11

MONITOR
377
417
459
462
# Hawks
count hawks
3
1
11

SWITCH
755
110
896
143
show-payoff?
show-payoff?
1
1
-1000

SLIDER
6
393
175
426
time-cost
time-cost
0
100
10.0
5
1
NIL
HORIZONTAL

PLOT
660
289
958
484
Average Payoff for each Strategy
Time
Average Payoff
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"hawks" 1.0 0 -2674135 true "" "if any? hawks [ plot hawks-mean-payoff ]"
"doves" 1.0 0 -13345367 true "" "if any? doves [ plot doves-mean-payoff ]"
"retaliators" 1.0 0 -10899396 true "" "if any? retaliators [ plot retaliators-mean-payoff ]"

MONITOR
661
238
747
283
Dove Payoff
mean [payoff] of doves
2
1
11

MONITOR
754
238
841
283
Hawk Payoff
mean [payoff] of hawks
2
1
11

PLOT
660
60
954
231
Ratio of Strategies
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
750
10
836
55
Ratio Doves
count doves / count turtles
3
1
11

MONITOR
659
10
746
55
Ratio Hawks
count hawks / count turtles
3
1
11

SLIDER
7
209
173
242
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
542
417
632
462
# Retaliators
count retaliators
17
1
11

MONITOR
841
10
954
55
Ratio Retaliators
count retaliators / count turtles
3
1
11

MONITOR
848
238
956
283
Retaliators Payoff
mean [payoff] of retaliators
3
1
11

SLIDER
6
313
175
346
loss-cost
loss-cost
0
100
0.0
5
1
NIL
HORIZONTAL

TEXTBOX
38
252
151
270
---- Payoffs ----
12
0.0
1

MONITOR
26
71
155
120
Carrying Capacity
initial-number-hawks +\ninitial-number-doves +\ninitial-number-retaliators
0
1
12

OUTPUT
192
20
640
74
13

@#$#@#$#@
# Maynard Smith's Hawks and Doves

This version is compatible with NetLogo 6.0.2

## WHAT IS IT?


### "Any individual of our hypothetical population is classified as a hawk or a dove. Hawks always fight as hard and as unrestrainedly as they can, retreating only when seriously injured. Doves merely threaten in a dignified conventional way, never hurting anybody. If a hawk fights a dove the dove quickly runs away, and so does not get hurt. If a hawk fights a hawk they go on until one of them is seriously injured or dead. If a dove meets a dove nobody gets hurt; they go on posturing at each other for a long time until one of them tires or decides not to bother any more, and therefore backs down. For the time being, we assume that there is no way in which an individual can tell, in advance, whether a particular rival is a hawk or a dove. He only discovers this by fighting him, and he has no memory of past fights with particular individuals to guide him."


This model explores the evolution of aggresion in a system consisting of animals fighting for a resource necessary for reproduction. Three different strategies are considered: doves, hawks and retaliators. 

1. Doves are not aggresive, they start displaying and retreat at once if their opponent  is aggresive. When both opponents display one of them eventually gives up the reward to the other one but both pay a cost for wasting time.  

2. Hawks are aggresive and fight with opponents that do not retreat until one of them is seriously injured and the other one gets the reward.  

3. Retaliators start displaying but become aggresive when their opponents are aggresive. They behave as doves when confronted with a dove or another retaliator and as a hawk when they fight a hawk.  

This project explores if any of the three strategies is an ESS (Evolutionary Stable Strategy), a strategy that when adopted by most of the individuals in the population cannot be invaded by another strategy.  

## HOW TO USE IT

1. Set the SHOW-FITNESS? switch On to display the fitness associted with each individual or Off otherwise.   
2. Adjust the slider parameters (see below), or use the default settings.  
3. Press the SETUP button.  
4. Press the GO button to begin the simulation.  
5. Look at the POPULATIONS, FITNESS and RATIO plots to watch the population sizes, their fitness and the ratio of each individual type in the population fluctuate over time.  
6. Look at the monitors to see the current subpopulation sizes, their fitness and ratio. 

Parameters:  
SHOW-FITNESS?: Whether or not to show the fitness associate with each individual  
TIME-TO-REPRODUCE: Expected time to elpase before an individual reproduces  
INITIAL-NUMBER-DOVES: The initial size of the dove population  
INITIAL-NUMBER-HAWKS: The initial size of the hawk population  
INITIAL-NUMBER-RETALIATORS: The initial size of the retaliator population  
INITIAL-FITNESS: The initial fitness associated with each individual  
REWARD: Value added to an individual fitness after winning a fight   
COST-INJURE: Value substracted from an individual fitness after being injured during a fight   
COST-WASTED-TIME: Value substracted from an individual fitness after  dove or retaliator fitness 

## THINGS TO NOTICE

None of these strategy is an ESS with the default settings.

Note that a population of hawks can be invaded by a population of doves and viceversa.

Note that a population of retaliators cannot be invaded by a population of hawks but tolerates a subpopulation of doves. 

Note that a population of retaliators is driven extinct when both doves and hawks are introduced.  

## THINGS TO TRY

Try adjusting the parameters under various settings. Can you find any parameters that make one of these strategy an ESS?

## REFERENCES

Smith, J.M. (1982). Evolution and the Theory of Games. Cambridge University Press 

## COPYRIGHT NOTICE

Copyright 2011 Francisco J. Romero-Campero. All rights reserved.

Permission to use, modify or redistribute this model is hereby granted, provided that both of the following requirements are followed:  
a) this copyright notice is included.  
b) this model will not be redistributed for profit without permission from Francisco J. Romero-Campero. 

This model was created as part of the projects: COMPUTATIONAL MODELLING AND SIMULATION IN SYSTEMS BIOLOGY (grant number P08-TIC-04200) and CELLULAR COMPUTING; APPLICATIONS TO SYSTEMS AND SYNTHETIC BIOLOGY (grant number TIN2009-13192).These projects gratefully acknowledge the support of the Spanish Ministry of Science and Innovation and the Andalusian Agency for Economy, Innovation and Science. 
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
NetLogo 6.0.2
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
