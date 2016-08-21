# Constants
## game
RANK = 4
DIMENSION = 8
INIT_SURVIVAL_RATE = 0.2

# Ctrls
## game
@rule = 'normal4d'
@boundary_condition = 'periodic'
## view
@scale = 10
@ctrl = false
@rotate_speed = 0.1
@radius = 250

# FPSMonitor
stats = new Stats()
stats.domElement.style.position = 'absolute'
stats.domElement.style.left = ( window.innerWidth - 80 ).toString() + 'px'
stats.domElement.style.top = ( window.innerHeight - 50 ).toString() + 'px'
$( 'body' ).append stats.domElement

# ControlPanel
controlPanel = new dat.GUI()
controlPanel.add( window, 'rotate_speed', 0, 1 ).step 0.1
controlPanel.add( window, 'radius', 0, 500 ).step 50
controlPanel.add( window, 'ctrl', true, false )
controlPanel.add( window, 'rule', [ 'normal2d', 'normal4d' ] )
controlPanel.add( window, 'boundary_condition', [ 'periodic', 'dirichlet' ] )
controlPanel.close()

# Game
game = new Lifegame RANK, DIMENSION, rule, boundary_condition, INIT_SURVIVAL_RATE
g = game.present()

# Scene
scene = new THREE.Scene()

# Camera
camera = new THREE.PerspectiveCamera(
	60, 									# field of view
	window.innerWidth / window.innerHeight, # aspect ratio
	1, 										# near
	1000 									# far
)

# Renderer
renderer = new THREE.WebGLRenderer()
renderer.setSize window.innerWidth, window.innerHeight
renderer.domElement.style.position = 'absolute'
$( '#container' ).append renderer.domElement

decToHexRGB = ( r, g, b ) ->
	return (
		( r & 0x0000FF ) << 16	|
		( g & 0x0000FF ) << 8	|
		( b & 0x0000FF )
	)#.toString 16

decToHue = ( d ) ->
	d_smooth = Math.cos 4 * Math.PI * d
	d_fixed = 255 * ( - d_smooth / 2 + 0.5 )
	if d == 1.0
		lum_r = 255; lum_g = 0; lum_b = 0
	else if d >= 3.0 / 4.0
		lum_r = 255; lum_g = d_fixed; lum_b = 0
	else if d >= 2.0 / 4.0
		lum_r = d_fixed; lum_g = 255; lum_b = 0
	else if d >= 1.0 / 4.0
		lum_r = 0; lum_g = 255; lum_b = d_fixed
	else if d > 0.05
		lum_r = 0; lum_g = d_fixed; lum_b = 255
	else
		lum_r = 0; lum_g = 0; lum_b = 0

	return decToHexRGB lum_r, lum_g, lum_b

# Object
colorAlive = 0x22FF22
colorDead = 0x222222

geometry = new THREE.BoxGeometry scale, scale, scale

max = 2 ** DIMENSION - 1
cell = new Array()
for i in [ 0..DIMENSION - 1 ]
	cell[ i ] = new Array()
	for j in [ 0..DIMENSION - 1 ]
		cell[ i ][ j ] = new Array()
		for k in [ 0..DIMENSION - 1 ]
			sum = 0
			for l in [ 0..DIMENSION - 1 ]
				sum += ( g[ i ][ j ][ k ][ l ] * 2 ) ** l


			# color = Math.floor 255 * sum / max
			# color_s = ( Math.floor color ).toString( 16 )
			# if color_s.length < 2 then color_s = '0' + color_s
			# color_s = '0x' + color_s + color_s + color_s

			color = sum / max
			color_s = decToHue color

			cell[ i ][ j ][ k ] = new THREE.Mesh geometry, new THREE.MeshBasicMaterial {
				color: color_s,
				wireframe: true
			}

			# cell[ i ][ j ][ k ] = if g[ i ][ j ][ k ][ 0 ] == true
			# 	new THREE.Mesh geometry, new THREE.MeshBasicMaterial {
			# 		color: colorAlive,
			# 		wireframe: true
			# 	}
			# else
			# 	new THREE.Mesh geometry, new THREE.MeshBasicMaterial {
			# 		color: colorDead,
			# 		wireframe: true
			# 	}

			posx = i * scale * 2 - scale * ( DIMENSION - 1 )
			posy = j * scale * 2 - scale * ( DIMENSION - 1 )
			posz = k * scale * 2 - scale * ( DIMENSION - 1 )
			cell[ i ][ j ][ k ].position.set posx, posy, posz
			scene.add cell[ i ][ j ][ k ]

# Add mouse control
controls = new THREE.OrbitControls camera, renderer.domElement

showStatus = ( s ) ->
	aliveCellsNum = game.alive()
	allCellsNum = game.cells()
	$( '#status' ).html(
		'Genesis: ' + game.genesis().toString() +
		'<br />Generation: ' + game.generation().toString() +
		'<br />Alive: ' + aliveCellsNum + ' of ' + allCellsNum +
		' (' + ( 100 * aliveCellsNum / allCellsNum ).toFixed( 2 ) + '%)' +
		'<br />' + ( if game.isStable() then 'stable' else 'unstable' ) +
		'<br />' + ( s || '' )
	)

# flashCell = () ->
# 	for i in [ 0..DIMENSION - 1 ]
# 		for j in [ 0..DIMENSION - 1 ]
# 			for k in [ 0..DIMENSION - 1 ]
# 				cell[ i ][ j ][ k ].material.color.setHex 0xffffff

animateCell = ( cell ) ->
	for i in [ 0..DIMENSION - 1 ]
		for j in [ 0..DIMENSION - 1 ]
			for k in [ 0..DIMENSION - 1 ]
				cell[ i ][ j ][ k ].rotation.x += 0.05 * ( i - 3 )
				cell[ i ][ j ][ k ].rotation.y += 0.05

theta = 0
animateField = ( camera ) ->
	camera.position.x = radius * Math.sin THREE.Math.degToRad( theta )
	camera.position.y = radius * Math.sin THREE.Math.degToRad( theta )
	camera.position.z = radius * Math.cos THREE.Math.degToRad( theta )
	camera.lookAt scene.position

refreshCellColor = ( cell ) ->
	g = game.present()
	# for i in [ 0..DIMENSION - 1 ]
	# 	for j in [ 0..DIMENSION - 1 ]
	# 		for k in [ 0..DIMENSION - 1 ]
	# 			cell[ i ][ j ][ k ].material.color.setHex(
	# 				if g[ i ][ j ][ k ][ 0 ] == true
	# 					colorAlive
	# 				else
	# 					colorDead
	# 			)
	max = 2 ** DIMENSION - 1
	for i in [ 0..DIMENSION - 1 ]
		for j in [ 0..DIMENSION - 1 ]
			for k in [ 0..DIMENSION - 1 ]
				sum = 0
				for l in [ 0..DIMENSION - 1 ]
					sum += ( g[ i ][ j ][ k ][ l ] * 2 ) ** l

				# color = Math.floor 255 * sum / max
				# color_s = ( Math.floor color ).toString( 16 )
				# if color_s.length < 2 then color_s = '0' + color_s
				# color_s = '0x' + color_s + color_s + color_s
				color = sum / max
				color_s = decToHue color
				cell[ i ][ j ][ k ].material.color.setHex color_s
				# console.log color

mouse = () ->
	$( window ).mousemove ( e ) ->
		rect = e.target.getBoundingClientRect()

		mouseX = e.clientX - rect.left
		mouseY = e.clientY - rect.top

		mouseX = ( mouseX / window.innerWidth ) * 2 - 1
		mouseY = ( mouseY / window.innerHeight ) * 2 + 1

		p = new THREE.Vector3 mouseX, mouseY, 1

		p.unproject camera# p, camera

		ray = new THREE.Raycaster camera.position, p.sub( camera.position ).normalize()

		obj = ray.intersectObjects scene.chidren

		if obj.length
			showStatus(
				obj.toString()
				# 'x: ' + obj[ 0 ].object.position.x +
				# 'y: ' + obj[ 0 ].object.position.y
			)

key = () ->
	$( window ).keydown ( e ) ->
		switch e.keyCode
			# when 65 # A
			# 	ctrl = false

			# when 66 # B
			# 	ctrl = true

			when 67 # C
				game.step()
				refreshCellColor cell

			# when 68 # D
			# 	for i in [ 0..DIMENSION - 1 ]
			# 		for j in [ 0..DIMENSION - 1 ]
			# 			for k in [ 0..DIMENSION - 1 ]
			# 				cell[ i ][ j ][ k ].material.color.setHex 0xffffff

			when 69 # E
				game.regenerate()
				refreshCellColor cell

			else
				return true

		showStatus()
		return false

rl = rule
bc = boundary_condition

render = () ->
	stats.begin()

	# animateCell cell

	# to detect changes

	theta += rotate_speed

	if ctrl
		controls.update()
	else
		animateField( camera )

	if rl != rule
		game.setRule rule

	if bc != boundary_condition
		game.setBoundaryCondition boundary_condition

	rl = rule
	bc = boundary_condition

	# 	rotate_speed = - rotate_speed
	# 	# game.regenerate()
	# if continuous_generate
	# unless game.alive()
	# 	game.regenerate()

	# if game.isStable()
		# game.regenerate()

	# 	unless game.stable

	renderer.render scene, camera

	stats.end()

	requestAnimationFrame render

showStatus()
# mouse()
key()
render()
