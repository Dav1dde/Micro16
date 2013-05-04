CodeMirror.defineMode("micro16", function(config, parserConfig) {
        var keywords = ['GOTO', 'IF'];

        return {
                token: function(stream, state) {
                        if (stream.eatSpace()) {
                                return null;
                        }

                        var ch = stream.next();


                        if(ch == ';') { stream.skipToEnd(); return "comment" }
                        if(ch == '<' && stream.peek() == '-') { stream.eat(/-/); return "special" }
                        if(/[&+~]/.test(ch)) { stream.eatWhile(/[&+~]/); return "operator"; }
                        if(/[\d]/.test(ch)) { stream.eatWhile(/\d/); return "number" }
                        if(/[\.:]/.test(ch)) { stream.eatWhile(/[\.\w:]/); return "label" }

                        stream.eatWhile(/[\w]/)
                        current = stream.current().toUpperCase();

                        if(/R10/.test(current)) { stream.eat(/R10/); return "register" }
                        if(/R\d|PC|AC|MAR|MBR|0|-?1/.test(current)) { stream.eat(/R\d|PC|AC|MAR|MBR|0|-?1/); return "register" }
                        if($.inArray(current, keywords) >= 0) { return "keyword" }


                        return "nothing";
                }
        };
});