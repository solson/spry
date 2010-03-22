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
        writer write("NICK " + nick + "\r\n" +
                     "USER " + user + " * * :" + realname + "\r\n")
//        writer write("JOIN #ooc-lang\r\n" +
//                     "PRIVMSG #ooc-lang :It's ALIVE!!\r\n")
        recieveLoop()
    }

    recieveLoop: func {
        while(true) {
            if(reader hasNext()) {
                line := reader readLine()
                line println()
            }
        }
        socket close()
    }
}
