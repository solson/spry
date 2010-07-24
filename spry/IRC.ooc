import net/StreamSocket, structs/[HashMap, ArrayList]
import Message, Prefix

IRC: class {
    nickname, username, realname, server: String
    port: Int
    socket: StreamSocket
    reader: StreamSocketReader
    writer: StreamSocketWriter
    callbacks := HashMap<String, Func (IRC, Message)> new()

    init: func (=nickname, =username, =realname, =server, =port) {
        socket = StreamSocket new(server, port)
        reader = socket reader()
        writer = socket writer()

        on("PING", |irc, msg|
            irc pong(msg params[0])
        )
    }

    on: func (name: String, fn: Func (IRC, Message)) {
        callbacks put(name, fn)
    }

    runCallback: func (name: String, msg: Message) {
        if(callbacks contains(name))
            callbacks[name](this, msg)
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
        msg := Message new(line)

        runCallback("all", msg)
        runCallback(msg command, msg)
    }

    send: func (msg: Message) {
        runCallback("send", msg)
        writer write(msg toString() + "\r\n")
    }

    /*
     * IRC Messages
     * Refer to <http://tools.ietf.org/html/rfc2812#section-3>
     */

    /*
     * Connection registration
     */
    pass: func (password: String) {
        send(Message new("PASS", [password] as ArrayList<String>))
    }

    nick: func (nickname: String) {
        send(Message new("NICK", [nickname] as ArrayList<String>))
    }

    user: func (username, realname: String) {
        send(Message new("USER", [username, "0", "*", realname] as ArrayList<String>))
    }

    oper: func (name, password: String) {
        send(Message new("OPER", [name, password] as ArrayList<String>))
    }

    userMode: func (modes: String) {
        send(Message new("MODE", [this nickname, modes] as ArrayList<String>))
    }

    quit: func ~withoutMessage {
        send(Message new("QUIT", ArrayList<String> new()))
    }

    quit: func ~withMessage (message: String) {
        send(Message new("QUIT", [message] as ArrayList<String>))
    }
    
    /*
     * Channel operations
     */
    join: func (channel: String) {
        send(Message new("JOIN", [channel] as ArrayList<String>))
    }

    part: func ~withoutMessage (channel: String) {
        send(Message new("PART", [channel] as ArrayList<String>))
    }

    part: func ~withMessage (channel, message: String) {
        send(Message new("PART", [channel, message] as ArrayList<String>))
    }
    
    channelMode: func (channel, modes: String) {
        send(Message new("MODE", [channel, modes] as ArrayList<String>))
    }

    topic: func ~get (channel: String) {
        send(Message new("TOPIC", [channel] as ArrayList<String>))
    }

    topic: func ~set (channel, topic: String) {
        send(Message new("TOPIC", [channel, topic] as ArrayList<String>))
    }

    names: func (channel: String) {
        send(Message new("NAMES", [channel] as ArrayList<String>))
    }

    list: func {
        send(Message new("LIST", ArrayList<String> new()))
    }

    invite: func (nickname, channel: String) {
        send(Message new("INVITE", [nickname, channel] as ArrayList<String>))
    }
    
    kick: func ~withoutComment (channel, user: String) {
        send(Message new("KICK", [channel, user] as ArrayList<String>))
    }
    
    kick: func ~withComment (channel, user, comment: String) {
        send(Message new("KICK", [channel, user, comment] as ArrayList<String>))
    }

    /*
     * Sending messages
     */
    privmsg: func (target, text: String) {
        send(Message new("PRIVMSG", [target, text] as ArrayList<String>))
    }
    
    notice: func (target, text: String) {
        send(Message new("NOTICE", [target, text] as ArrayList<String>))
    }

    /*
     * Server queries and commands
     */
    motd: func {
        send(Message new("MOTD", ArrayList<String> new()))
    }

    lusers: func {
        send(Message new("LUSERS", ArrayList<String> new()))
    }

    version_: func {
        send(Message new("VERSION", ArrayList<String> new()))
    }

    stats: func (query: String) {
        send(Message new("STATS", [query] as ArrayList<String>))
    }

    links: func {
        send(Message new("LINKS", ArrayList<String> new()))
    }

    time: func {
        send(Message new("TIME", ArrayList<String> new()))
    }

    admin: func {
        send(Message new("ADMIN", ArrayList<String> new()))
    }

    info: func {
        send(Message new("INFO", ArrayList<String> new()))
    }

    /*
     * User based queries
     */
    who: func (mask: String) {
        send(Message new("WHO", [mask] as ArrayList<String>))
    }

    whois: func (mask: String) {
        send(Message new("WHOIS", [mask] as ArrayList<String>))
    }

    whowas: func (nickname: String) {
        send(Message new("WHOWAS", [nickname] as ArrayList<String>))
    }

    /*
     * Miscellaneous messages
     */
    kill: func (nickname, comment: String) {
        send(Message new("KILL", [nickname, comment] as ArrayList<String>))
    }
    
    ping: func (server: String) {
        send(Message new("PING", [server] as ArrayList<String>))
    }
    
    pong: func (server: String) {
        send(Message new("PONG", [server] as ArrayList<String>))
    }
}
