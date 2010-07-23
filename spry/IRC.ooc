import net/StreamSocket, structs/[HashMap, ArrayList]
import Command, Prefix

IRC: class {
    nickname, username, realname, server: String
    port: Int
    socket: StreamSocket
    reader: StreamSocketReader
    writer: StreamSocketWriter
    callbacks := HashMap<String, Func (IRC, Command)> new()

    init: func (=nickname, =username, =realname, =server, =port) {
        socket = StreamSocket new(server, port)
        reader = socket reader()
        writer = socket writer()

        on("PING", |irc, cmd|
            irc pong(cmd params[0])
        )
    }

    on: func (name: String, fn: Func (IRC, Command)) {
        callbacks put(name, fn)
    }

    runCallback: func (name: String, cmd: Command) {
        if(callbacks contains(name))
            callbacks[name](this, cmd)
    }

    connect: func {
        socket connect()
        nick(nickname)
        user(username, realname)
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

    /*
     * Connection registration
     */
    // pass

    nick: func (nickname: String) {
        send(Command new("NICK", [nickname] as ArrayList<String>))
    }

    user: func (username, realname: String) {
        send(Command new("USER", [username, "0", "*", realname] as ArrayList<String>))
    }

    // oper

    // user mode

    // service

    // quit

    // squit
    
    /*
     * Channel operations
     */
    join: func (channel: String) {
        send(Command new("JOIN", [channel] as ArrayList<String>))
    }

    // part

    // channel mode

    // topic

    // names

    // list

    // invite

    // kick

    /*
     * Sending messages
     */
    privmsg: func (to, msg: String) {
        send(Command new("PRIVMSG", [to, msg] as ArrayList<String>))
    }

    // notice

    /*
     * Server queries and commands
     */
    // motd

    // lusers

    // version

    // stats

    // links

    // time

    // connect

    // trace

    // admin

    // info

    /*
     * Service queries and commands
     */
    // servlist

    // squery

    /*
     * User based queries
     */
    // who

    // whois

    // whowas

    /*
     * Miscellaneous messages
     */
    // kill

    // ping
    
    pong: func (server: String) {
        send(Command new("PONG", [server] as ArrayList<String>))
    }

    // error
}
