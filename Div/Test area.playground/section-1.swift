
// Easy on the shell commands, the code here is run automatically, and very frequently.

import SwiftShell

let (input,output) = streams()

input.writeln("10.17.14,15:58:00,Magesmerte,Middels,Ut dagen. Spiste noe lell.")
input.writeln("10.14.14,16:49:00,Magesmerte,Middels,\"Spiste skive med brunost , så skive med peanøttsmør og kvart eple. Etter jobb, før trening.\" ")
input.writeln("10.14.14,11:49:28,Drit,Middels,")
input.closeStream()

output.lines() |> map { $0.replace(",","\t",limit: 4) } |> writeTo(standardoutput)
