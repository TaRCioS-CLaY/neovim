(require-macros :hibiscus.vim)

(local {: show-info} (require :functions))

(fn recover-position []
  (let [line-position (vim.fn.line "'\"")]
    (when (and (> line-position 1) (<= line-position (vim.fn.line "$")))
      (exec [[:exe "\"normal! g`\\\"\""]]))))

(fn map-q-to-close []
  (map! [n :buffer] :q ":close<CR>"))

(augroup! :_general-settings ; autocmds gerais
          [[FileType] [qf help man] `map-q-to-close]
          [[TextYankPost]
           *
           #(vim.highlight.on_yank {:higroup :Search :timeout 200})]
          ;; [[BufWinEnter]
          ;;  dashboard
          ;;  "setlocal cursorline signcolumn=yes cursorcolumn number"]
          [[FileType] qf #(set! nobuflisted)]
          [[FileType] qf #(map! [n :buffer] :<CR> :<CR>)]
          [[BufReadPost] * `recover-position]
          [[BufEnter FocusGained InsertLeave] * #(set! relativenumber)]
          [[BufLeave FocusLost InsertEnter] * #(set! relativenumber false)])

(augroup! :_git ; autocmd para arquivos do git
          [[FileType] gitcommit "setlocal wrap"]
          [[FileType] [gitcommit octo] "setlocal spell"])

(augroup! :_markdown [[FileType] [markdown txt] "setlocal wrap spell"])

(augroup! :_auto_resize
          ; will cause split windows to be resized evenly if main window is resized
          [[VimResized] * "tabdo wincmd ="])

(fn source-file []
  (let [file-name (vim.fn.expand "%:r")
        config-folder (vim.fn.stdpath :config)
        lua-file (.. config-folder "/" (vim.fn.expand "%:p:.:gs?fnl?lua?"))
        source-file (if (= file-name :init)
                        (.. config-folder :/lua/tangerine_vimrc.lua)
                        lua-file)]
    (exec [[":source " source-file]])
    (show-info (.. "sourced: " source-file) :Source)))

(augroup! :_highlight_end_spaces
          ; Destacar espaços em branco no final do arquivo
          [[VimEnter WinEnter] * #(vim.fn.matchadd :EndSpace "\\s\\+$")])

(augroup! :_config ;autocmd para arquivos de configuração fennel
          [[BufWritePost] *.fnl `source-file])

(augroup! :_qutebrowser [[BufWinEnter]
                         *qutebrowser-editor*
                         #(set! filetype :markdown)])
