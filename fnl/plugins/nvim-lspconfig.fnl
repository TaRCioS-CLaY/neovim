(import-macros {: augroup!} :hibiscus.vim)
(local {: requireAnd : format} (require :functions))
(local M {1 :neovim/nvim-lspconfig
          :event :BufReadPost
          :dependencies [:mason.nvim
                         :williamboman/mason-lspconfig.nvim
                         :SmiteshP/nvim-navic]})

(fn M.on_attach [client bufnr]
  (local capabilities client.server_capabilities)
  (when capabilities.documentSymbolProvider
    (local navic (require :nvim-navic))
    (navic.attach client bufnr))
  (set vim.lsp.handlers.textDocument/publishDiagnostics
       (vim.lsp.with vim.lsp.diagnostic.on_publish_diagnostics
         {:virtual_text false})))

(fn M.config []
  (local mason (require :mason))
  (local mason-lspconfig (require :mason-lspconfig))
  (local lspconfig (require :lspconfig))
  ;; {:virtual_text {:prefix :x}})))
  (local capabilities (requireAnd :cmp_nvim_lsp #($.default_capabilities)))
  (set lspconfig.util.default_config
       (vim.tbl_extend :force lspconfig.util.default_config
                       {:on_attach M.on_attach : capabilities}))
  ;; Desativar virtual text porque estamos usando o plugin lsp_lines
  (vim.diagnostic.config {:virtual_text false})
  (λ get-config-options [server-name default-config]
    (match server-name
      :sumneko_lua {:settings {:Lua {:runtime {:version :LuaJIT}
                                     :diagnostics {:globals [:vim]}
                                     :workspace {:library (vim.api.nvim_list_runtime_paths)}}}}
      :ltext {:root_dir vim.loop.cwd}
      :fennel_language_server
      {:settings {:fennel {:workspace {:library (vim.api.nvim_list_runtime_paths)}
                           :diagnostics {:globals [:vim]}}}}
      :tailwindcss {:settings {:tailwindCSS {:includeLanguages {:elm :html}
                                             :experimental {:classRegex ["\\bclass[\\s(<|]+\"([^\"]*)\""
                                                                         "\\bclass[\\s(]+\"[^\"]*\"[\\s+]+\"([^\"]*)\""
                                                                         "\\bclass[\\s<|]+\"[^\"]*\"\\s*\\+{2}\\s*\" ([^\"]*)\""
                                                                         "\\bclass[\\s<|]+\"[^\"]*\"\\s*\\+{2}\\s*\" [^\"]*\"\\s*\\+{2}\\s*\" ([^\"]*)\""
                                                                         "\\bclass[\\s<|]+\"[^\"]*\"\\s*\\+{2}\\s*\" [^\"]*\"\\s*\\+{2}\\s*\" [^\"]*\"\\s*\\+{2}\\s*\" ([^\"]*)\""
                                                                         "\\bclassList[\\s\\[\\(]+\"([^\"]*)\""
                                                                         "\\bclassList[\\s\\[\\(]+\"[^\"]*\",\\s[^\\)]+\\)[\\s\\[\\(,]+\"([^\"]*)\""
                                                                         "\\bclassList[\\s\\[\\(]+\"[^\"]*\",\\s[^\\)]+\\)[\\s\\[\\(,]+\"[^\"]*\",\\s[^\\)]+\\)[\\s\\[\\(,]+\"([^\"]*)\""]}}}
                    :init_options {:userLanguages {:elm :html}}
                    :filetypes [:elm (unpack default-config.filetypes)]}
      :yamlls {:settings {:yaml {:keyOrdering false}}}
      _ {}))
  (mason.setup {})
  (mason-lspconfig.setup {})
  (mason-lspconfig.setup_handlers [(fn [server-name]
                                     (let [server (. lspconfig server-name)]
                                       (-> server-name
                                           (get-config-options server.document_config.default_config)
                                           (server.setup))))])
  (requireAnd :code-support #($.setup))
  (lspconfig.nimls.setup {}))

M
