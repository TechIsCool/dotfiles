$console = $host.UI.RawUI
$buffer = $console.BufferSize
$buffer.Width = $console.MaxWindowSize.Width
$buffer.Height = 5000

$console.BufferSize = $buffer
$size = $console.WindowSize
$size.Width = $console.MaxWindowSize.Width - 10
$size.Height = 50
$console.WindowSize = $size
