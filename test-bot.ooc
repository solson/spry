import spry/[IRC, Commands, Prefix]

main: func {
    bot := IRC new("spry", "spry", "a spry little IRC bot", "irc.ninthbit.net", 6667)

    bot on("send", |irc, cmd|
        ">> " print()
        cmd toString() println()
    )

    bot on("all", |irc, cmd|
        cmd toString() println()
    )

    bot run()
}
