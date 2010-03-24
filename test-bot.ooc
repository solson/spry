import net/StreamSocket, structs/ArrayList, text/StringTokenizer
import spry/[IRC, Commands, Prefix]

TestBot: class extends IRC {
    init: func ~TestBot (=nick, =user, =realname, =server, =port) {
        socket = StreamSocket new(server, port)
        reader = socket reader()
        writer = socket writer()
    }

    onConnect: func {
        super onConnect()
        Join new(this, "#spry,#ooc-lang") send()
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

    onJoin: func (cmd: Join) {
        if(cmd prefix nick != this nick)
            cmd respond("Welcome to %s, %s!" format(cmd channel(), cmd prefix nick))
    }

    onChannelMessage: func (cmd: Message) {
        handleCommand(cmd)
    }

    onPrivateMessage: func (cmd: Message) {
        handleCommand(cmd)
    }

    handleCommand: func (cmd: Message) {
        msg := cmd message()
        if(!msg startsWith('!')) return

        msgParts := msg[1..-1] split(' ', 1) toArrayList()

        match(msgParts[0]) {
            case "ping" =>
                cmd respond(cmd prefix nick + ": pong")
            case "echo" =>
                cmd respond("%s: %s" format(cmd prefix nick, msgParts[1]))
        }
    }
}

main: func {
    bot := TestBot new("spry", "spry", "a spry little Eye Are See bot", "irc.freenode.net", 6667)
    bot run()
}
