import net/StreamSocket
import spry/[IRC, Commands, Prefix]

//handleCommand: func (msg: Message) {
//    if(!addressed) return

//    i := commandString indexOf(' ')
//    cmd := commandString[0..i]

//    if(i != -1) i += 1
//    rest := commandString[i..-1]

//    match(cmd) {
//        case "join" =>
//            Join new(this, rest) send()
//        case "ping" =>
//            reply("pong")
//        case "echo" =>
//            reply(rest)
//        case "trigger" =>
//            trigger = rest
//            reply("Done.")
//        case "help" =>
//            reply("ping, echo, trigger, help")
//        case "die" =>
//            if(rest == "   ") exit(0)
//    }
//}

main: func {
    bot := IRC new("spry", "spry", "a spry little IRC bot", "irc.ninthbit.net", 6667, "!")

    bot on("send", |cmd|
        ">> " print()
        cmd toString() println()
    )

    bot on("all", |cmd|
        cmd toString() println()
    )

    bot run()
}
