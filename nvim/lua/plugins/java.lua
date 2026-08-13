return {
  {
    "mfussenegger/nvim-jdtls",
    opts = {
      settings = {
        java = {
          configuration = {
            runtimes = {
              {
                name = "JavaSE-26",
                path = vim.fn.expand("~/.gradle/jdks/eclipse_adoptium-26-aarch64-os_x.2/jdk-26.0.1+8/Contents/Home"),
              },
            },
          },
          -- jdtls defaults both of these to false server-side and returns an
          -- empty result for every textDocument/signatureHelp request until
          -- they are set, which surfaces as "No signature help available".
          signatureHelp = {
            enabled = true,
            description = { enabled = true },
          },
        },
      },
      -- jdtls keeps its own compiled model of the project separate from file
      -- buffers, so changes made outside Neovim (e.g. by an external tool)
      -- aren't picked up until one of these runs.
      on_attach = function(args)
        vim.keymap.set("n", "<leader>cu", "<cmd>JdtUpdateConfig<cr>",
          { buffer = args.buf, desc = "Update Project Config" })
        vim.keymap.set("n", "<leader>cC", "<cmd>JdtCompile incremental<cr>",
          { buffer = args.buf, desc = "Compile (Incremental)" })

        -- <leader>td is neotest's "Debug Nearest", but no Java neotest adapter
        -- is installed, so it always reports "No tests found". Point it at the
        -- jdtls equivalent, which launches through java-debug-adapter.
        local ok, jdtls_dap = pcall(require, "jdtls.dap")
        if ok then
          vim.keymap.set("n", "<leader>td", function()
            jdtls_dap.test_nearest_method()
          end, { buffer = args.buf, desc = "Debug Nearest Test" })
        end

        -- jdtls looks for the enclosing "(" by scanning backwards from
        -- offset - 1, so a cursor parked *on* the "(" never sees it and the
        -- scan runs left into the enclosing brace. Nudge one column right for
        -- the request, then put the cursor back. Scheduled so this lands after
        -- LazyVim's own buffer-local gK from its LspAttach handler.
        vim.schedule(function()
          -- jdtls also attaches to short-lived buffers (e.g. the ones opened
          -- during a dap test run), which can be gone by the time this runs.
          if not vim.api.nvim_buf_is_valid(args.buf) then
            return
          end
          vim.keymap.set("n", "gK", function()
            local line = vim.api.nvim_get_current_line()
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))
            if line:sub(col + 1, col + 1) == "(" then
              vim.api.nvim_win_set_cursor(0, { row, col + 1 })
              vim.lsp.buf.signature_help()
              vim.api.nvim_win_set_cursor(0, { row, col })
            else
              vim.lsp.buf.signature_help()
            end
          end, { buffer = args.buf, desc = "Signature Help" })
        end)
      end,
    },
  },

  -- Format Java with the real google-java-format tool (same one Spotless runs
  -- in the Gradle build), so editor formatting always matches `spotlessCheck`.
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        google_java_format = {
          command = "java",
          args = {
            "--add-exports",
            "jdk.compiler/com.sun.tools.javac.api=ALL-UNNAMED",
            "--add-exports",
            "jdk.compiler/com.sun.tools.javac.file=ALL-UNNAMED",
            "--add-exports",
            "jdk.compiler/com.sun.tools.javac.parser=ALL-UNNAMED",
            "--add-exports",
            "jdk.compiler/com.sun.tools.javac.tree=ALL-UNNAMED",
            "--add-exports",
            "jdk.compiler/com.sun.tools.javac.util=ALL-UNNAMED",
            "--add-opens",
            "jdk.compiler/com.sun.tools.javac.code=ALL-UNNAMED",
            "-jar",
            vim.fn.expand("~/.local/share/nvim/google-java-format/google-java-format-1.28.0-all-deps.jar"),
            "-",
          },
          stdin = true,
        },
      },
      formatters_by_ft = {
        java = { "google_java_format" },
      },
    },
  },
}
