import structs/[List, ArrayList], text/[StringReader, Buffer]
import Prefix

Command: class {
    command: String
    prefix: Prefix
    params: ArrayList<String>

    init: func (=command, =prefix, =params) {}

    init: func ~copy (cmd: This) {
        this prefix = cmd prefix
        this command = cmd command
        this params = cmd params
    }

    new: static func ~fromString (line: String) -> This {
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

        This new(command, prefix, params)
    }

    toString: func -> String {
        b := Buffer new()

        if(prefix) {
            b append(':') .append(prefix full) .append(' ')
        }

        b append(prepare())

        return b toString()
    }

    prepare: func -> String {
        b := Buffer new()

        b append(command)

        last := params lastIndex()
        for(i in 0..params size()) {
            param := params[i]
            b append(' ')
            if(i == last) b append(':')
            b append(param)
        }

        return b toString()
    }
}

Nick: class extends Command {
    init: func ~Nick (nick: String) {
        params := [nick] as ArrayList<String>
        super("NICK", null, params)
    }

    init: func ~copy (cmd: Command) {
        this prefix = cmd prefix
        this command = cmd command
        this params = cmd params
    }

    nick: func -> String {
        params[0]
    }
}

User: class extends Command {
    init: func ~User (user, realname: String) {
        params := [user, "*", "*", realname] as ArrayList<String>
        super("USER", null, params)
    }

    init: func ~copy (cmd: Command) {
        this prefix = cmd prefix
        this command = cmd command
        this params = cmd params
    }

    user: func -> String {
        params[0]
    }

    realname: func -> String {
        params[3]
    }
}

Join: class extends Command {
    init: func ~Join (channel: String) {
        params := [channel] as ArrayList<String>
        super("JOIN", null, params)
    }

    init: func ~JoinMany (channels: ArrayList<String>) {
        params := [channels join(',')] as ArrayList<String>
        super("JOIN", null, params)
    }

    init: func ~copy (cmd: Command) {
        this prefix = cmd prefix
        this command = cmd command
        this params = cmd params
    }

    channel: func -> String {
        params[0]
    }
}

Message: class extends Command {
    init: func ~Privmsg (reciever, message: String) {
        params := [reciever, message] as ArrayList<String>
        super("PRIVMSG", null, params)
    }

    init: func ~copy (cmd: Command) {
        this prefix = cmd prefix
        this command = cmd command
        this params = cmd params
    }

    reciever: func -> String {
        params[0]
    }

    message: func -> String {
        params[1]
    }
}

Ping: class extends Command {
    init: func ~Ping (server: String) {
        params := [server] as ArrayList<String>
        super("PING", null, params)
    }

    init: func ~copy (cmd: Command) {
        this prefix = cmd prefix
        this command = cmd command
        this params = cmd params
    }

    server: func -> String {
        params[0]
    }
}

Pong: class extends Command {
    init: func ~Pong (server: String) {
        params := [server] as ArrayList<String>
        super("PONG", null, params)
    }

    init: func ~copy (cmd: Command) {
        this prefix = cmd prefix
        this command = cmd command
        this params = cmd params
    }

    server: func -> String {
        params[0]
    }
}
