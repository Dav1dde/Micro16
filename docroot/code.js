define('/main', function(exports, require) {
  var Main, Parser;
  Parser = require('parser');
  Main = (function() {

    function Main() {
      var _this = this;
      this.parser = new Parser();
      $("#parse").click(function() {
        return _this.parser.parse($("#code").val());
      });
    }

    return Main;

  })();
  $(function() {
    var main;
    return main = new Main;
  });
  return exports;
});

define('/parser', function(exports, require) {
  var ALU_RE, GOTO_RE, LABEL_RE, Parser, READ_REGISTER, REGISTER_RE, WRITE_REGISTER, contains, trim;
  trim = function(s) {
    return (s || "").replace(/^\s+|\s+$/g, "");
  };
  contains = function(value, array) {
    return $.inArray(value, array) >= 0;
  };
  WRITE_REGISTER = ["PC", "R0", "R1", "R2", "R3", "R4", "R5", "R6", "R7", "R8", "R9", "R10", "AC", "MAR", "MBR"];
  READ_REGISTER = ["0", "1", "-1"] + WRITE_REGISTER;
  LABEL_RE = /:(\w+)$/;
  REGISTER_RE = /(R10|R\d|PC|AC|MAR|MBR)/;
  ALU_RE = /(lsh|rsh\()?\(?(~)?(R10|R\d|PC|AC|MBR|\-?1|0)([+,&])?\(?(R10|R\d|PC|AC|MBR|\-?1|0)?\)?\)?/;
  GOTO_RE = /^(?:if\s+(N|Z))\s+goto\s+(\d+|\.[a-zA-Z]\w+)$/;
  exports = Parser = (function() {

    function Parser() {
      this.lines = [];
      this.parsedLines = [];
      this.label = {};
    }

    Parser.prototype.parse = function(text) {
      var line,
        _this = this;
      line = null;
      $.each(text.split('\n'), function(i, line) {
        var element, elements, ins, label, origLine, tmp, _i, _j, _len, _len1, _ref;
        origLine = line;
        line = trim(line.replace(/#.*/g, ""));
        if (line.length === 0) {
          _this.parsedLines.push({});
          return;
        }
        if (LABEL_RE.test(line)) {
          label = LABEL_RE.match(line);
          line = LABEL_RE.replace("");
          _this.label[label[1]] = i;
        }
        elements = [];
        _ref = line.split(";");
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          element = _ref[_i];
          elements.push(trim(element));
        }
        ins = {};
        for (_j = 0, _len1 = elements.length; _j < _len1; _j++) {
          element = elements[_j];
          tmp = (function() {
            switch (false) {
              case !/<-/.test(element):
                return this.parse_load(element, line);
              case !/^(rd|wr)$/.test(line):
                return {
                  memready: true
                };
              case !/(rd|wr)/.test(element):
                return this.parse_rdwr(element, line);
              case !GOTO_RE.test(element):
                return this.parse_goto(element, line);
              case !ALU_RE.test(element):
                return this.parse_alu(element, line);
              default:
                throw {
                  name: "SyntaxError",
                  message: "SyntaxError at line: " + i,
                  line: i
                };
            }
          }).call(_this);
          $.extend(ins, tmp);
        }
        _this.lines.push(origLine);
        return _this.parsedLines.push(ins);
      });
      return console.log(this.parsedLines);
    };

    Parser.prototype.parse_load = function(element, line) {
      var alu, s, write;
      s = element.split(/<-/);
      if (s.length !== 2) {
        throw {
          name: "SyntaxError",
          message: "More than one <- found",
          line: line
        };
      }
      write = s[0];
      if (!contains(write, WRITE_REGISTER)) {
        throw {
          name: "SyntaxError",
          message: "Unknown register",
          line: line
        };
      }
      alu = this.parse_alu(s[1]);
      alu["alu"]["S"] = write;
      return alu;
    };

    Parser.prototype.parse_alu = function(element, line) {
      var alu, alu_op, shift;
      alu = element.match(ALU_RE);
      if (!alu) {
        throw {
          name: "SyntaxError",
          message: "Unable to parse expression",
          line: line
        };
      }
      if (alu[2] && (alu[4] || alu[5])) {
        throw {
          name: "SyntaxError",
          message: "Only one operation allowed",
          line: line
        };
      }
      shift = alu[1] ? alu[1].toUpperCase() : void 0;
      alu_op = alu[2] ? alu[2] : alu[4];
      alu_op = alu_op ? alu_op : "=";
      if (contains(alu_op, ["&", "+"]) && !alu[5]) {
        throw {
          name: "SyntaxError",
          message: "Need seconds register",
          line: line
        };
      }
      return {
        alu: {
          A: alu[3],
          B: alu[5],
          op: alu_op
        },
        shift: shift
      };
    };

    Parser.prototype.parse_goto = function(element, line) {
      var g;
      g = element.match(GOTO_RE);
      if (!g) {
        throw {
          name: "SyntaxError",
          message: "Malformed goto",
          line: line
        };
      }
      return {
        target: g[2],
        condition: g[1]
      };
    };

    Parser.prototype.parse_rdwr = function(element, line) {
      return {
        loadmem: true
      };
    };

    return Parser;

  })();
  return exports;
});
