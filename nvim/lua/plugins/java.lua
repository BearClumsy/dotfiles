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
