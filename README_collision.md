# Collision
- Player: Layer = 1, Mask = 2 (Put 1 in mask to make anything collide w/ Player)
- Terrain: Layer = 2, Mask = None (Put 2 in mask to make anything collide w/ Terrain)
- Killzone: Layer = None, Mask = 1 (If we add spikes in the future, add another layer here, or put spikes on L1)
- GasCan: Layer = None, Mask = 1 (Only needs to collide w/ Player on L1)

# Note to Ben:
- Debug Menu --> Visible Collision Shapes is great for debugging. 
- I added layer names to layer 1,2 and 3. Mouse over it in the physics layers or click the 3 dots to see them. 
