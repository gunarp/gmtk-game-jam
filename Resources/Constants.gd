class_name Constants extends Node

## Character Speed
const Speed: float = 2.;
## Character acceleration curve
const Acceleration = .28;
## Character friction curve
const Friction = .337;
## acceleration value when the character goes in the opposite direction
const TurnSpeed: float = .56;

## the force the character will exert towards the ground
const Gravity: float = .3;
## multiplier of the force exerted by the character on the ground
const DownGravity: float = 1;
## multiplier of the force exerted by the character on the ground
const UpGravity: float = .8;
## Maximum the maximum force the character will exert on the ground
const GravityMaximum: float = 4.75;
# GravityScale
const GravityScale: float = 1.;
## acceleration value in air
const AirAcceleration: float = 0.2;
## control value in air
const AirControl: float = .85;
## friction value in air
const AirBrake: float = .25;

## how high the character jumps
const JumpHeight: float = 4.5;
# how much the jump will decrease in divide when the key is released.
const JumpCutoff: float = 2;
## whether wall jump will be active
const Wall_active: bool = true;
## To make a slide on the wall, the character must walk towards the wall.
const Wall_OnlyWhenMoving: bool = true;
## the gravity of the wall slide
const Wall_Gravity: float = .1;
## maximum gravity when doing a wall slide
const Wall_GravityMax: float = 1.75;
## wall jump height
const Wall_JumpHeight: float = 3.5;
## small wall jump jump value
const Wall_JumpHeightMin: float = 3;
## how much to push the character during wall jumpo
const Wall_JumpOffset: float = 4;
## character push value on small wall jumps
const Wall_JumpOffsetMin: float = 2;
## How long (seconds) inputs will be deactive on wall jumps
const Wall_JumpInputCooldown: float = .1;
## how many pixels away to control the walls for wall jump
const Wall_SafeMargin: float = 2;
## record the jump for the key pressed a few seconds before
const Wall_JumpBuffer: float = .1;

const Dash_Strength: float = 2.5;
const Dash_input_cooldown: float = .1;
const Dash_up_scale: float = .6;
const Dash_down_scale: float = 1;
const Dash_right_scale: float = 1.2;
const Dash_left_scale: float = 1.2;
const Dash_Count: float = 1;

## the time allowed to jump when falling from platforms.
const CoyotoTime: float = .15;
## when the character tries to jump while near the ground, the time it takes to jump when he reaches the ground
const JumpBuffer: float = .15;
## How far should you check to see if you are in the corner? The value should be adjusted according to the collision width.
const EdgeCheckDistance: float = 8;
## pushing the character around the corner when the character's head hits the corner.
const CornerCorrectionSize: float = 3;
