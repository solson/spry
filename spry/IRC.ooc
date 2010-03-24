import net/StreamSocket
import Commands, Prefix

IRC: class {
    nick, user, realname, server: String
    port: Int
    socket: StreamSocket
    reader: StreamSocketReader
    writer: StreamSocketWriter

    // Set whenever a channel command or private message is recieved (Message,
    // Join, Part, Notice, etc). Can be a nick or a channel.
    sayTo: String

    init: func (=nick, =user, =realname, =server, =port) {
        socket = StreamSocket new(server, port)
        reader = socket reader()
        writer = socket writer()
        sayTo = null
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
        sayTo = null
        cmd := Command new(this, line)
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
                if(msg reciever() startsWith('#')) {
                    sayTo = msg channel()
                    onChannelMessage(msg)
                } else {
                    sayTo = msg prefix nick
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

    send: func (cmd: Command) {
        onSend(cmd)
        writer write(cmd toString() + "\r\n")
    }

    say: func (msg: String) {
        if(!sayTo) {
            Exception new(This, "Called say and sayTo was null. (Probably wasn't a private message/notice or channel command.)") throw()
        }
        Message new(this, sayTo, msg) send()
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
