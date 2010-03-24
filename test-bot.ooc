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
        send(Join new("#spry"))
    }

    onNick: func (cmd: Nick) {
        "%s is now known as %s" format(cmd prefix, cmd nick()) println()
    }

    onChannelMessage: func (cmd: Message) {
        send(Message new(cmd reciever(), "Omg, %s! I can hear you!" format(cmd prefix nick)))
    }

    onJoin: func (cmd: Join) {
        send(Message new(cmd channel(), "Welcome to %s, %s!" format(cmd channel(), cmd prefix nick)))
    }
}

main: func {
    bot := TestBot new("spry", "spry", "a spry little Eye Are See bot", "irc.freenode.net", 6667)
    bot run()
}
