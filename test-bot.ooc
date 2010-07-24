import spry/[IRC, Message, Prefix]
import structs/ArrayList, text/[Buffer, StringTokenizer]

main: func {
    bot := IRC new("spry", "spry", "a spry little IRC bot", "localhost", 6667)

    bot on("send", |irc, msg|
        ">> " print()
        msg toString() println()
    )

    bot on("all", |irc, msg|
        msg toString() println()
    )

    bot on("001", |irc, msg|
        irc join("#programming")
    )

    bot on("PRIVMSG", |irc, msg|
        target := msg params[0]
        if(target startsWith('#'))
            irc runCallback("channel message", msg)
        else
            irc runCallback("private message", msg)
    )

    bot on("channel message", |irc, msg|
        channel := msg params[0]
        if(msg params[1] startsWith('!')) {
            words := msg params[1][1..-1] split(' ')
            first := words nextToken()
            match first {
                case "channels" =>
                    buf := Buffer new()
                    for(c in irc channels)
                        buf append(c) .append(' ')
                    irc privmsg(channel, msg prefix nick + ": " + buf toString())
                case "ping" =>
                    irc privmsg(channel, msg prefix nick + ": pong")
                case "join" =>
                    chan := words nextToken()
                    if(irc channels contains(chan)) {
                        irc privmsg(channel, msg prefix nick + ": I'm already in " + chan + ".")
                    } else {
                        irc join(chan)
                        irc privmsg(channel, msg prefix nick + ": Consider it done.")
                    }
                case "part" =>
                    chan := words nextToken()
                    if(irc channels contains(chan)) {
                        irc part(chan)
                        irc privmsg(channel, msg prefix nick + ": Consider it done.")
                    } else {
                        irc privmsg(channel, msg prefix nick + ": I'm not in " + chan + ".")
                    }
            }
        }
    )

    bot run()
}
