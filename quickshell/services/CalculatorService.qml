// services/CalculatorService.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property var constants: ({ pi: Math.PI, e: Math.E, tau: 2 * Math.PI })
    readonly property var functions: ({
        sqrt: Math.sqrt, cbrt: Math.cbrt, abs: Math.abs,
        sin: Math.sin, cos: Math.cos, tan: Math.tan,
        asin: Math.asin, acos: Math.acos, atan: Math.atan,
        ln: Math.log, log: Math.log10, log2: Math.log2,
        exp: Math.exp, round: Math.round, floor: Math.floor, ceil: Math.ceil
    })

    function _has(obj, key) {
        return Object.prototype.hasOwnProperty.call(obj, key)
    }

    // Returns { value, text } for a valid calculation, or null when the
    // input isn't one (plain text, a bare number, incomplete or invalid).
    function evaluate(input) {
        if (!input) return null
        var src = String(input).toLowerCase()
            .replace(/×/g, "*").replace(/÷/g, "/")
            .replace(/=\s*$/, "").trim()
        if (src.length === 0 || src.length > 120) return null

        var pos = 0
        var usedOp = false

        function skipSpace() {
            while (pos < src.length && src.charAt(pos) === " ") pos++
        }
        function peek() {
            skipSpace()
            return src.charAt(pos)
        }
        function expect(ch) {
            if (peek() !== ch) throw "parse"
            pos++
        }

        function parseExpr() {
            var v = parseTerm()
            for (;;) {
                var c = peek()
                if (c === "+") { pos++; v += parseTerm(); usedOp = true }
                else if (c === "-") { pos++; v -= parseTerm(); usedOp = true }
                else return v
            }
        }

        function parseTerm() {
            var v = parseUnary()
            for (;;) {
                var c = peek()
                if (c === "*") { pos++; v *= parseUnary(); usedOp = true }
                else if (c === "/") { pos++; v /= parseUnary(); usedOp = true }
                else if (c === "%") { pos++; v %= parseUnary(); usedOp = true }
                else return v
            }
        }

        function parseUnary() {
            var c = peek()
            if (c === "-") { pos++; return -parseUnary() }
            if (c === "+") { pos++; return parseUnary() }
            return parsePower()
        }

        // Right-associative: 2^3^2 = 2^(3^2). "**" is accepted as "^".
        function parsePower() {
            var base = parsePrimary()
            var c = peek()
            if (c === "^" || (c === "*" && src.charAt(pos + 1) === "*")) {
                pos += (c === "^") ? 1 : 2
                usedOp = true
                return Math.pow(base, parseUnary())
            }
            return base
        }

        function parsePrimary() {
            var c = peek()

            if (c === "(") {
                pos++
                var inner = parseExpr()
                expect(")")
                return inner
            }

            var rest = src.slice(pos)

            var num = /^(\d+\.?\d*|\.\d+)(e[+-]?\d+)?/.exec(rest)
            if (num) {
                pos += num[0].length
                return parseFloat(num[0])
            }

            var idm = /^[a-z_][a-z0-9_]*/.exec(rest)
            if (idm) {
                var id = idm[0]
                pos += id.length
                if (peek() === "(" && _has(root.functions, id)) {
                    pos++
                    var arg = parseExpr()
                    expect(")")
                    usedOp = true
                    return root.functions[id](arg)
                }
                if (_has(root.constants, id)) return root.constants[id]
            }

            throw "parse"
        }

        var result
        try {
            result = parseExpr()
            skipSpace()
            if (pos !== src.length) return null
        } catch (e) {
            return null
        }

        if (!usedOp || typeof result !== "number" || !isFinite(result)) return null

        var rounded = Number(result.toPrecision(12))   // 0.1 + 0.2 -> 0.3
        if (rounded === 0) rounded = 0                 // no "-0"
        return { value: rounded, text: String(rounded) }
    }

    Process {
        id: copyProc
        property string payload: ""
        command: ["wl-copy", payload]
    }

    function copy(text) {
        if (!text) return
        copyProc.payload = text
        copyProc.running = false
        copyProc.running = true
    }
}