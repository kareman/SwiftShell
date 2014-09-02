
import SwiftShell

run("echo this is streamed") |> run("wc -w") |> standardoutput 

run("ls") //|> standardoutput 
