Set-Alias pio "$env:USERPROFILE\.platformio\penv\Scripts\pio.exe"
pio run -t compiledb
pio run -t clean