// Generated by CoffeeScript 1.8.0
(function() {
  this.Lifegame = (function() {
    var _boundaryConditions, _generateField, _generateState, _getElem, _getState, _localSpace, _nextCellState, _refreshCellState, _rules;

    _rules = new Array();

    _rules.normal2d = function(surrounded, current_state) {
      if (surrounded <= 1 || surrounded > 4) {
        return false;
      } else if (surrounded === 3) {
        return true;
      } else {
        return current_state;
      }
    };

    _rules.normal4d = function(surrounded, current_state) {
      if (surrounded <= 5 || surrounded > 35) {
        return false;
      } else if (surrounded <= 15 || surrounded > 30) {
        return true;
      } else {
        return current_state;
      }
    };

    _boundaryConditions = new Array();

    _boundaryConditions.nothing = function(neighbor, field_length) {
      return neighbor;
    };

    _boundaryConditions.dirichlet = function(neighbor, field_length) {
      var cells;
      cells = new Array();
      neighbor.forEach(function(d, i) {
        if (d.join().indexOf('-1') === -1 && d.join().indexOf(field_length.toString()) === -1) {
          return cells.push(d);
        }
      });
      return cells;
    };

    _boundaryConditions.periodic = function(neighbor, field_length) {
      var cells;
      cells = new Array();
      neighbor.forEach(function(d, i) {
        d = d.map(function(d, i) {
          if (d === -1) {
            return field_length - 1;
          } else if (d === field_length) {
            return 0;
          } else {
            return d;
          }
        });
        return cells.push(d);
      });
      return cells;
    };

    _generateState = function(survival_rate) {
      if (Math.random() < survival_rate) {
        return true;
      } else {
        return false;
      }
    };

    _generateField = function(rank, dimension, initial_survival_rate) {
      var f, i, _i, _ref;
      f = new Array();
      for (i = _i = 0, _ref = dimension - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (rank > 1) {
          f.push(_generateField(rank - 1, dimension, initial_survival_rate));
        } else {
          f.push(_generateState(initial_survival_rate));
        }
      }
      return f;
    };

    _getState = function(f, rank, rank_origin, cell) {
      if (rank > 1) {
        return _getState(f[cell[rank_origin - rank]], rank - 1, rank_origin, cell);
      } else {
        return f[cell[rank_origin - rank]];
      }
    };

    _localSpace = function(current_position, field_length, boundary_condition) {
      var cell, i, j, neighbor, rank, x, _i, _j, _ref, _ref1;
      rank = current_position.length;
      neighbor = new Array();
      for (i = _i = 0, _ref = Math.pow(3, rank) - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        x = i;
        cell = new Array();
        for (j = _j = 0, _ref1 = rank - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
          cell.push(x % 3 - 1 + current_position[j]);
          x = Math.floor(x / 3);
        }
        neighbor.push(cell);
      }
      neighbor.splice((Math.pow(3, rank) - 1) / 2, 1);
      return boundary_condition(neighbor, field_length);
    };

    _getElem = function(field, index) {
      var d, e, i, _i, _len;
      e = field;
      for (i = _i = 0, _len = index.length; _i < _len; i = ++_i) {
        d = index[i];
        e = e[d];
      }
      return e;
    };

    _nextCellState = function(field, index, rule, boundary_condition) {
      var current_state, field_length, ls, surrounded;
      current_state = _getElem(field, index);
      field_length = field.length;
      ls = _localSpace(index, field_length, _boundaryConditions[boundary_condition]);
      surrounded = 0;
      ls.forEach(function(d, i) {
        surrounded += _getElem(field, d);
        return surrounded;
      });
      return _rules[rule](surrounded, current_state);
    };

    _refreshCellState = function(f, rank, rank_origin, cell, next_state) {
      if (rank > 1) {
        return _refreshCellState(f[cell[rank_origin - rank]], rank - 1, rank_origin, cell, next_state);
      } else {
        return f[cell[rank_origin - rank]] = next_state;
      }
    };

    function Lifegame(rank, dimension, rule, boundary_condition, initial_survival_rate) {
      var _boundary_condition, _cells, _current_state, _dimension, _f, _generation, _genesis, _initial_survival_rate, _rank, _rule;
      _rank = Math.max(rank, 1);
      _dimension = dimension;
      _rule = rule;
      _boundary_condition = boundary_condition;
      _initial_survival_rate = initial_survival_rate;
      _f = _generateField(rank, _dimension, _initial_survival_rate);
      _current_state = new Array();
      _genesis = 1;
      _generation = 1;
      _cells = Math.pow(dimension, rank);
      this.setField = function(field) {
        return _f = field;
      };
      this.setRule = function(rule) {
        return _rule = rule;
      };
      this.setBoundaryCondition = function(boundary_condition) {
        return _boundary_condition = boundary_condition;
      };
      this.setCell = function(value, index) {
        return _refreshCellState(_f, _rank, _rank, index, value);
      };
      this.genesis = function() {
        return _genesis;
      };
      this.generation = function() {
        return _generation;
      };
      this.isStable = function() {
        var cell, i, j, ns, x, _i, _j, _ref, _ref1;
        for (i = _i = 0, _ref = Math.pow(_dimension, _rank) - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          x = i;
          cell = new Array();
          for (j = _j = 0, _ref1 = _rank - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
            cell.push(x % _dimension);
            x = Math.floor(x / _dimension);
          }
          ns = _nextCellState(_f, cell, _rule, _boundary_condition);
          if (_current_state[i] !== ns) {
            return false;
          }
        }
        return true;
      };
      this.present = function() {
        return _f;
      };
      this.getCell = function(index) {
        return _getElem(_f, index);
      };
      this.cells = function() {
        return _cells;
      };
      this.alive = function() {
        var cell, count, i, j, x, _i, _j, _ref, _ref1;
        count = 0;
        for (i = _i = 0, _ref = Math.pow(_dimension, _rank) - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          x = i;
          cell = new Array();
          for (j = _j = 0, _ref1 = _rank - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
            cell.push(x % _dimension);
            x = Math.floor(x / _dimension);
          }
          count += _getState(_f, _rank, _rank, cell);
        }
        return count;
      };
      this.regenerate = function() {
        _f = _generateField(_rank, _dimension, _initial_survival_rate);
        _genesis += 1;
        return _generation = 1;
      };
      this.clear = function() {
        _f = _generateField(_rank, _dimension, 0.0);
        _genesis = 1;
        return _generation = 1;
      };
      this.step = function() {
        var cell, i, j, next_state, ns, x, _i, _j, _k, _l, _ref, _ref1, _ref2, _ref3;
        _current_state = new Array();
        next_state = new Array();
        for (i = _i = 0, _ref = Math.pow(_dimension, _rank) - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          x = i;
          cell = new Array();
          for (j = _j = 0, _ref1 = _rank - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; j = 0 <= _ref1 ? ++_j : --_j) {
            cell.push(x % _dimension);
            x = Math.floor(x / _dimension);
          }
          ns = _nextCellState(_f, cell, _rule, _boundary_condition);
          next_state.push(ns);
          _current_state.push(ns);
        }
        for (i = _k = 0, _ref2 = Math.pow(_dimension, _rank) - 1; 0 <= _ref2 ? _k <= _ref2 : _k >= _ref2; i = 0 <= _ref2 ? ++_k : --_k) {
          x = i;
          cell = new Array();
          for (j = _l = 0, _ref3 = _rank - 1; 0 <= _ref3 ? _l <= _ref3 : _l >= _ref3; j = 0 <= _ref3 ? ++_l : --_l) {
            cell.push(x % _dimension);
            x = Math.floor(x / _dimension);
          }
          _refreshCellState(_f, _rank, _rank, cell, next_state[i]);
        }
        return _generation += 1;
      };
      this.next = function(steps) {
        var i, _i, _ref, _results;
        _results = [];
        for (i = _i = 0, _ref = steps - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          _results.push(this.step());
        }
        return _results;
      };
    }

    return Lifegame;

  })();

}).call(this);
