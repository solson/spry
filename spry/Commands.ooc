import structs/[List, ArrayList], text/[StringReader, Buffer]
import IRC, Prefix

Command: class {
    irc: IRC
    command: String
    prefix: Prefix
    params: ArrayList<String>

    init: func (=irc, =command, =prefix, =params) {}

    init: func ~copy (cmd: This) {
        this irc = cmd irc
        this prefix = cmd prefix
        this command = cmd command
        this params = cmd params
    }

    new: static func ~fromString (irc: IRC, line: String) -> This {
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

        This new(irc, command, prefix, params)
    }

    toString: func -> String {
        b := Buffer new()

        if(prefix) {
            b append(':') .append(prefix full) .append(' ')
        }

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

    send: func {
        irc send(this)
    }
}

Nick: class extends Command {
    init: func ~Nick (.irc, nick: String) {
        params := [nick] as ArrayList<String>
        super(irc, "NICK", null, params)
    }

    init: func ~copy (cmd: Command) {
        this irc = cmd irc
        this prefix = cmd prefix
        this command = cmd command
        this params = cmd params
    }

    nick: func -> String {
        params[0]
    }
}

User: class extends Command {
    init: func ~User (.irc, user, realname: String) {
        params := [user, "*", "*", realname] as ArrayList<String>
        super(irc, "USER", null, params)
    }

    init: func ~copy (cmd: Command) {
        this irc = cmd irc
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
    init: func ~Join (.irc, channel: String) {
        params := [channel] as ArrayList<String>
        super(irc, "JOIN", null, params)
    }

    init: func ~JoinMany (.irc, channels: ArrayList<String>) {
        params := [channels join(',')] as ArrayList<String>
        super(irc, "JOIN", null, params)
    }

    init: func ~copy (cmd: Command) {
        this irc = cmd irc
        this prefix = cmd prefix
        this command = cmd command
        this params = cmd params
    }

    channel: func -> String {
        params[0]
    }
}

Message: class extends Command {
    init: func ~Privmsg (.irc, reciever, message: String) {
        params := [reciever, message] as ArrayList<String>
        super(irc, "PRIVMSG", null, params)
    }

    init: func ~copy (cmd: Command) {
        this irc = cmd irc
        this prefix = cmd prefix
        this command = cmd command
        this params = cmd params
    }

    reciever: func -> String {
        params[0]
    }

    channel: func -> String {
        params[0]
    }

    message: func -> String {
        params[1]
    }
}

Ping: class extends Command {
    init: func ~Ping (.irc, server: String) {
        params := [server] as ArrayList<String>
        super(irc, "PING", null, params)
    }

    init: func ~copy (cmd: Command) {
        this irc = cmd irc
        this prefix = cmd prefix
        this command = cmd command
        this params = cmd params
    }

    server: func -> String {
        params[0]
    }
}

Pong: class extends Command {
    init: func ~Pong (.irc, server: String) {
        params := [server] as ArrayList<String>
        super(irc, "PONG", null, params)
    }

    init: func ~copy (cmd: Command) {
        this irc = cmd irc
        this prefix = cmd prefix
        this command = cmd command
        this params = cmd params
    }

    server: func -> String {
        params[0]
    }
}
