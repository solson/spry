import net/StreamSocket, structs/[HashMap, ArrayList]
import Commands, Prefix

IRC: class {
    nick, username, realname, server: String
    port: Int
    socket: StreamSocket
    reader: StreamSocketReader
    writer: StreamSocketWriter
    callbacks := HashMap<String, Func (IRC, Command)> new()

    init: func (=nick, =username, =realname, =server, =port) {
        socket = StreamSocket new(server, port)
        reader = socket reader()
        writer = socket writer()

        on("ping", |irc, cmd|
            irc send(Command new("PONG", null, cmd params))
        )
    }

    on: func (name: String, fn: Func (IRC, Command)) {
        callbacks[name] = fn
    }

    runCallback: func (name: String, cmd: Command) {
        if(callbacks contains(name))
            callbacks[name](this, cmd)
    }

    connect: func {
        socket connect()
        send(Command new("NICK", null, [nick] as ArrayList<String>))
        send(Command new("USER", null, [username, "0", "*", realname] as ArrayList<String>))
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

        runCallback("all", cmd)
        runCallback(cmd command, cmd)
    }

    send: func (cmd: Command) {
        runCallback("send", cmd)
        writer write(cmd toString() + "\r\n")
    }

    say: func (to, msg: String) {
        send(Command new("PRIVMSG", null, [to, msg] as ArrayList<String>))
    }
}
