(import-macros {: g!} :hibiscus.vim)
(local {: requireAnd : has-files-dirs?} (require :functions))

(λ prefixed-keys [mappings prefix]
  (icollect [_ {1 keys 2 cmd &as map-options} (ipairs mappings)]
    (vim.tbl_extend :keep [(.. prefix keys) cmd] map-options)))

(local plugins [;; Fennel
                {1 :udayvir-singh/tangerine.nvim :priority 1001 :lazy false}
                :udayvir-singh/hibiscus.nvim
                {1 :gpanders/editorconfig.nvim
                 :event :BufReadPost
                 :cond #(has-files-dirs? [:.editorconfig])
                 :init #(g! :EditorConfig_exclude_patterns ["fugitive://.*"])}
                {1 :Olical/conjure
                 :dependencies [:Olical/aniseed]
                 :ft :fennel
                 :init #(g! "conjure#mapping#doc_word" :K)}
                {1 :rlane/pounce.nvim
                 :config true
                 :keys [[:s :<cmd>Pounce<CR>]]}
                {1 :unblevable/quick-scope :event :VeryLazy}
                ;; Temas
                {1 :projekt0n/github-nvim-theme :priority 1000 :branch :0.0.x}
                {1 :ellisonleao/gruvbox.nvim
                 :lazy true
                 :init (fn []
                         (g! :gruvbox_italic 1)
                         (g! :gruvbox_sign_column :bg0))}
                ;; Git
                {1 :tpope/vim-fugitive
                 :cmd [:G :Git]
                 :keys (prefixed-keys [{1 :ba
                                        2 "<cmd>Git blame<CR>"
                                        :desc "Todos (all)"}
                                       {1 :c
                                        2 "<cmd>Git commit<CR>"
                                        :desc :Commit}
                                       {1 :d 2 :<cmd>Gdiff<CR> :desc :Diff}
                                       {1 :g 2 "<cmd>G log<CR>" :desc :Log}
                                       {1 :l
                                        2 "<cmd>Git pull --rebase<CR> "
                                        :desc :Pull}
                                       {1 :p
                                        2 "<cmd>Git -c push.default=current push<CR>"
                                        :desc :Push}
                                       {1 :s 2 :<cmd>Git<CR> :desc :Status}
                                       {1 :w
                                        2 :<cmd>Gwrite<CR>
                                        :desc "Salvar e adicionar ao stage"}]
                                      :<leader>g)}
                ;; Interface
                ; Linhas de identação
                {1 :lukas-reineke/indent-blankline.nvim
                 :event :BufReadPre
                 :opts {:show_current_context true}
                 :init #(g! :indent_blankline_filetype_exclude
                            [:dashboard :lsp-installer ""])}
                ; Erros na linha abaixo
                {:url "https://git.sr.ht/~whynothugo/lsp_lines.nvim"
                 :event :BufReadPost
                 :config true}
                ; Destaque na palavra sob o cursor
                {1 :RRethy/vim-illuminate :event :BufReadPost}
                ;; Autocompletar
                {1 :github/copilot.vim
                 :event :InsertEnter
                 :init (fn []
                         (vim.keymap.set :i :<C-q>
                                         "copilot#Accept(\"\\<C-q>\")"
                                         {:remap true
                                          :silent true
                                          :script true
                                          :expr true
                                          :replace_keycodes false})
                         (g! :copilot_no_tab_map true))}
                {1 :windwp/nvim-autopairs :event :InsertEnter :config true}
                ;; Outros
                ; Comentar código
                {1 :numToStr/Comment.nvim
                 :config true
                 :keys [:gc {1 :gc :mode :v}]}
                ; Emmet
                {1 :mattn/emmet-vim
                 :keys [{1 "<C-g>," :mode :i}]
                 :init (fn []
                         (g! :user_emmet_mode :iv)
                         (g! :user_emmet_leader_key :<C-g>))}
                ; Ações com pares
                {1 :kylechui/nvim-surround :event :VeryLazy :config true}
                ; Objetos de texto adicionais
                {1 :wellle/targets.vim :event :VeryLazy}
                ; Explorador de arquivos
                {1 :kyazdani42/nvim-tree.lua
                 :dependencies [:kyazdani42/nvim-web-devicons]
                 :opts {:git {:ignore false}}
                 :keys [[:<F3> :<cmd>NvimTreeToggle<CR>]
                        [:<F2> :<cmd>NvimTreeFindFile<CR>]]}
                ; Múltiplos cursores
                {1 :mg979/vim-visual-multi
                 :branch :master
                 :keys [:<c-g> :<c-t>]
                 :init (fn []
                         (g! :VM_maps
                             {"Find Under" :<C-t>
                              "Find Subword Under" ""
                              "Add Cursor Down" :<C-g>
                              "Add Cursor Up" ""})
                         (g! :VM_Mono_hl :DiffText))}
                ; Animais andando pelo código
                {1 :tamton-aquib/duck.nvim :lazy true}
                ; Usar Neovim em campos de text do navegador
                {1 :glacambre/firenvim
                 :event :VeryLazy
                 :build #(vim.fn.firenvim#install 0)}
                ; ChatGPT
                {1 :jackMort/ChatGPT.nvim
                 :dependencies [:MunifTanjim/nui.nvim
                                :nvim-lua/plenary.nvim
                                :nvim-telescope/telescope.nvim]
                 :keys (prefixed-keys [{1 :a
                                        2 :<cmd>ChatGPTActAs<CR>
                                        :desc "Agir como..."}
                                       {1 :c 2 :<cmd>ChatGPT<CR> :desc :Abrir}
                                       {1 :e
                                        2 :<cmd>ChatGPTEditWithInstructions<CR>
                                        :desc "Editar com instruções"}]
                                      :<leader>ec)
                 :config true}
                ; Verificador de gramática
                {1 :brymer-meneses/grammar-guard.nvim
                 :event :BufReadPost
                 :dependencies [:neovim/nvim-lspconfig
                                :williamboman/mason.nvim]
                 :config #(requireAnd :grammar-guard #($.init))}
                :uga-rosa/utf8.nvim
                ; Funcionalidades para a linguagem Nim
                {1 :alaviss/nim.nvim :ft :nim}])

(let [(_ user-plugins) (xpcall #(require :user.plugins)
                               (fn []
                                 []))]
  (each [_ user-plugin (pairs user-plugins)]
    (table.insert plugins user-plugin)))

plugins
