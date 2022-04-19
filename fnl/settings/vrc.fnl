(require-macros :hibiscus.vim)

; Opções para o vim-rest-console
(g! vrc_curl_opts {:-sS "" :--connect-timeout 10 :-i "" :--max-time 60 :-k ""})

; -- Formatar resposta em JSON
(g! vrc_auto_format_response_patterns {:json "python3 -m json.tool"})

; --  Permitir que parâmetros GET sejam declarados em linhas sequenciais
(g! vrc_split_request_body 0)
