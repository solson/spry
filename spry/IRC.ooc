import net/StreamSocket
import Commands, Prefix

IRC: class {
    nick, user, realname, server: String
    port: Int
    socket: StreamSocket
    reader: StreamSocketReader
    writer: StreamSocketWriter

    // A string to use at the beginning of commands ("!", as in !ping, !echo)
    trigger: String

    // Set whenever a channel command or private message is recieved (Message,
    // Join, Part, Notice, etc). Can be a nick or a channel.
    sayTo: String

    // Set whenever a command performed by another user is recived
    senderPrefix: Prefix

    // Set when a message matches the trigger or the bot nick
    addressed: Bool

    // Set when the bot is `addressed` to the string after the trigger/nickname
    commandString: String

    init: func (=nick, =user, =realname, =server, =port, =trigger) {
        socket = StreamSocket new(server, port)
        reader = socket reader()
        writer = socket writer()
        sayTo = null
        senderPrefix = null
        addressed = false
        commandString = false
    }

    connect: func {
        socket connect()
        onConnect()
    }

    run: func {
        connect()
        while(true) {
            if(reader hasNext()) {
                line := reader readLine()
                handleLine(line)
            }
        }
        socket close()
    }

    handleLine: func (line: String) {
        this sayTo = null

        cmd := Command new(this, line)
        if(cmd prefix) {
            this senderPrefix = cmd prefix
        }

        onAll(cmd)
        match(cmd command) {
            case "PING" =>
                onPing(Ping new(cmd))
            case "PONG" =>
                onPong(Pong new(cmd))
            case "NICK" =>
                onNick(Nick new(cmd))
            case "PRIVMSG" =>
                msg := Message new(cmd)
                checkAddressed(msg)
                if(msg inChannel()) {
                    this sayTo = msg channel()
                    onChannelMessage(msg)
                } else {
                    this sayTo = msg prefix nick
                    onPrivateMessage(msg)
                }
            case "JOIN" =>
                joinCmd := Join new(cmd)
                sayTo = joinCmd channel()
                onJoin(joinCmd)
            case =>
                onUnhandled(cmd)
        }
    }

    checkAddressed: func (msg: Message) {
        addressed = false
        commandString = null
        msgStr := msg message()
        if(msg inChannel()) {
            if(this trigger && msgStr startsWith(this trigger)) {
                addressed = true
                commandString = msgStr substring(this trigger length())
            } else if(msgStr startsWith(this nick + ": ")) {
                addressed = true
                commandString = msgStr substring(this nick length() + 2)
            }
        } else {
            addressed = true
            if(this trigger && msgStr startsWith(this trigger)) {
                commandString = msgStr substring(this trigger length())
            } else {
                commandString = msgStr clone()
            }
        }
    }

    send: func (cmd: Command) {
        onSend(cmd)
        writer write(cmd toString() + "\r\n")
    }

    say: func (msg: String) {
        if(!this sayTo) {
            Exception new(This, "Called say and sayTo was null. (Probably wasn't a private message/notice or channel command.)") throw()
        }

        say(this sayTo, msg)
    }

    say: func ~to (to, msg: String) {
        Message new(this, to, msg) send()
    }

    reply: func (msg: String) {
        if(!this senderPrefix) {
            Exception new(This, "Called reply and senderPrefix was null. (The command didn't have a prefix.)") throw()
        }

        if(this sayTo && this sayTo startsWith('#')) {
            say("%s: %s" format(this senderPrefix nick, msg))
        } else {
            say(msg)
        }
    }

    // Callbacks
    onConnect: func {
        Nick new(this, nick) send()
        User new(this, user, realname) send()
    }

    onSend: func (cmd: Command) {}

    onAll: func (cmd: Command) {}

    onPing: func (cmd: Ping) {
        Pong new(this, cmd server()) send()
    }

    onPong: func (cmd: Pong) {}

    onNick: func (cmd: Nick) {}

    onChannelMessage: func (cmd: Message) {}

    onPrivateMessage: func (cmd: Message) {}

    onJoin: func (cmd: Join) {}

    onUnhandled: func (cmd: Command) {}
}
