import structs/[List, ArrayList], text/[StringReader, Buffer]
import IRC, Prefix

Message: class {
    command: String
    prefix: Prefix
    params: ArrayList<String>

    init: func (=command, =prefix, =params) {}

    init: func ~withoutPrefix (=command, =params) { prefix = null }

    init: func ~fromString (line: String) {
        reader := StringReader new(line)

        // If the line begins with a colon it has a prefix.
        if(line startsWith?(':')) {
            // Skip the colon.
            reader skip(1)
            // Everything up until the next space is the prefix.
            this prefix = Prefix new(reader readUntil(' '))
        } else {
            this prefix = null
        }

        // The first word (or first word after the prefix) is the command.
        this command = reader readUntil(' ') toUpper()

        this params = ArrayList<String> new()

        while(reader hasNext?()) {
            param: String

            // A param beginning with a colon extends to the end of
            // the line and can include spaces. Note that this kind of
            // parameter is not stored differently, it is just a
            // syntactic trick to allow spaces in parameters.
            if(reader peek() == ':') {
                // The param is the rest of the line after the colon.
                param = line substring(reader mark() + 1)
                // Set the reader position to the end.
                reader reset(line length())
            } else {
                // A param is a string of non-whitespace characters.
                param = reader readUntil(' ')
            }

            this params add(param)
        }
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
