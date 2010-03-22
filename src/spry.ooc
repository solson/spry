import net/StreamSocket

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
        recieveLoop()
    }

    recieveLoop: func {
        while(reader hasNext()) {
            line := reader readLine()
            line println()
        }
        socket close()
    }
}
