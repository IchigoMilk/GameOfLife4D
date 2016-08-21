class @Lifegame
	_rules = new Array()
	_rules.normal2d = ( surrounded, current_state ) ->
		return if surrounded <= 1 or surrounded > 4
			false
		else if surrounded == 3
			true
		else
			current_state

	_rules.normal4d = ( surrounded, current_state ) ->
		return if surrounded <= 5 or surrounded > 35
			false
		else if surrounded <= 15 or surrounded > 30
			true
		else
			current_state

	_boundaryConditions = new Array()
	_boundaryConditions.nothing = ( neighbor, field_length ) ->
		return neighbor

	_boundaryConditions.dirichlet = ( neighbor, field_length ) ->
		cells = new Array()
		neighbor.forEach ( d, i ) ->
			if d.join().indexOf( '-1' ) == -1 and
				d.join().indexOf( field_length.toString() ) == -1
					cells.push d
		return cells

	_boundaryConditions.periodic = ( neighbor, field_length ) ->
		cells = new Array()
		neighbor.forEach ( d, i ) ->
			d = d.map ( d, i ) ->
				return if d == -1
					field_length - 1
				else if d == field_length
				  	0
				else
					d
			cells.push d
		return cells

	_generateState = ( survival_rate ) ->
		return if Math.random() < survival_rate
			true
		else
			false

	_generateField = ( rank, dimension, initial_survival_rate ) ->
		f = new Array()
		for i in [ 0..dimension - 1 ]
			if rank > 1
				f.push _generateField ( rank - 1 ), dimension, initial_survival_rate
			else
				f.push _generateState initial_survival_rate
		return f

	_getState = ( f, rank, rank_origin, cell ) ->
		if rank > 1
			_getState f[ cell[ rank_origin - rank ] ],
				rank - 1, rank_origin, cell
		else
			return f[ cell[ rank_origin - rank ] ]

	_localSpace = ( current_position, field_length, boundary_condition ) ->
		rank = current_position.length
		neighbor = new Array()
		for i in [ 0..3 ** rank - 1 ]
			x = i
			cell = new Array()
			for j in [ 0..rank - 1 ]
				cell.push x % 3 - 1 + current_position[ j ]
				x = Math.floor x / 3
			neighbor.push cell
		neighbor.splice ( 3 ** rank - 1 ) / 2, 1
		return boundary_condition neighbor, field_length

	_getElem = ( field, index ) ->
		e = field
		for d, i in index
			e = e[ d ]

		return e

	_nextCellState = ( field, index, rule, boundary_condition ) ->
		current_state = _getElem field, index
		
		field_length = field.length
		ls = _localSpace index, field_length, _boundaryConditions[ boundary_condition ]
		surrounded = 0
		
		ls.forEach ( d, i ) ->
			surrounded += _getElem field, d
			return surrounded

		return _rules[ rule ] surrounded, current_state

	_refreshCellState = ( f, rank, rank_origin, cell, next_state ) ->
		if rank > 1
			_refreshCellState f[ cell[ rank_origin - rank ] ],
				rank - 1, rank_origin, cell, next_state
		else
			f[ cell[ rank_origin - rank ] ] = next_state
		
	constructor: ( rank, dimension, rule,
		boundary_condition, initial_survival_rate ) ->
			_rank = Math.max rank, 1
			_dimension = dimension
			_rule = rule
			_boundary_condition = boundary_condition
			_initial_survival_rate = initial_survival_rate

			_f = _generateField rank, _dimension, _initial_survival_rate
			_current_state = new Array()
			_genesis = 1
			_generation = 1
			_cells = dimension ** rank

			@setField = ( field ) ->
				_f = field

			@setRule = ( rule ) ->
				_rule = rule

			@setBoundaryCondition = ( boundary_condition ) ->
				_boundary_condition = boundary_condition

			@setCell = ( value, index ) ->
				_refreshCellState _f, _rank, _rank, index, value

			@genesis = () ->
				_genesis

			@generation = () ->
				_generation
			
			@isStable = () ->
				for i in [ 0.._dimension ** _rank - 1 ]
					x = i
					cell = new Array()
					for j in [ 0.._rank - 1 ]
						cell.push x % _dimension
						x = Math.floor x / _dimension
					ns = _nextCellState _f, cell, _rule, _boundary_condition
					if _current_state[ i ] != ns
						return false

				true

			@present = () ->
				_f

			@getCell = ( index ) ->
				_getElem _f, index

			@cells = () ->
				_cells

			@alive = () ->
				count = 0
				for i in [ 0.._dimension ** _rank - 1 ]
						x = i
						cell = new Array()
						for j in [ 0.._rank - 1 ]
							cell.push x % _dimension
							x = Math.floor x / _dimension
						
						count += _getState _f, _rank, _rank, cell

				count
			
			@regenerate = () ->
				_f = _generateField _rank, _dimension, _initial_survival_rate
				_genesis += 1
				_generation = 1

			@clear = () ->
				_f = _generateField _rank, _dimension, 0.0
				_genesis = 1
				_generation = 1			

			@step = () ->
				_current_state = new Array()
				next_state = new Array()
				for i in [ 0.._dimension ** _rank - 1 ]
					x = i
					cell = new Array()
					for j in [ 0.._rank - 1 ]
						cell.push x % _dimension
						x = Math.floor x / _dimension
					ns = _nextCellState _f, cell, _rule, _boundary_condition
					next_state.push ns
					_current_state.push ns

				for i in [ 0.._dimension ** _rank - 1 ]
					x = i
					cell = new Array()
					for j in [ 0.._rank - 1 ]
						cell.push x % _dimension
						x = Math.floor x / _dimension
					
					_refreshCellState _f, _rank, _rank, cell, next_state[ i ]
	
				_generation += 1
			
			@next = ( steps ) ->
				for i in [ 0..steps - 1 ]
					@step()
