;extends

; This isn't perfect
; - escaped quotes in the string_content will break it.
; - dollarsigns in the string_content will break it.
(command
  name: (command_name) @injection.language
	(#eq? @injection.language "jq")
	argument: (string
    (string_content) @injection.content
	)
)

