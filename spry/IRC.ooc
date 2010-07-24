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
     * IRC Messages
     * Refer to <http://tools.ietf.org/html/rfc2812#section-3>
     */

    /*
     * Connection registration
     */
    pass: func (password: String) {
        send(Command new("PASS", [password] as ArrayList<String>))
    }

    nick: func (nickname: String) {
        send(Command new("NICK", [nickname] as ArrayList<String>))
    }

    user: func (username, realname: String) {
        send(Command new("USER", [username, "0", "*", realname] as ArrayList<String>))
    }

    oper: func (name, password: String) {
        send(Command new("OPER", [name, password] as ArrayList<String>))
    }

    userMode: func (modes: String) {
        send(Command new("MODE", [this nickname, modes] as ArrayList<String>))
    }

    quit: func ~withoutMessage {
        send(Command new("QUIT", ArrayList<String> new()))
    }

    quit: func ~withMessage (message: String) {
        send(Command new("QUIT", [message] as ArrayList<String>))
    }
    
    /*
     * Channel operations
     */
    join: func (channel: String) {
        send(Command new("JOIN", [channel] as ArrayList<String>))
    }

    part: func ~withoutMessage (channel: String) {
        send(Command new("PART", [channel] as ArrayList<String>))
    }

    part: func ~withMessage (channel, message: String) {
        send(Command new("PART", [channel, message] as ArrayList<String>))
    }
    
    channelMode: func (channel, modes: String) {
        send(Command new("MODE", [channel, modes] as ArrayList<String>))
    }

    topic: func ~get (channel: String) {
        send(Command new("TOPIC", [channel] as ArrayList<String>))
    }

    topic: func ~set (channel, topic: String) {
        send(Command new("TOPIC", [channel, topic] as ArrayList<String>))
    }

    names: func (channel: String) {
        send(Command new("NAMES", [channel] as ArrayList<String>))
    }

    list: func {
        send(Command new("LIST", ArrayList<String> new()))
    }

    invite: func (nickname, channel: String) {
        send(Command new("INVITE", [nickname, channel] as ArrayList<String>))
    }
    
    kick: func ~withoutComment (channel, user: String) {
        send(Command new("KICK", [channel, user] as ArrayList<String>))
    }
    
    kick: func ~withComment (channel, user, comment: String) {
        send(Command new("KICK", [channel, user, comment] as ArrayList<String>))
    }

    /*
     * Sending messages
     */
    privmsg: func (target, text: String) {
        send(Command new("PRIVMSG", [target, text] as ArrayList<String>))
    }
    
    notice: func (target, text: String) {
        send(Command new("NOTICE", [target, text] as ArrayList<String>))
    }

    /*
     * Server queries and commands
     */
    motd: func {
        send(Command new("MOTD", ArrayList<String> new()))
    }

    lusers: func {
        send(Command new("LUSERS", ArrayList<String> new()))
    }

    version_: func {
        send(Command new("VERSION", ArrayList<String> new()))
    }

    stats: func (query: String) {
        send(Command new("STATS", [query] as ArrayList<String>))
    }

    links: func {
        send(Command new("LINKS", ArrayList<String> new()))
    }

    time: func {
        send(Command new("TIME", ArrayList<String> new()))
    }

    admin: func {
        send(Command new("ADMIN", ArrayList<String> new()))
    }

    info: func {
        send(Command new("INFO", ArrayList<String> new()))
    }

    /*
     * User based queries
     */
    who: func (mask: String) {
        send(Command new("WHO", [mask] as ArrayList<String>))
    }

    whois: func (mask: String) {
        send(Command new("WHOIS", [mask] as ArrayList<String>))
    }

    whowas: func (nickname: String) {
        send(Command new("WHOWAS", [nickname] as ArrayList<String>))
    }

    /*
     * Miscellaneous messages
     */
    kill: func (nickname, comment: String) {
        send(Command new("KILL", [nickname, comment] as ArrayList<String>))
    }
    
    ping: func (server: String) {
        send(Command new("PING", [server] as ArrayList<String>))
    }
    
    pong: func (server: String) {
        send(Command new("PONG", [server] as ArrayList<String>))
    }
}
