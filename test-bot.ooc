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

//    onJoin: func (cmd: Join) {
//        if(cmd prefix nick != this nick)
//            say("Welcome to %s, %s!" format(cmd channel(), cmd prefix nick))
//    }

    onChannelMessage: func (cmd: Message) {
        handleCommand(cmd)
    }

    onPrivateMessage: func (cmd: Message) {
        handleCommand(cmd)
    }

    handleCommand: func (msg: Message) {
        msgStr := msg message()
        if(!msgStr startsWith('!')) return

        i := msgStr indexOf(' ')
        cmd := msgStr[1..i]
        rest := msgStr[(i + 1)..-1]

        match(cmd) {
            case "ping" =>
                say(msg prefix nick + ": pong")
            case "echo" =>
                say("%s: %s" format(msg prefix nick, rest))
        }
    }
}

main: func {
    bot := TestBot new("spry", "spry", "a spry little Eye Are See bot", "irc.freenode.net", 6667)
    bot run()
}
