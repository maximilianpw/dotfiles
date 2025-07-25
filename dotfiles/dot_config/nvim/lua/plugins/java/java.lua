return {
  'nvim-java/nvim-java',
  config = false,
  dependencies = {
    {
      'neovim/nvim-lspconfig',
      opts = {
        setup = {
          jdtls = function()
            -- Your nvim-java configuration goes here
            require('java').setup {
              root_markers = {
                'settings.gradle',
                'settings.gradle.kts',
                'pom.xml',
                'build.gradle',
                'mvnw',
                'gradlew',
                'build.gradle',
                'build.gradle.kts',
              },
            }
          end,
        },
      },
    },
  },
}
