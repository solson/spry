import net/StreamSocket
import Commands, Prefix

IRC: class {
    nick, user, realname, server: String
    port: Int
    socket: StreamSocket
    reader: StreamSocketReader
    writer: StreamSocketWriter

    init: func (=nick, =user, =realname, =server, =port) {
        socket = StreamSocket new(server, port)
        reader = socket reader()
        writer = socket writer()
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
        cmd := Command new(line)
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
                    onChannelMessage(msg)
                } else {
                    onPrivateMessage(msg)
                }
            case "JOIN" =>
                onJoin(Join new(cmd))
            case =>
                onUnhandled(cmd)
        }
    }

    send: func (cmd: Command) {
        onSend(cmd)
        writer write(cmd toString() + "\r\n")
    }

    // Callbacks
    onConnect: func {
        send(Nick new(nick))
        send(User new(user, realname))
    }

    onSend: func (cmd: Command) {}

    onAll: func (cmd: Command) {}

    onPing: func (cmd: Ping) {
        send(Pong new(cmd server()))
    }

    onPong: func (cmd: Pong) {}

    onNick: func (cmd: Nick) {}

    onChannelMessage: func (cmd: Message) {}

    onPrivateMessage: func (cmd: Message) {}

    onJoin: func (cmd: Join) {}

    onUnhandled: func (cmd: Command) {}
}
