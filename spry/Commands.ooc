import structs/[List, ArrayList], text/[StringReader, Buffer]
import IRC, Prefix

Command: class {
    command: String
    prefix: Prefix
    params: ArrayList<String>

    init: func (=command, =prefix, =params) {}

    init: func ~fromString (line: String) {
        reader := StringReader new(line)

        prefix: Prefix

        if(line startsWith(':')) {
            reader skip(1)
            prefix = Prefix new(reader readUntil(' '))
            reader skipWhile(' ')
        } else {
            prefix = null
        }

        command := reader readUntil(' ') toUpper()
        reader skipWhile(' ')

        params := ArrayList<String> new()

        while(reader hasNext()) {
            param: String

            if(reader peek() == ':') {
                param = line substring(reader mark() + 1)
                reader reset(line length())
            } else {
                param = reader readUntil(' ')
                reader skipWhile(' ')
            }

            params add(param)
        }

        this init(command, prefix, params)
    }

    toString: func -> String {
        b := Buffer new()

        if(prefix != null) {
            b append(':') .append(prefix full) .append(' ')
        }

        b append(command)

        last := params lastIndex()
        for(i in 0..params size()) {
            param := params[i]
            b append(' ')
            if(i == last)
                b append(':')
            b append(param)
        }

        b toString()
    }
}
