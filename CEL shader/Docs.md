# Documentation

This is a module I use for CEL shading in Roblox, for highlighting models at runtime or at contextual events in-game. This module is finished as it has full functionality
tested and run in a live game. It's advised to use this on cartoony looking games or when highlighting parts or models in-game for UX purposes.

Alright, time for the functions.

## void applyCelShader([Model](https://developer.roblox.com/en-us/api-reference/class/Model) groupedModel, [BrickColor](https://developer.roblox.com/en-us/api-reference/datatype/BrickColor) brickColor)

#### This function applies CEL shaders to all the model's descendants that are baseparts. Mostly used for player characters. The shaders are stored in a model inside
the groupedModel and is not to be touched unless you know what you're doing. It also welds the shaders to the individual descendants of the groupedModel and are parented
to the shaders.

## void removeCelShader([Model](https://developer.roblox.com/en-us/api-reference/class/Model) modelWithCelShading)

#### This function's purpose is only to delete the shaders in the model inside a previously shaded model, and does nothing else. Is meant to be lightweight for
asthetical purpose.

That's it! It's a module I solely made for fun and a method proposed by a friend in the Credits.
