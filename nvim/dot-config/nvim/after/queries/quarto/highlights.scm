; extends 

(paragraph 
  (inline) @text
  (#match? @text "(\[.*?)?@[A-z0-9]+(; @[A-z0-9]+)*\]?")
) @citation
