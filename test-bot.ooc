import net/StreamSocket
import spry/[IRC, Commands, Prefix]

TestBot: class extends IRC {
    init: func ~TestBot (=nick, =user, =realname, =server, =port) {
        socket = StreamSocket new(server, port)
        reader = socket reader()
        writer = socket writer()
    }

    onConnect: func {
        super onConnect()
        send(Join new("#spry,#ooc-lang"))
    }

    onSend: func (cmd: Command) {
        ">> " print()
        cmd toString() println()
    }

    onAll: func (cmd: Command) {
        cmd toString() println()
    }

    onNick: func (cmd: Nick) {
        "%s is now known as %s" format(cmd prefix, cmd nick()) println()
    }

    onChannelMessage: func (cmd: Message) {
        match(cmd message()) {
            case "!ping" =>
                respond(cmd, cmd prefix nick + ": pong")
        }
    }

    onJoin: func (cmd: Join) {
        if(cmd prefix nick != this nick)
            respond(cmd, "Welcome to %s, %s!" format(cmd channel(), cmd prefix nick))
    }
}

main: func {
    bot := TestBot new("spry", "spry", "a spry little Eye Are See bot", "irc.freenode.net", 6667)
    bot run()
}
