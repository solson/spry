import spry/IRC

main: func {
    bot := IRC new("spry", "spry", "a spry little IRC bot", "localhost", 6667)

    bot on("send", |irc, cmd|
        ">> " print()
        cmd toString() println()
    )

    bot on("all", |irc, cmd|
        cmd toString() println()
    )

    bot on("001", |irc, cmd|
        irc join("#programming")
    )

    bot run()
}
