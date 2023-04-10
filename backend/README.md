#Notes on DB tables

## Implementation:

For testing purposes: only create building and room table and their relationships.

### Building
- Used to represent a building.

### Room
- Used to represent a room inside of a building.

### Pathway
- Used to represent the path from one building to another.

  *Note:* for now this is only for buldings. In the future we would need 
  to make this more flexible to be able to handle:
	- Building --> POI (Point of Interest)
	- POI --> POI
	- etc. 

### Floor
- Used to represent the floor of a building.

### Point of Interest
- Used to represent a "point of interest" such as a parking lot or bike repair.

### Entrance/Exit
- Used to locate the entrances and exits of a building.


