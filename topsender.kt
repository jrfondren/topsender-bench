import java.io.File

fun main() {
    var senders = hashMapOf<String, Int>()
    val re = "^(?:\\S+ ){3,4}<= ([^ @]+@(\\S+))".toRegex()

    val file = File("exim_mainlog")
    file.forEachLine {
        val matches = re.find(it)
        if (matches != null) {
            val sender = matches.groupValues[1]
            val count = senders.getOrElse(sender) { 0 }
            senders[sender] = count+1
        }
    }

    senders.keys.sortedByDescending { senders[it] }.take(5).forEach {
        println("%5d %s".format(senders[it], it))
    }
}
